-- Seitker Asylzhan
-- id: 25B031814


--------------------------------------------------------------------------------
-- PART 1: CHECK Constraints
--------------------------------------------------------------------------------

-- Task 1.1: Basic CHECK Constraint
CREATE TABLE employees (
                           employee_id INTEGER,
                           first_name TEXT,
                           last_name TEXT,
                           age INTEGER CHECK (age BETWEEN 18 AND 65), -- Ensures age is between 18 and 65
                           salary NUMERIC CHECK (salary > 0)          -- Ensures salary is strictly positive
);

-- Task 1.2: Named CHECK Constraint
CREATE TABLE products_catalog (
                                  product_id INTEGER,
                                  product_name TEXT,
                                  regular_price NUMERIC,
                                  discount_price NUMERIC,
    -- Named constraint ensuring valid pricing logic
                                  CONSTRAINT valid_discount CHECK (
                                      regular_price > 0
                                          AND discount_price > 0
                                          AND discount_price < regular_price
                                      )
);

-- Task 1.3: Multiple Column CHECK
CREATE TABLE bookings (
                          booking_id INTEGER,
                          check_in_date DATE,
                          check_out_date DATE,
                          num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10), -- Guest limit constraint
                          CONSTRAINT chk_valid_dates CHECK (check_out_date > check_in_date) -- Check-out must be after check-in
);

-- Task 1.4: Testing CHECK Constraints
-- Successful inserts for employees:
INSERT INTO employees VALUES (1, 'Alice', 'Smith', 30, 50000.00);
INSERT INTO employees VALUES (2, 'Bob', 'Jones', 45, 75000.50);

-- Failed insert for employees (Violates age constraint):
-- INSERT INTO employees VALUES (3, 'Charlie', 'Brown', 16, 30000.00);
-- Result: ERROR: new row for relation "employees" violates check constraint "employees_age_check"

-- Failed insert for employees (Violates salary constraint):
-- INSERT INTO employees VALUES (4, 'Diana', 'Prince', 25, -500.00);
-- Result: ERROR: new row for relation "employees" violates check constraint "employees_salary_check"


--------------------------------------------------------------------------------
-- PART 2: NOT NULL Constraints
--------------------------------------------------------------------------------

-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers_part2 (
                                 customer_id INTEGER NOT NULL,
                                 email TEXT NOT NULL,
                                 phone TEXT, -- Can be NULL
                                 registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
                           item_id INTEGER NOT NULL,
                           item_name TEXT NOT NULL,
                           quantity INTEGER NOT NULL CHECK (quantity >= 0),
                           unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL
-- Successful complete record:
INSERT INTO inventory VALUES (101, 'Mouse', 50, 25.99, '2026-10-14 12:00:00');

-- Failed insert (Violates NOT NULL on quantity):
-- INSERT INTO inventory VALUES (102, 'Keyboard', NULL, 45.00, '2026-10-14 12:00:00');
-- Result: ERROR: null value in column "quantity" violates not-null constraint


--------------------------------------------------------------------------------
-- PART 3: UNIQUE Constraints
--------------------------------------------------------------------------------

-- Task 3.1 & 3.3: Named UNIQUE Constraints
CREATE TABLE users (
                       user_id INTEGER,
                       username TEXT,
                       email TEXT,
                       created_at TIMESTAMP,
                       CONSTRAINT unique_username UNIQUE (username),
                       CONSTRAINT unique_email UNIQUE (email)
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
                                    enrollment_id INTEGER,
                                    student_id INTEGER,
                                    course_code TEXT,
                                    semester TEXT,
                                    CONSTRAINT unique_student_course UNIQUE (student_id, course_code, semester)
);


--------------------------------------------------------------------------------
-- PART 4: PRIMARY KEY Constraints
--------------------------------------------------------------------------------

-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY, -- Uniquely identifies each department, implies NOT NULL
                             dept_name TEXT NOT NULL,
                             location TEXT
);

INSERT INTO departments VALUES (1, 'HR', 'Building A');
INSERT INTO departments VALUES (2, 'IT', 'Building B');
INSERT INTO departments VALUES (3, 'Finance', 'Building C');

-- Failed insert (Duplicate primary key):
-- INSERT INTO departments VALUES (1, 'Marketing', 'Building D');
-- Result: ERROR: duplicate key value violates unique constraint "departments_pkey"

-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 enrollment_date DATE,
                                 grade TEXT,
                                 PRIMARY KEY (student_id, course_id) -- Combination must be unique
);


--------------------------------------------------------------------------------
-- PART 5: FOREIGN KEY Constraints
--------------------------------------------------------------------------------

-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
                                emp_id INTEGER PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INTEGER REFERENCES departments(dept_id), -- Links to departments table
                                hire_date DATE
);

INSERT INTO employees_dept VALUES (101, 'Alice Smith', 1, '2026-01-10');
-- Failed insert (Non-existent department ID):
-- INSERT INTO employees_dept VALUES (102, 'Bob Jones', 99, '2026-02-15');
-- Result: ERROR: insert or update on table "employees_dept" violates foreign key constraint

-- Task 5.2: Multiple Foreign Keys
CREATE TABLE authors (
                         author_id INTEGER PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

CREATE TABLE publishers (
                            publisher_id INTEGER PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

CREATE TABLE books (
                       book_id INTEGER PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INTEGER REFERENCES authors(author_id),
                       publisher_id INTEGER REFERENCES publishers(publisher_id),
                       publication_year INTEGER,
                       isbn TEXT UNIQUE
);

-- Task 5.3: ON DELETE Options
CREATE TABLE categories (
                            category_id INTEGER PRIMARY KEY,
                            category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
                             product_id INTEGER PRIMARY KEY,
                             product_name TEXT NOT NULL,
                             category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders_fk_test (
                                order_id INTEGER PRIMARY KEY,
                                order_date DATE NOT NULL
);

CREATE TABLE order_items_fk_test (
                                     item_id INTEGER PRIMARY KEY,
                                     order_id INTEGER REFERENCES orders_fk_test(order_id) ON DELETE CASCADE,
                                     product_id INTEGER REFERENCES products_fk(product_id),
                                     quantity INTEGER CHECK (quantity > 0)
);


--------------------------------------------------------------------------------
-- PART 6: Practical Application (E-commerce System Schema)
--------------------------------------------------------------------------------

-- Customers Table
CREATE TABLE ecommerce_customers (
                                     customer_id INTEGER PRIMARY KEY,
                                     name TEXT NOT NULL,
                                     email TEXT UNIQUE NOT NULL,
                                     phone TEXT,
                                     registration_date DATE NOT NULL
);

-- Products Table
CREATE TABLE ecommerce_products (
                                    product_id INTEGER PRIMARY KEY,
                                    name TEXT NOT NULL,
                                    description TEXT,
                                    price NUMERIC NOT NULL CHECK (price >= 0),
                                    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

-- Orders Table
CREATE TABLE ecommerce_orders (
                                  order_id INTEGER PRIMARY KEY,
                                  customer_id INTEGER NOT NULL REFERENCES ecommerce_customers(customer_id) ON DELETE CASCADE,
                                  order_date DATE NOT NULL,
                                  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
                                  status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

-- Order Details Table
CREATE TABLE ecommerce_order_details (
                                         order_detail_id INTEGER PRIMARY KEY,
                                         order_id INTEGER NOT NULL REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
                                         product_id INTEGER NOT NULL REFERENCES ecommerce_products(product_id) ON DELETE RESTRICT,
                                         quantity INTEGER NOT NULL CHECK (quantity > 0),
                                         unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Sample Data Inserts (5 records per table)
INSERT INTO ecommerce_customers VALUES (1, 'Ali Bakyt', 'ali@mail.com', '+77011234567', '2026-01-10');
INSERT INTO ecommerce_customers VALUES (2, 'Aruzhan Serik', 'aruzhan@mail.com', '+77029876543', '2026-02-12');
INSERT INTO ecommerce_customers VALUES (3, 'Timur Zhuman', 'timur@mail.com', '+77054443322', '2026-03-15');
INSERT INTO ecommerce_customers VALUES (4, 'Dana Kassym', 'dana@mail.com', '+77075556677', '2026-04-20');
INSERT INTO ecommerce_customers VALUES (5, 'Erlan Omar', 'erlan@mail.com', '+77089990011', '2026-05-01');

INSERT INTO ecommerce_products VALUES (1, 'Laptop', 'Gaming laptop', 450000.00, 10);
INSERT INTO ecommerce_products VALUES (2, 'Smartphone', 'Latest model', 250000.00, 25);
INSERT INTO ecommerce_products VALUES (3, 'Headphones', 'Wireless ANC', 45000.00, 50);
INSERT INTO ecommerce_products VALUES (4, 'Monitor', '27 inch 4K', 120000.00, 15);
INSERT INTO ecommerce_products VALUES (5, 'Keyboard', 'Mechanical RGB', 35000.00, 30);

INSERT INTO ecommerce_orders VALUES (1, 1, '2026-10-01', 495000.00, 'pending');
INSERT INTO ecommerce_orders VALUES (2, 2, '2026-10-02', 250000.00, 'processing');
INSERT INTO ecommerce_orders VALUES (3, 3, '2026-10-03', 120000.00, 'shipped');
INSERT INTO ecommerce_orders VALUES (4, 4, '2026-10-04', 35000.00, 'delivered');
INSERT INTO ecommerce_orders VALUES (5, 5, '2026-10-05', 450000.00, 'cancelled');

INSERT INTO ecommerce_order_details VALUES (1, 1, 1, 1, 450000.00);
INSERT INTO ecommerce_order_details VALUES (2, 1, 3, 1, 45000.00);
INSERT INTO ecommerce_order_details VALUES (3, 2, 2, 1, 250000.00);
INSERT INTO ecommerce_order_details VALUES (4, 3, 4, 1, 120000.00);
INSERT INTO ecommerce_order_details VALUES (5, 4, 5, 1, 35000.00);