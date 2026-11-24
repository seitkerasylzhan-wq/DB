
-- L.ABORATORY WORK 8: SQL INDEXES
-- PART 1: Database Setup
DROP TABLE IF EXISTS projects, employees, departments CASCADE;

CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);

CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(100),
                           dept_id INT,
                           salary DECIMAL(10,2),
                           FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
                          proj_id INT PRIMARY KEY,
                          proj_name VARCHAR(100),
                          budget DECIMAL(12,2),
                          dept_id INT,
                          FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
                            (101, 'IT', 'Building A'),
                            (102, 'HR', 'Building B'),
                            (103, 'Operations', 'Building C');

INSERT INTO employees VALUES
                          (1, 'John Smith', 101, 50000),
                          (2, 'Jane Doe', 101, 55000),
                          (3, 'Mike Johnson', 102, 48000),
                          (4, 'Sarah Williams', 102, 52000),
                          (5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
                         (201, 'Website Redesign', 75000, 101),
                         (202, 'Database Migration', 120000, 101),
                         (203, 'HR System Upgrade', 50000, 102);

-- PART 2: Creating Basic Indexes
-- Exercise 2.1: Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

/* ANSWER 2.1:
There are two indexes on the employees table: one automatic index created for the primary key (emp_id)
   and one custom index created on the salary column (emp_salary_idx)
*/

-- Exercise 2.2: Index on Foreign Key
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;

/* ANSWER 2.2:
It makes join operations and searches between related tables much faster.
*/

-- Exercise 2.3: View Index Information
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

/* ANSWER 2.3:
The indexes for primary keys (like departments_pkey, employees_pkey,
   and projects_pkey) were created automatically by PostgreSQL.
*/

-- PART 3: Multicolumn Indexes
-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

/* ANSWER 3.1:
No, because in a multicolumn index, PostgreSQL uses the columns from left to right.
   If the first column (dept_id) is missing in the WHERE clause, the index cannot be used effectively.
*/

-- Exercise 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

/* ANSWER 3.2:
   Yes, the order matters. The index works best when you filter by the first column or both columns together from left to right
*/

-- PART 4: Unique Indexes
-- Exercise 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email) VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

/* ANSWER 4.1:
We received a unique violation error because the email address already exists in the table.
*/

-- Exercise 4.2: Unique Index vs UNIQUE Constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

/* ANSWER 4.2:
Yes, PostgreSQL automatically created a B-tree unique index for the unique constraint
*/

-- PART 5: Indexes and Sorting
-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

/* ANSWER 5.1:
The index stores the data already sorted in descending order, so the database does not need to sort it manually during the query.
*/

-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

-- PART 6: Indexes on Expressions
-- Exercise 6.1
CREATE INDEX emp_name_lower_idx ON employees (LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

/* ANSWER 6.1:
PostgreSQL would use a sequential scan, checking every row one by one and converting each name to lowercase.
*/

-- Exercise 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- PART 7: Managing Indexes
-- Exercise 7.1: Rename
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

-- Exercise 7.2: Drop
DROP INDEX emp_salary_dept_idx;

/* ANSWER 7.2:
To save disk space and improve the speed of write operations (INSERT, UPDATE, DELETE), because unused indexes slow them down.
*/

-- Exercise 7.3: Reindex
REINDEX INDEX employees_salary_index;

-- PART 8: Practical Scenarios
-- Exercise 8.1: Optimize a Slow Query
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Exercise 8.2: Partial Index
CREATE INDEX proj_high_budget_idx ON projects(budget) WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

/* ANSWER 8.2:
A partial index is smaller and faster because it only indexes a specific subset of rows (e.g., where budget > 80000) instead of the whole table.
*/

-- Exercise 8.3: Analyze Index Usage
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

/* ANSWER 8.3:
It shows an "Index Scan", which tells us that the database successfully used the index to find the data faster instead of reading the whole table.
*/

-- PART 9: Index Types Comparison
-- Exercise 9.1: Hash Index
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';

/* ANSWER 9.1:
You should use a HASH index only when you need fast simple equality comparisons (=), but not for range queries (like >, <, or BETWEEN).
*/

-- Exercise 9.2: B-tree vs Hash
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

SELECT * FROM projects WHERE proj_name = 'Website Redesign';
SELECT * FROM projects WHERE proj_name > 'Database';

-- PART 10: Cleanup and Best Practices
-- Exercise 10.1: Review All Indexes
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

/* ANSWER 10.1:
The index on primary keys or text columns with the most data is usually the largest because it stores more keys and references.
*/

-- Exercise 10.2: Drop Unnecessary Indexes
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Exercise 10.3: Document Your Indexes
DROP VIEW IF EXISTS index_documentation;
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;

-- SUMMARY QUESTIONS (ҚОРЫТЫНДЫ СҰРАҚТАРДЫҢ ЖАУАПТАРЫ)
/*
What is the default index type in PostgreSQL?B-tree.
Name three scenarios where you should create an index:For columns frequently used in WHERE clauses, JOIN conditions, and ORDER BY clauses.
Name two scenarios where you should NOT create an index:On small tables, or on columns that are updated very frequently with few read queries.
What happens to indexes when you INSERT, UPDATE, or DELETE data?The indexes must also be updated, which adds a small overhead and slows down write operations.
How can you check if a query is using an index?By using the EXPLAIN command before the query.
*/

-- ADDITIONAL CHALLENGES (OPTIONAL)-
-- 1. Ай бойынша іздеу индексі
CREATE INDEX emp_hire_month_idx ON employees(EXTRACT(MONTH FROM hire_date));

-- 2. dept_id және email бойынша бірегей индекс
CREATE UNIQUE INDEX emp_dept_email_unique_idx ON employees(dept_id, email);

-- 3. Өнімділікті салыстыру
EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 52000;

-- 4. Covering index
CREATE INDEX emp_dept_covering_idx ON employees(dept_id) INCLUDE (emp_name, salary);