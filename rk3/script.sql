DROP TABLE IF EXISTS workers CASCADE;
DROP TABLE IF EXISTS timetable CASCADE;

CREATE TABLE IF NOT EXISTS workers
(
    id INT PRIMARY KEY,
    fio VARCHAR,
    birthdate DATE,
    department VARCHAR
);

CREATE TABLE IF NOT EXISTS timetable
(
    worker_id INT,
    dt DATE,
    weekday VARCHAR,
    time_value time,
    action_type INT,
    FOREIGN KEY(worker_id) REFERENCES workers(id)
);

INSERT INTO workers
VALUES 
    (1, 'fio1', '2002-09-09', 'depart1'),
    (2, 'fio2', '2002-03-23', 'depart2'),
    (3, 'fio3', '1976-01-18', 'depart3'),
    (4, 'fio4', '2002-06-21', 'depart4'),
    (5, 'fio5', '2005-03-24', 'depart5'),
    (6, 'fio6', '1976-02-14', 'depart2');

INSERT INTO timetable
VALUES
    (1, '2022-11-01', 'Monday', '9:03', 1),
    (1, '2022-11-01', 'Monday', '10:30', 2),
    (1, '2022-11-09', 'Saturday', '11:50', 1),
    (1, '2022-11-09', 'Saturday', '19:30', 2),
    (1, '2022-11-25', 'Friday', '11:20', 1),
    (1, '2022-11-25', 'Friday', '18:45', 2),
    (1, '2022-11-08', 'Saturday', '11:50', 1),
    (1, '2022-11-07', 'Saturday', '11:50', 1),
    (1, '2022-11-06', 'Saturday', '11:50', 1),
    (1, '2022-11-05', 'Saturday', '11:50', 1),

    (2, '2022-11-01', 'Monday', '9:04', 1),
    (2, '2022-11-01', 'Monday', '17:30', 2),
    (2, '2022-11-09', 'Saturday', '11:50', 1),
    (2, '2022-11-09', 'Saturday', '19:30', 2),
    (2, '2022-11-25', 'Friday', '11:20', 1),
    (2, '2022-11-25', 'Friday', '18:45', 2),

    (3, '2022-11-01', 'Monday', '9:20', 1),
    (3, '2022-11-01', 'Monday', '10:30', 2),
    (3, '2022-11-09', 'Saturday', '12:50', 1),
    (3, '2022-11-09', 'Saturday', '19:30', 2),
    (3, '2022-11-25', 'Friday', '11:20', 1),
    (3, '2022-11-25', 'Friday', '18:45', 2),

    (4, '2022-11-01', 'Monday', '9:20', 1),
    (4, '2022-11-01', 'Monday', '10:30', 2),
    (4, '2022-11-09', 'Saturday', '15:50', 1),
    (4, '2022-11-09', 'Saturday', '19:30', 2),
    (4, '2022-11-25', 'Friday', '11:20', 1),
    (4, '2022-11-25', 'Friday', '18:45', 2),

    (6, '2022-11-25', 'Friday', '7:30', 1),
    (6, '2022-11-25', 'Friday', '18:45', 2),

    (5, '2022-11-25', 'Friday', '7:45', 1),
    (5, '2022-11-25', 'Friday', '18:45', 2),
   
    (5, '2022-12-17', 'Saturday', '7:45', 1),
    (2, '2022-12-17', 'Saturday', '6:45', 1);
   
   
   

DROP FUNCTION statistics_late(date);
CREATE OR REPLACE FUNCTION statistics_late(today DATE)
RETURNS TABLE (late_ret numeric, num_ret bigint) AS
$$
BEGIN
    RETURN QUERY
    SELECT late, count(*) AS num
           FROM (SELECT worker_id, extract(epoch from (min(time_value) - '09:00:00')) / 60 AS late
                 FROM timetable t
                 WHERE dt = today AND action_type = 1
                 GROUP BY worker_id
                 HAVING min(time_value) > '09:00:00') AS foo
            GROUP BY late;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM statistics_late('2022-11-09');



select distinct department 
from workers w 
where department not in 
(select distinct department 
from workers
where date_part('year', age(birthdate)) < 25)


with first as (
	select distinct on (dt, time_in) worker_id, dt, min(time_value) OVER (PARTITION BY worker_id, dt) as time_in
	from timetable
	where action_type = 1)
select workers.id, workers.fio, time_in
from first join workers on first.worker_id = workers.id
where dt = CURRENT_DATE and time_in =
                (select min(time_in)
				 from first
				 where dt = CURRENT_DATE)
				 
				 
				 
select id , fio, count(first.worker_id)
from (select distinct on (worker_id , dt, time_in) worker_id, dt, min(time_value) OVER (PARTITION BY worker_id, dt) as time_in
	from timetable
	where action_type = 1 ) as first join workers on first.worker_id = workers.id
where time_in > '09:00:00'
group by id, fio
having count(first.worker_id) >= 5;


