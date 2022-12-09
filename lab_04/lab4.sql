CREATE EXTENSION plpython3u;

--Скалярная функция
--Получить страну компании
DROP FUNCTION IF EXISTS get_county(int);
CREATE OR REPLACE FUNCTION get_county(company_id_param int)
RETURNS VARCHAR AS
$$
    query = '''
            SELECT country
            FROM companies
            WHERE id = '%d'
            ''' % (company_id_param)
    
    result = plpy.execute(query)

    return result[0]['country']

$$ LANGUAGE plpython3u;

SELECT get_county(1);

--Агрегатная функция
--Количество актеров в фильме
DROP FUNCTION IF EXISTS count_actors_in_film_clr(int);
CREATE OR REPLACE FUNCTION count_actors_in_film_clr(film_id_param int) RETURNS int AS $$
	query = '''
        	SELECT count(*) as cnt
		    FROM films f
		    JOIN films_actors f_a ON f.id = f_a.film_id
		    WHERE f.id = '%d'
        	''' % (film_id_param)
        	
	result = plpy.execute(query)
	
	if result is not None:
		return result[0]['cnt']
		
$$ LANGUAGE plpython3u;

SELECT count_actors_in_film_clr(1);

SELECT title, count_actors_in_film_clr(id) AS "actors"
FROM films
GROUP BY id;

--Табличная функция
--Получить информацию о фильмах конкретного директора
DROP FUNCTION IF EXISTS get_films_by_director(int);
CREATE OR REPLACE FUNCTION get_films_by_director(director_id int)
RETURNS TABLE(title VARCHAR, year INTEGER, rating FLOAT)
AS $$
    query = '''
            SELECT title, year, rating
            FROM films JOIN directors ON films.director=directors.id
            WHERE directors.id = '%d'
            ''' % (director_id)
    
    result = plpy.execute(query)

    result_table = []

    if result is not None:
        for film in result:
        	result_table.append(film)
    
    return result_table

$$ LANGUAGE plpython3u;

SELECT * FROM get_films_by_director(3);

SELECT title, year, rating
            FROM films JOIN directors ON films.director=directors.id
            WHERE directors.id = 3
            
--Хранимая процедура
--Устанавливает дату смерти
CREATE OR REPLACE PROCEDURE set_death_date(_id int, _death_date date)
AS $$
	query = '''
    	UPDATE directors
    	SET death_date = '%s'
    	WHERE id = '%d'
    	''' % (_death_date, _id)

	result = plpy.execute(query)
$$ LANGUAGE plpython3u;

CALL set_death_date(2, '2022-10-18');
SELECT * FROM directors
WHERE id = 2;


--Триггер
--Логирование вставки в таблицу фильмов
CREATE OR REPLACE FUNCTION write_to_log()
RETURNS TRIGGER AS $$
    plpy.notice("Record inserted in table films")
$$ LANGUAGE plpython3u;

CREATE TRIGGER log_trigger
AFTER INSERT ON films
FOR ROW EXECUTE PROCEDURE write_to_log();

INSERT INTO films (title, YEAR, company, director, duration, rating)
VALUES ('Jhbjhc sjhdcb jcb', 1999, 3, 3, 100, 4);

--Триггер
--Вместо удаления фильма по названию название заменяется на DELETED
CREATE OR REPLACE VIEW films_view AS 
SELECT *
FROM films f;

CREATE OR REPLACE FUNCTION del_film()
RETURNS TRIGGER AS $$
	query = '''
    	UPDATE films
    	SET title = 'DELETED'
    	WHERE title = '%s'
    	''' % (TD["old"]["title"])

	result = plpy.execute(query)
$$ LANGUAGE plpython3u;

DROP TRIGGER IF EXISTS delete_trigger ON films_view;
CREATE TRIGGER delete_trigger
INSTEAD OF DELETE ON films_view
FOR EACH ROW 
EXECUTE PROCEDURE del_film();


INSERT INTO films (title, YEAR, company, director, duration, rating)
VALUES ('aaa', 1999, 3, 3, 100, 4);

DELETE FROM films_view  
WHERE title = 'aaa';

SELECT * FROM films_view;

--Пользовательский тип данных
-- Получить информацию о фильме.

CREATE TYPE film_type AS
(
    title VARCHAR,
    country VARCHAR,
    company VARCHAR,
    director VARCHAR
);

DROP FUNCTION IF EXISTS get_custom_film(int);
CREATE OR REPLACE FUNCTION get_custom_film(_id_film INTEGER)
RETURNS SETOF film_type AS
$$
	query = '''
        	SELECT f.title, c.country, c.name as company, d.name as director
			FROM films f JOIN companies c ON f.company=c.id
			JOIN directors d ON d.id=f.director
			WHERE f.id='%d'
        	''' % (_id_film)

	result = plpy.execute(query)
	
	if result is not None:
		return result
$$ LANGUAGE plpython3u;

SELECT *
FROM get_custom_film(5);

SELECT f.title, c.country, c.name, d.name
FROM films f
JOIN companies c ON f.company=c.id
JOIN directors d ON d.id=f.director
WHERE f.id=5


