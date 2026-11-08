-- Part 1: Database Setup
-- Step 1.1: Create Sample Tables
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2)
);

CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);

CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2)
);

-- Step 1.2: Insert Sample Data
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id,
                      budget) VALUES
                                  (1, 'Website Redesign', 101, 100000),
                                  (2, 'Employee Training', 102, 50000),
                                  (3, 'Budget Analysis', 103, 75000),
                                  (4, 'Cloud Migration', 101, 150000),
                                  (5, 'AI Research', NULL, 200000);

-- Part 2: CROSS JOIN Exercises
-- Exercise 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;

/*
Question: How many rows does the result contain? Calculate N × M where N = number of employees, M = number of departments.

Answer:
The result contains 20 rows.
Calculation: N × M = 5 (employees) × 4 (departments) = 20 rows.
*/

-- Exercise 2.2: Alternative CROSS JOIN Syntax

-- a) Comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- b) INNER JOIN with TRUE condition
SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d ON TRUE;

-- Exercise 2.3: Practical CROSS JOIN
SELECT
    e.emp_name,
    p.project_name
FROM employees e
         CROSS JOIN projects p;

-- Part 3: INNER JOIN Exercises
-- Exercise 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;

/*
Question: How many rows are returned? Why is Tom Brown not included?

Answer:
1. 4 rows are returned.
2. Tom Brown is not included because his dept_id is NULL.
*/

-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
         INNER JOIN departments USING (dept_id);

/*
Question: What's the difference in output columns compared to the ON version?

Answer:
When using `USING (dept_id)`, the join column (`dept_id`) is merged into a single
column in the output if you use `SELECT *`.
With `ON (e.dept_id = d.dept_id)`, both `e.dept_id` and `d.dept_id` would appear as
separate columns in `SELECT *`.
*/

-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
         INNER JOIN departments USING (dept_id);

/*
Question: What's the difference in output columns compared to the ON version?

Answer:
1. With USING, the database shows `dept_id` only one time.
2. With ON, the database shows `dept_id` two times (from employees and from departments).
*/

-- Exercise 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees
         NATURAL INNER JOIN departments;

-- Exercise 3.4: Multi-table INNER JOIN
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
         INNER JOIN projects p ON d.dept_id = p.dept_id;

--Part 4: LEFT JOIN Exercises
-- Exercise 4.1: Basic LEFT JOIN
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id;

/*
Question: How is Tom Brown represented in the results?

Answer:
Tom Brown is included in the list.
His employee data is shown, but his department fields (dept_dept and dept_name) are NULL.
*/

-- Exercise 4.2: LEFT JOIN with USING
SELECT emp_name, dept_id, dept_name
FROM employees
         LEFT JOIN departments USING (dept_id);

-- Exercise 4.3: Find Unmatched Records
SELECT e.emp_name, e.dept_id
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Exercise 4.4: LEFT JOIN with Aggregation
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

--Part 5: RIGHT JOIN Exercises
-- Exercise 5.1: Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 5.2: Convert to LEFT JOIN
SELECT e.emp_name, d.dept_name
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- Exercise 5.3: Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--Part 6: FULL JOIN Exercises
--Exercise 6.1: Basic FULL JOIN
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id;

/*
Question: Which records have NULL values on the left side? Which have NULL on the right side?

Answer:
1. NULL on the left side (employees side):
   - Department 'Marketing' (dept_id 104) has NULL for employee data because it has no employees.

2. NULL on the right side (departments side):
   - Employee 'Tom Brown' has NULL for department data because he is not assigned to any department.
*/

--Exercise 6.2: FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
         FULL JOIN projects p ON d.dept_id = p.dept_id;

-- Exercise 6.3: Find Orphaned Records
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
        END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--Part 7: ON vs WHERE Clause
--Exercise 7.1: Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id AND
                                    d.location = 'Building A';

--Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Exercise 7.2: Filtering in WHERE Clause (Query 2)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

/*
Question: Compare the results of Query 1 and Query 2. Explain the difference.

Answer:
- Query 1 (ON clause): Applies the filter BEFORE the join. All employees are kept in the list, but departments not in 'Building A' show NULL.
- Query 2 (WHERE clause): Applies the filter AFTER the join. It removes all employees whose department is not in 'Building A'.
*/

-- Exercise 7.3: ON vs WHERE with INNER JOIN

-- Query 1 with INNER JOIN (Filter in ON clause)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Query 2 with INNER JOIN (Filter in WHERE clause)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

/*
Question: Is there any difference in results? Why or why not?

Answer:
No, there is no difference in the results. Both queries return the exact same rows.
This is because INNER JOIN only keeps rows that match both conditions, so filtering before or after the join gives the same result.
*/

--Part 8: Complex JOIN Scenarios
-- Exercise 8.1: Multiple Joins with Different Types
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Exercise 8.2: Self Join

-- 1. Добавляем новую колонку manager_id
ALTER TABLE employees ADD COLUMN manager_id INT;

-- 2. Заполняем данные о менеджерах
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- 3. Запрос Self Join (таблица соединяется сама с собой)
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Exercise 8.3: Join with Subquery / Group By
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

/*
LAB QUESTIONS

1. What is the difference between INNER JOIN and LEFT JOIN?
Answer:
- INNER JOIN returns only rows that have a match in both tables.
- LEFT JOIN returns all rows from the left table, plus matching rows from the right table. If there is no match, it shows NULL for right table columns.

2. When would you use CROSS JOIN in a practical scenario?
Answer:
You use CROSS JOIN when you need to make all possible combinations of items from two lists (for example: pairing every employee with every project to make an availability matrix, or combining sizes and colors for products).

3. Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.
Answer:
- For OUTER JOINs (LEFT/RIGHT): ON filters data before joining (keeps all rows from the main table). WHERE filters data after joining (removes rows with NULLs).
- For INNER JOINs: Both ON and WHERE give the same result because rows without matches are removed anyway.

4. What is the result of: SELECT COUNT(*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?
Answer:
The result is 50 rows (5 * 10 = 50).

5. How does NATURAL JOIN determine which columns to join on?
Answer:
NATURAL JOIN automatically finds and joins columns that have the exact same name in both tables.

6. What are the potential risks of using NATURAL JOIN?
Answer:
If someone adds a new column to one of the tables with a matching name (like created_at or status), the query will automatically try to join on that column too, which can break your query or return wrong data.

7. Convert this LEFT JOIN to a RIGHT JOIN: SELECT * FROM A LEFT JOIN B ON A.id = B.id
Answer:
SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

8. When should you use FULL OUTER JOIN instead of other join types?
Answer:
Use FULL OUTER JOIN when you want to see all data from both tables and find unmatched records on both sides (for example: finding employees without departments AND departments without employees at the same time).
*/

-- Challenge 1: Simulate FULL OUTER JOIN using UNION (LEFT + RIGHT JOIN)
SELECT e.emp_name, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id

UNION

SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;


-- Challenge 2: Employees in departments with more than one project
SELECT e.emp_name, d.dept_name, COUNT(p.project_id) AS total_projects
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
         INNER JOIN projects p ON d.dept_id = p.dept_id
GROUP BY e.emp_id, e.emp_name, d.dept_id, d.dept_name
HAVING COUNT(p.project_id) > 1;


-- Challenge 3: Hierarchical structure (Employee -> Manager -> Manager's Manager)
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager,
    top_m.emp_name AS top_manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id
         LEFT JOIN employees top_m ON m.manager_id = top_m.emp_id;


-- Challenge 4: Pairs of employees working in the same department
SELECT
    e1.emp_name AS employee_1,
    e2.emp_name AS employee_2,
    d.dept_name
FROM employees e1
         INNER JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
         INNER JOIN departments d ON e1.dept_id = d.dept_id;