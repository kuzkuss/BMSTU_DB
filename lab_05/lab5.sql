-- 1
COPY (SELECT row_to_json(f)
FROM films AS f)
TO '/home/data/json/films.json';

COPY (SELECT row_to_json(d)
FROM directors AS d)
TO '/home/data/json/directors.json';

COPY
(SELECT row_to_json(s)
FROM screenwriters AS s)
TO '/home/data/json/screenwriters.json';

COPY
(SELECT row_to_json(a)
FROM actors AS a)
TO '/home/data/json/actors.json';

COPY
(SELECT row_to_json(c)
FROM companies AS c)
TO '/home/data/json/companies.json';

COPY (SELECT row_to_json(g)
FROM genres AS g)
TO '/home/data/json/genres.json';

COPY (SELECT row_to_json(f_a)
FROM films_actors AS f_a)
TO '/home/data/json/films_actors.json';

COPY (SELECT row_to_json(f_g)
FROM films_genres AS f_g)
TO '/home/data/json/films_genres.json';

COPY (SELECT row_to_json(f_s)
FROM films_screenwriters AS f_s)
TO '/home/data/json/films_screenwriters.json';

-- 2
CREATE TABLE IF NOT EXISTS films_copy(
	id serial PRIMARY KEY,
	title varchar(64) NOT NULL,
	year int NOT NULL,
	company int NOT NULL REFERENCES companies(id),
	director int NOT NULL REFERENCES directors(id),
	duration int NOT NULL,
	rating NUMERIC(3,1) NOT NULL
);

drop table films_json;
create table if not exists films_json (data json);
copy films_json(data) from '/home/data/json/films.json';

insert into films_copy (title, year, company, director, duration, rating) 
select data->>'title', (data->>'year')::int, (data->>'company')::int, (data->>'director')::int,
(data->>'duration')::int, (data->>'rating')::numeric from films_json;

select * from films_copy;
select * from films;

-- 3
CREATE TABLE IF NOT EXISTS humans (
	id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	name varchar(35) not null,
	address jsonb
);

insert into humans(name, address) 
	values 
	('Kuznetsova Anastasia', '{"town": "N. Novgorod", "street": "Usilova", "house": 1}'),
	('Nikulina Anna', '{"town": "Yaroslavl", "street": "Parkovaya", "house": 4}'),
	('Kosarev Alexey', '{"town": "Balashikha", "street": "Ulyanova", "house": 11}'),
	('Burlakov Ilya', '{"town": "Moscow", "street": "Pervomayskaya", "house": 2}');

select * from humans;

-- 4.1. Извлечь XML/JSON фрагмент из XML/JSON документа
create table if not exists films_json (data json);
copy films_json(data) from '/home/data/json/films.json'; -- выгрузка из файла

select data->'title' title, data->'year' "year" from films_json; -- извлечение json


-- 4.2 Извлечь значения конкретных узлов или атрибутов XML/JSON документа
CREATE TABLE IF NOT EXISTS humans (
	id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	name varchar(35) not null,
	address jsonb
);

insert into humans(name, address) 
	values 
	('Kuznetsova Anastasia', '{"town": "N. Novgorod", "street": "Usilova", "house": 1}'),
	('Nikulina Anna', '{"town": "Yaroslavl", "street": "Parkovaya", "house": 4}'),
	('Kosarev Alexey', '{"town": "Balashikha", "street": "Ulyanova", "house": 11}'),
	('Burlakov Ilya', '{"town": "Moscow", "street": "Pervomayskaya", "house": 2}');

select address->'town' from humans;

-- 4.3 Выполнить проверку существования узла или атрибута

insert into humans(name, address) 
	values 
	('Belokopytov Prokhor', '{"town": "Moscow"}');

CREATE OR REPLACE FUNCTION is_exists(address jsonb, atr VARCHAR)
RETURNS BOOL AS
$$
BEGIN
	RETURN (address->atr) IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

SELECT address->'town' AS town, is_exists(address, 'street') AS is_street_exists
FROM humans;

-- 4.4 Изменить json документ

select * from humans;

update humans
set address = address || '{"postcode": 603093}'
where name = 'Kuznetsova Anastasia';

select * from humans;

--4.5. Разделить XML/JSON документ на несколько строк по узлам

insert into humans (name, address) values ('Ivanov Petr',
'[
 	{"town": "N. Novgorod", "street": "Politboytsov", "house": 10},
	{"town": "N. Novgorod", "street": "Mosckovskaya", "house": 3}
 ]');

select * from humans 
where name = 'Ivanov Petr';

select jsonb_array_elements(address)
from humans 
where name = 'Ivanov Petr';


--Защита
COPY (SELECT row_to_json(f_a) FROM (SELECT f.id, title, count(*) actors FROM films f 
JOIN films_actors fa ON f.id=fa.film_id
JOIN actors a ON fa.actor_id =a.id
GROUP BY f.id, title) AS f_a)
TO '/home/data/json/task.json';

