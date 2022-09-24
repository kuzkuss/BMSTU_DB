COPY companies(name, country, director, rating, year)
FROM '/home/anastasia/BMSTU_BD/lab_01/data/companies.csv' DELIMITER ';' NULL '';

COPY directors(gender, name, birth_date, death_date)
FROM '/home/anastasia/BMSTU_BD/lab_01/data/directors.csv' DELIMITER ',' NULL '';

COPY films(title, year, company, director, duration, rating)
FROM '/home/anastasia/BMSTU_BD/lab_01/data/films.csv' DELIMITER ',' NULL '';

COPY actors(gender,	name, birth_date, death_date)
FROM '/home/anastasia/BMSTU_BD/lab_01/data/actors.csv' DELIMITER ',' NULL '';

COPY genres(name, description)
FROM '/home/anastasia/BMSTU_BD/lab_01/data/genres.csv' DELIMITER ',' NULL '';

COPY films_genres(film_id, genre_id)
FROM '/home/anastasia/BMSTU_BD/lab_01/data/films_genres.csv' DELIMITER ',' NULL '';

COPY films_actors(film_id, actor_id)
FROM '/home/anastasia/BMSTU_BD/lab_01/data/actors.csv' DELIMITER ',' NULL '';

