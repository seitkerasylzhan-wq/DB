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

-- Exercise 2.1: Simple View Creation
CREATE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id;

-- Проверка:
SELECT * FROM employee_details;
-- Вопрос: How many rows are returned? Why doesn't Tom Brown appear?,
--It returns only employees who have a department. Tom Brown does not appear because he has no department (dept_id is null or not in the departments table), so the inner join hides him.

-- Exercise 2.2: View with Aggregation
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Проверка:
SELECT * FROM dept_statistics
ORDER BY employee_count DESC;


-- Exercise 2.3: View with Multiple Joins
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
         JOIN departments d ON p.dept_id = d.dept_id
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name, d.location;


-- Exercise 2.4: View with Filtering
CREATE VIEW high_earners AS
SELECT
    emp_name,
    salary,
    dept_id
FROM employees
WHERE salary > 55000;

-- Вопрос: What happens when you query this view? Can you see all high-earning employees?
-- When you query this view, you only see employees with a salary greater than 55,000. You cannot see all employees, only the high earners.

-- Exercise 3.1: Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
        END AS salary_grade
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id;


-- Exercise 3.2: Rename a View
ALTER VIEW high_earners RENAME TO top_performers;

-- Верификация:
SELECT * FROM top_performers;


-- Exercise 3.3: Drop a View
CREATE TEMP VIEW temp_view AS
SELECT * FROM employees WHERE salary < 50000;

DROP VIEW temp_view;

-- Exercise 4.1: Create an Updatable View
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;


-- Exercise 4.2: Update Through a View
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

-- Проверка:
SELECT * FROM employees WHERE emp_name = 'John Smith';
-- Вопрос: Did the underlying table get updated?
-- Yes, the base table (employees) was updated successfully because simple views without aggregation are updatable.


-- Exercise 4.3: Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

-- Вопрос: Was the insert successful? Check the employees table.
-- Yes, the insert was successful, and the new employee appeared in the employees table.


-- Exercise 4.4: View with CHECK OPTION
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
        WITH LOCAL CHECK OPTION;

-- Попытка вставки (должна завершиться ошибкой):
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
-- Вопрос: What error message do you receive? Why?
-- You get a check option violation error because the new employee's department ID (103) does not match the view's condition (dept_id = 101).

-- Exercise 5.1: Create a Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_salaries,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COALESCE(SUM(p.budget), 0) AS total_project_budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
    WITH DATA;

-- Запрос:
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;


-- Exercise 5.2: Refresh Materialized View
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

REFRESH MATERIALIZED VIEW dept_summary_mv;

-- Exercise 5.3: Concurrent Refresh
CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- Exercise 5.4: Materialized View with NO DATA
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS assigned_employees
FROM projects p
         JOIN departments d ON p.dept_id = d.dept_id
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
    WITH NO DATA;

-- Query attempt:
-- SELECT * FROM project_stats_mv;
-- Error: materialized view is not populated.
-- Fix:
REFRESH MATERIALIZED VIEW project_stats_mv;

-- Exercise 6.1: Create Basic Roles
CREATE ROLE analyst NOLOGIN;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user LOGIN PASSWORD 'report456';

-- Просмотр ролей:
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';


-- Exercise 6.2: Role with Specific Attributes
CREATE ROLE db_creator CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user SUPERUSER LOGIN PASSWORD 'admin999';


-- Exercise 6.3: Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;


-- Exercise 6.4: Create Group Roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;


-- Exercise 6.5: Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;


-- Exercise 6.6: Modify Role Attributes
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

-- Exercise 7.1: Role Hierarchies
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;


-- Exercise 7.2: Object Ownership
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

-- Проверка владения:
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';


-- Exercise 7.3: Reassign and Drop Roles
CREATE ROLE temp_owner LOGIN;

CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;


-- Exercise 7.4: Row-Level Security with Views
CREATE VIEW hr_employee AS
SELECT * FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

-- Exercise 8.1: Department Dashboard View
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS employee_count,
    ROUND(COALESCE(AVG(e.salary), 0), 2) AS avg_salary,
    COUNT(DISTINCT p.project_id) AS active_projects,
    COALESCE(SUM(p.budget), 0) AS total_project_budget,
    CASE
        WHEN COUNT(e.emp_id) = 0 THEN 0.00
        ELSE ROUND(COALESCE(SUM(p.budget), 0) / COUNT(e.emp_id), 2)
        END AS budget_per_employee
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;


-- Exercise 8.2: Audit View
-- Шаг 1: Добавление колонки created_date в таблицу projects (если её нет)
ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Шаги 2, 3, 4: Создание представления high_budget_projects с классификацией бюджета
CREATE OR REPLACE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
        END AS approval_status
FROM projects p
         JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;


-- Exercise 8.3: Create Access Control System
-- Level 1: Viewer Role
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

-- Level 2: Entry Role
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

-- Level 3: Analyst Role
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

-- Level 4: Manager Role
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

-- Создание пользователей и назначение ролей:
CREATE ROLE alice LOGIN PASSWORD 'alice123';
CREATE ROLE bob LOGIN PASSWORD 'bob123';
CREATE ROLE charlie LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;