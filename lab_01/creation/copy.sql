COPY companies(name, country, director, rating, year)
FROM '/home/data/companies.csv' DELIMITER ';' NULL '';

COPY directors(gender, name, birth_date, death_date)
FROM '/home/data/directors.csv' DELIMITER ';' NULL '';

COPY films(title, year, company, director, duration, rating)
FROM '/home/data/films.csv' DELIMITER ';' NULL '';

COPY actors(gender,	name, birth_date, death_date)
FROM '/home/data/actors.csv' DELIMITER ';' NULL '';

COPY screenwriters(gender, name, birth_date, genre)
FROM '/home/data/screenwriters.csv' DELIMITER ';' NULL '';

COPY genres(name, description)
FROM '/home/data/genres.csv' DELIMITER ';' NULL '';

COPY films_genres(film_id, genre_id)
FROM '/home/data/films_genres.csv' DELIMITER ';' NULL '';

COPY films_actors(film_id, actor_id)
FROM '/home/data/films_actors.csv' DELIMITER ';' NULL '';

COPY films_screenwriters(film_id, screenwriter_id)
FROM '/home/data/films_screenwriters.csv' DELIMITER ';' NULL '';

