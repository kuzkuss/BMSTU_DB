--1
SELECT title, year
FROM films
WHERE year>2000;

--2
SELECT title, rating
FROM films
WHERE rating BETWEEN 7 AND 10;

--3
SELECT name, birth_date
FROM directors
WHERE name LIKE 'A%';

--4
SELECT title
FROM films
WHERE company IN (SELECT id
                FROM companies
                WHERE country='France');

--5
SELECT title
FROM films
WHERE EXISTS (SELECT id
            FROM directors
            WHERE death_date IS NULL AND films.director=directors.id);

--6
SELECT title, rating
FROM films f
WHERE rating >= ALL(SELECT rating FROM films WHERE company=f.company);

--7
SELECT name, AVG(duration)
FROM films
JOIN companies ON companies.id=films.company
GROUP BY name;

--8
SELECT name, 
        (SELECT MIN(rating)
        FROM films f
        WHERE f.director=d.id)
FROM directors d;

--9
SELECT title, CASE year
                WHEN 2022 THEN 'this year'
                WHEN 2021 THEN 'last year'
                ELSE CAST(2022 - year AS VARCHAR(5)) || 'years ago'
       		  END AS "When"
FROM films;

--10
SELECT title, CASE
                WHEN duration<100 THEN 'short film'
                ELSE 'long film'
       		  END
FROM films;

--11
CREATE TEMP TABLE IF NOT EXISTS temp_directors AS
SELECT name,
	   (SELECT count(*)
	   FROM films f
	   WHERE f.director=d.id) AS count_films
FROM directors d;

--12
SELECT title, name
FROM films f
JOIN films_genres fg ON fg.film_id=f.id
JOIN (SELECT id, name FROM genres g) ng ON ng.id=fg.genre_id
ORDER BY title;

--13
SELECT *
FROM films f
WHERE company IN (SELECT id
				  FROM companies c
				  WHERE EXISTS(SELECT id
				  			   FROM directors d
				  			   WHERE d.name=c.director AND d.name=(SELECT max(name)
				  												   FROM directors)));

--14
SELECT name, count(f.id) films
FROM films f
RIGHT JOIN companies c ON f.company=c.id
GROUP BY name;

--15
SELECT name, c.rating, count(f.id) films
FROM films f
RIGHT JOIN companies c ON f.company=c.id
GROUP BY name, c.rating
HAVING c.rating>(SELECT avg(rating)
			   FROM companies);

--16
INSERT INTO films (title, year, company, director, duration, rating)
VALUES ('Hello world', 2000, 192, 1, 100, 5);

--17
INSERT INTO films (title, year, company, director, duration, rating)
VALUES ('Hello world', 2000, 192, 1, (SELECT avg(duration)
									  FROM films), 5);

--18
UPDATE films
SET rating=rating*1.1
WHERE id=2003;

--19
UPDATE films
SET rating=(SELECT avg(rating)
			FROM films)
WHERE id=2004;

--20
DELETE FROM films
WHERE id=2003;

--21
DELETE FROM films f
WHERE EXISTS(SELECT id
		     FROM directors d
		     WHERE d.id=f.director AND d.death_date IS NOT NULL);

--22
WITH cte_actors AS (
SELECT f.id, title, count(*) actors FROM films f 
JOIN films_actors fa ON f.id=fa.film_id
JOIN actors a ON fa.actor_id =a.id
GROUP BY f.id, title
)
SELECT avg(actors)
FROM cte_actors;

--23
CREATE TABLE IF NOT EXISTS gamma
(
	id SERIAL PRIMARY KEY,
	next_id INT,
	note VARCHAR(3)
);

INSERT INTO gamma(next_id, note) VALUES
(5, 'do'),
(7, 'fa'),
(6, 'la'),
(2, 'mi'),
(4, 're'),
(NULL, 'si'),
(3, 'sol');

WITH RECURSIVE rcte(id, next_id, note)
AS
(
	SELECT id, next_id, note
	FROM gamma
	WHERE id = 1
	UNION ALL
	SELECT g.id, g.next_id, g.note
	FROM gamma AS g
	JOIN rcte AS r ON r.next_id = g.id
)

SELECT id, next_id, note
FROM rcte;

--24
SELECT DISTINCT name,
		avg(f.year) over(PARTITION BY c.id),
		min(f.year) over(PARTITION BY c.id),
		max(f.year) over(PARTITION BY c.id)
FROM companies c
LEFT JOIN films f ON f.company=c.id;

--25
INSERT INTO films (title, year, company, director, duration, rating)
(SELECT title, year, company, director, duration, rating FROM films);

WITH cte AS (
	SELECT *,
	ROW_NUMBER() over(PARTITION BY title, year, company, director, duration, rating) num
	FROM films
)
SELECT id, title, year, company, director, duration, rating
FROM cte
WHERE num=1;

-- защита: найти фильм, в котором сценарист и жанр фильма не совпадает, сценарист и директор женщина

SELECT title, COUNT(s.name)
FROM films f 
JOIN films_screenwriters f_s ON f.id=f_s.film_id
JOIN screenwriters s ON f_s.screenwriter_id=s.id
JOIN directors d ON f.director=d.id
WHERE s.gender='female' AND d.gender='female'
						AND s.genre NOT IN (SELECT name
											FROM films f2
											JOIN films_genres fg ON f2.id=fg.film_id AND f.id=f2.id
											JOIN genres g ON fg.genre_id=g.id)
						
GROUP BY title;

