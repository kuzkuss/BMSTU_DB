CREATE TABLE IF NOT EXISTS films (
    id serial PRIMARY KEY,
	title varchar(64) NOT NULL,
	year int NOT NULL,
	company int NOT NULL REFERENCES companies(id),
	director int NOT NULL REFERENCES directors(id),
	duration int NOT NULL,
	rating NUMERIC(3,1) NOT NULL
);

CREATE TABLE IF NOT EXISTS actors (
    id serial PRIMARY KEY,
	gender varchar(6) NOT NULL,
	name varchar(32) NOT NULL, 
	birth_date DATE NOT NULL,
	death_date DATE
);

CREATE TABLE IF NOT EXISTS screenwriters (
    id serial PRIMARY KEY,
	gender varchar(6) NOT NULL,
	name varchar(32) NOT NULL, 
	birth_date DATE NOT NULL,
	genre varchar(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS directors (
    id serial PRIMARY KEY,
	gender varchar(6) NOT NULL,
	name varchar(32) NOT NULL,
	birth_date DATE NOT NULL,
	death_date DATE
);

CREATE TABLE IF NOT EXISTS companies (
	id serial PRIMARY KEY,
    name varchar(64),
	country varchar(64) NOT NULL,
	director varchar(32) NOT NULL,
	rating NUMERIC(3,1),
	year int NOT NULL
);

CREATE TABLE IF NOT EXISTS genres (
    id serial PRIMARY KEY,
	name varchar(32) NOT NULL,
	description TEXT
);

CREATE TABLE IF NOT EXISTS films_genres (
    film_id int NOT NULL REFERENCES films(id),
	genre_id int NOT NULL REFERENCES genres(id)
);


CREATE TABLE IF NOT EXISTS films_actors (
	film_id int NOT NULL REFERENCES films(id),
	actor_id int NOT NULL REFERENCES actors(id)
);

