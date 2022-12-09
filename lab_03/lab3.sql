-- Functions
-- 1
DROP FUNCTION IF EXISTS count_actors_in_film(int);
CREATE OR REPLACE FUNCTION count_actors_in_film(film_id_param int) RETURNS int AS $$
BEGIN
	RETURN(SELECT count(*)
		   FROM films f
		   JOIN films_actors f_a ON f.id=f_a.film_id
		   WHERE f.id=film_id_param);
END;
$$ LANGUAGE plpgsql;

SELECT count_actors_in_film(1);

-- 2
DROP FUNCTION IF EXISTS count_films_by_director();
CREATE OR REPLACE FUNCTION count_films_by_director()
RETURNS TABLE (id int, director varchar, count_films bigint) AS $$
BEGIN
	RETURN QUERY
	SELECT d.id, name, count(*) AS count_films
	FROM directors d
	JOIN films f ON d.id=f.director GROUP BY d.id, name;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM count_films_by_director();

-- 3
DROP FUNCTION IF EXISTS update_rating(int, numeric);
CREATE OR REPLACE FUNCTION update_rating(f_id int, new_rating numeric) 
RETURNS TABLE (id int, title varchar, 
               year int, company int, 
               director int, duration int, rating numeric) AS $$
BEGIN
	UPDATE films f
	SET rating = new_rating
	WHERE f.id = f_id;

	RETURN QUERY
	SELECT *
	FROM films;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM update_rating(1, 3.9);

-- 4
DROP FUNCTION IF EXISTS fib(int, int, int);
CREATE OR REPLACE FUNCTION fib(first int, second int, max int)
RETURNS TABLE (fibonacci int)
AS $$
BEGIN
    RETURN QUERY
    SELECT first;
    IF second <= max THEN
        RETURN QUERY
        SELECT *
        FROM fib(second, first + second, max);
    END IF;
END $$ LANGUAGE plpgsql;

SELECT *
FROM fib(1, 1, 100);


-- Procedures
-- 1
CREATE OR REPLACE PROCEDURE set_death_date(_id int, _death_date date)
AS $$
BEGIN
	UPDATE directors
    SET death_date = _death_date
    WHERE id = _id;
END;
$$ LANGUAGE plpgsql;

CALL set_death_date(2, '2022-10-18');
SELECT * FROM directors
WHERE id = 2;

-- 2
CREATE OR REPLACE PROCEDURE fib_index
(
	res INOUT int,
	index_ int,
	start_ int DEFAULT 1, 
	end_ int DEFAULT 1
)
AS $$
BEGIN
	IF index_ > 0 THEN
		res = start_ + end_;
		CALL fib_index(res, index_ - 1, end_, start_ + end_);
	END IF;
END; 
$$ LANGUAGE plpgsql;

CALL fib_index(1, 7);

-- 3
CREATE OR REPLACE PROCEDURE get_leaders(top int, bottom int) AS $$
DECLARE
    curs CURSOR FOR SELECT * 
                    FROM films;

    cur_film RECORD; 

BEGIN
    RAISE NOTICE 'List of leaders:';
    OPEN curs;
    LOOP 
        FETCH curs INTO cur_film;
		EXIT WHEN NOT FOUND;

        IF cur_film.rating BETWEEN top AND bottom THEN
            RAISE NOTICE '%', cur_film.title;
        END IF;

    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;

CALL get_leaders(8, 10);

SELECT *
FROM films
WHERE RATING BETWEEN 8 AND 10;

-- 4
CREATE OR REPLACE PROCEDURE indexes(db_name VARCHAR, table_name VARCHAR) 
AS
$$
DECLARE
	now_record RECORD;
BEGIN
    SELECT *
    FROM pg_indexes
    WHERE tablename = table_name
    INTO now_record;

    RAISE NOTICE 'INFO: tablename %, indexname %, indexdef %',
	now_record.tablename, now_record.indexname, now_record.indexdef;
END;
$$ LANGUAGE plpgsql;

CALL indexes('postgres', 'films');

SELECT *
FROM pg_indexes;

-- Triggers
-- 1
CREATE OR REPLACE FUNCTION write_to_log()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
    	RAISE NOTICE 'INSERT: NEW: %', NEW;
        RETURN NEW;
    ELSEIF TG_OP = 'UPDATE' THEN
    	RAISE NOTICE 'UPDATE:';
    	RAISE NOTICE 'OLD: %', OLD;
        RAISE NOTICE 'NEW: %', NEW;
        RETURN NEW;
    ELSEIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'DELETE: OLD: %', OLD;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_trigger
AFTER INSERT OR UPDATE OR DELETE ON films
FOR EACH ROW
EXECUTE PROCEDURE write_to_log();

INSERT INTO films (title, YEAR, company, director, duration, rating)
VALUES ('Jhbjhc sjhdcb jcb', 1999, 3, 3, 100, 4);

-- 2
CREATE VIEW films_view AS 
SELECT *
FROM films f;

CREATE OR REPLACE FUNCTION del_film()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'NEW =  %', NEW;
    UPDATE films
    SET title = 'DELETED' 
    WHERE title = OLD.title;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER del_packages_trigger
INSTEAD OF DELETE ON films_view
	FOR EACH ROW 
	EXECUTE PROCEDURE del_film();

INSERT INTO films (title, YEAR, company, director, duration, rating)
VALUES ('aaa', 1999, 3, 3, 100, 4);

DELETE FROM films_view  
WHERE title = 'aaa';

SELECT * FROM films;




