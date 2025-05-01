CREATE DATABASE employees_performance
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

use employees_performance;



CREATE TABLE account(
account_id INT auto_increment PRIMARY KEY,
username VARCHAR(50) UNIQUE,
pwd VARCHAR(1000),
acc_role VARCHAR(20),
created_at datetime,
updated_at datetime);



CREATE TABLE employees(
employee_id INT auto_increment PRIMARY KEY,
name VARCHAR(50),
birth_date DATE,
email VARCHAR(100) UNIQUE,
phone VARCHAR(12) UNIQUE,
job_title VARCHAR(100),
account_id INT,
department_id INT,
created_at datetime,
updated_at datetime);



CREATE TABLE manage_info(
manage_info_id INT auto_increment PRIMARY KEY,
employee_id INT,
line_manager_id INT,
start_date DATE,
end_date DATE,
created_at datetime,
updated_at datetime);



CREATE TABLE departments(
department_id INT auto_increment PRIMARY KEY,
department_name VARCHAR(50),
description TEXT,
function_head_id INT,
created_at datetime,
updated_at datetime);



CREATE TABLE kpi(
kpi_id INT auto_increment PRIMARY KEY,
kpi_name VARCHAR(1000),
kpi_year YEAR,
type VARCHAR(50),
percent DECIMAL(5,2) CHECK (percent >= 0 AND percent <= 100),
description TEXT,
created_at datetime,
updated_at datetime);



CREATE TABLE kpa(
kpa_id INT auto_increment PRIMARY KEY,
kpa_name VARCHAR(1000),
description TEXT,
percent DECIMAL(5,2) CHECK (percent >= 0 AND percent <= 100),
kpi_id INT,
created_at datetime,
updated_at datetime);



CREATE TABLE assessment(
assessment_id INT auto_increment PRIMARY KEY,
employee_id INT,
line_manager_id INT,
kpa_id INT,
kpi_id INT,
evaluate INT,
comments TEXT,
link VARCHAR(100),
created_at datetime,
updated_at datetime,
status varchar(20) default "pending");



CREATE TABLE review(
review_id INT auto_increment PRIMARY KEY,
line_manager_id INT,
assessment_id INT,
employee_id INT,
kpi_id INT,
kpa_id INT,
employee_evaluate INT,
employee_link VARCHAR(100),
evaluate INT,
comments TEXT,
created_at datetime,
updated_at datetime,
status varchar(20) default "pending");



ALTER TABLE employees
ADD CONSTRAINT fk_account_id FOREIGN KEY employees(account_id) REFERENCES account(account_id);
ALTER TABLE employees
ADD CONSTRAINT fk_department_id FOREIGN KEY employees(department_id) REFERENCES departments(department_id);



ALTER TABLE manage_info
ADD CONSTRAINT fk_employee_id FOREIGN KEY manage_info(employee_id) REFERENCES employees(employee_id);
ALTER TABLE manage_info
ADD CONSTRAINT fk_line_manager_id FOREIGN KEY manage_info(line_manager_id) REFERENCES employees(employee_id);



ALTER TABLE departments
ADD CONSTRAINT fk_function_head_id FOREIGN KEY departments(function_head_id) REFERENCES employees(employee_id);



ALTER TABLE kpa
ADD CONSTRAINT fk_kpi_id FOREIGN KEY kpa(kpi_id) REFERENCES kpi(kpi_id);



ALTER TABLE assessment 
ADD CONSTRAINT fk_employee_assessment FOREIGN KEY assessment(employee_id) REFERENCES employees(employee_id);
ALTER TABLE assessment 
ADD CONSTRAINT fk_manager_assessment FOREIGN KEY assessment(line_manager_id) REFERENCES employees(employee_id);
ALTER TABLE assessment
ADD CONSTRAINT fk_kpa_id FOREIGN KEY assessment(kpa_id) REFERENCES kpa(kpa_id);
ALTER TABLE assessment 
ADD CONSTRAINT fk_kpi_assessment FOREIGN KEY assessment(kpi_id) REFERENCES kpi(kpi_id);



ALTER TABLE review
ADD CONSTRAINT fk_line_manager FOREIGN KEY review(line_manager_id) REFERENCES employees(employee_id);
ALTER TABLE review 
ADD CONSTRAINT fk_employee FOREIGN KEY review(employee_id) REFERENCES employees(employee_id);
ALTER TABLE review
ADD CONSTRAINT fk_assessment FOREIGN KEY review(assessment_id) REFERENCES assessment(assessment_id);
ALTER TABLE review
ADD CONSTRAINT fk_kpi FOREIGN KEY review(kpi_id) REFERENCES kpi(kpi_id);
ALTER TABLE review
ADD CONSTRAINT fk_kpa FOREIGN KEY review(kpa_id) REFERENCES kpa(kpa_id);

