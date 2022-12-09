--Вариант 2
--Задание 1
create database RK2;

create table jobs_types (
	id serial primary key,
	name_job VARCHAR(256),
	labor_costs int,
	equipment TEXT
);

create table customer (
	id serial primary key,
	full_name VARCHAR(256),
	year_birth int,
	experience int,
	telephone VARCHAR(32)
);

create table executor (
	id serial primary key,
	full_name VARCHAR(256),
	year_birth int,
	experience int,
	telephone VARCHAR(32)
);

create table jobs_types_customer(
	job_type_id int REFERENCES jobs_types(id),
	customer_id int REFERENCES customer(id)
);

create table jobs_types_executor(
	job_type_id int REFERENCES jobs_types(id),
	executor_id int REFERENCES executor(id)
);

create table customer_executor(
	customer_id int REFERENCES customer(id),
	executor_id int REFERENCES executor(id)
);

INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job1', 1, 'equipment1');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job2', 2, 'equipment2');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job3', 3, 'equipment5');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job4', 5, 'equipment2');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job5', 3, 'equipment2');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job6', 4, 'equipment4');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job7', 6, 'equipment5');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job8', 4, 'equipment3');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job9', 2, 'equipment7');
INSERT INTO jobs_types(name_job, labor_costs, equipment) VALUES ('job10', 3, 'equipment8');

INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name1', 2002, 1, 'telephone1');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name2', 2001, 2, 'telephone2');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name3', 2000, 1, 'telephone3');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name4', 2001, 3, 'telephone4');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name5', 2000, 4, 'telephone5');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name6', 2003, 1, 'telephone6');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name7', 2000, 2, 'telephone7');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name8', 1999, 1, 'telephone8');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name9', 1998, 1, 'telephone9');
INSERT INTO customer(full_name, year_birth, experience, telephone) VALUES ('name10', 1997, 6, 'telephone10');

INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name1', 2002, 1, 'telephone1');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name2', 2001, 2, 'telephone2');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name3', 2000, 1, 'telephone3');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name4', 2001, 3, 'telephone4');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name5', 2000, 4, 'telephone5');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name6', 2003, 1, 'telephone6');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name7', 2000, 2, 'telephone7');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name8', 1999, 1, 'telephone8');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name9', 1998, 1, 'telephone9');
INSERT INTO executor(full_name, year_birth, experience, telephone) VALUES ('name10', 1997, 6, 'telephone10');

INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (1, 2);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (1, 3);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (2, 1);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (3, 1);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (4, 5);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (5, 4);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (6, 7);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (7, 6);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (8, 9);
INSERT INTO jobs_types_customer(job_type_id, customer_id) VALUES (9, 8);

INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (1, 2);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (1, 3);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (2, 1);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (3, 1);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (4, 5);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (5, 4);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (6, 7);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (7, 6);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (8, 9);
INSERT INTO jobs_types_executor(job_type_id, executor_id) VALUES (9, 8);

INSERT INTO customer_executor(customer_id, executor_id) VALUES (1, 2);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (1, 3);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (2, 1);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (3, 1);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (4, 5);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (5, 4);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (6, 7);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (7, 6);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (8, 9);
INSERT INTO customer_executor(customer_id, executor_id) VALUES (9, 8);




--Задание 2
SELECT full_name, year_birth
FROM customer
WHERE year_birth>2000;


SELECT name_job, full_name,
	   avg(year_birth) over(PARTITION BY j.id)
FROM executor e
JOIN jobs_types_executor j_e ON j_e.executor_id=e.id
JOIN jobs_types j ON j_e.job_type_id=j.id;



SELECT c.id AS customer, c_e_join.id AS executor, c_e_join.experience AS executor_experience
FROM (SELECT * FROM executor e
	   JOIN customer_executor c_e ON e.id=c_e.executor_id
	   WHERE e.experience > 1) c_e_join
JOIN customer c ON c_e_join.customer_id=c.id;


--Задание 3
CREATE OR REPLACE PROCEDURE info_store_proc(string VARCHAR)
LANGUAGE plpgsql
AS $$ 
DECLARE proc RECORD;
BEGIN
    FOR proc in
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_type = 'PROCEDURE'
              AND routine_definition LIKE '%' || string || '%'
              AND routine_definition LIKE '%WITH RECOMPILE%'
    LOOP
        RAISE NOTICE '%', proc.routine_name;
    END LOOP;
END
$$;

CALL info_store_proc('routine_name');


