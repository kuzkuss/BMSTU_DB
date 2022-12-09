package main

import (
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

type dataBase struct {
	DB *sqlx.DB
}

type FilmJoin struct {
	title string
	genre string
}

type Film struct {
	id int
	title string
	year int
	company int
	director int
	duration int
	rating float64
}

type DirectorFilms struct {
	id int
	name string
	films int
}

type Director struct {
	id int
	gender string
	name string
	birthDate time.Time
	deathDate time.Time
}

type Operator struct {
	id int
	gender string
	name string
	birthDate time.Time
}

func initDB(db *sqlx.DB) *dataBase {
	return &dataBase{DB: db}
}

func (db *dataBase) scalarQuery() error {
	var avg float64
	err := db.DB.QueryRow("SELECT AVG(rating) avg_rating FROM films;").Scan(&avg)

	if err != nil {
		return err
	}

	fmt.Println("RESULT:")
	fmt.Println("avg_rating:", avg)

	return nil
}

func (db *dataBase) multipleJoin() error {
	query := `SELECT title, name AS genre
				FROM films f
				JOIN films_genres fg ON fg.film_id=f.id
				JOIN (SELECT id, name FROM genres g) ng ON ng.id=fg.genre_id
				ORDER BY title;`
	rows, err := db.DB.Query(query)
	if err != nil {
		return err
	}
	defer rows.Close()

	fmt.Println("RESULT:")
	fmt.Println("title     genre")
	for rows.Next() {
		f := new(FilmJoin)
		err := rows.Scan(&f.title, &f.genre)
		if err != nil {
			return err
		}
		fmt.Println(f.title, " ", f.genre)
	}

	return nil
}

func (db *dataBase) cteWindowFunc() error {
	query := `WITH cte AS (
					SELECT *,
					ROW_NUMBER() over(PARTITION BY title, year, company, director, duration, rating) num
					FROM films
				)
				SELECT id, title, year, company, director, duration, rating
				FROM cte
				WHERE num=1;`
	rows, err := db.DB.Query(query)
	if err != nil {
		return err
	}
	defer rows.Close()

	fmt.Println("RESULT:")
	fmt.Println("id     title     year     company     director     duration     rating")
	for rows.Next() {
		f := new(Film)
		err := rows.Scan(&f.id, &f.title, &f.year, &f.company, &f.director, &f.duration, &f.rating)
		if err != nil {
			return err
		}
		fmt.Println(f.id, f.title, f.year, f.company, f.director, f.duration, f.rating)
	}

	return nil
}

func (db *dataBase) metaQuery() error {
	query := `SELECT rolname FROM pg_roles;`
	rows, err := db.DB.Query(query)
	if err != nil {
		return err
	}
	defer rows.Close()

	fmt.Println("RESULT:")
	fmt.Println("roles")
	for rows.Next() {
		var role string
		err := rows.Scan(&role)
		if err != nil {
			return err
		}
		fmt.Println(role)
	}

	return nil
}

func (db *dataBase) scalarFunc() error {
	createFunc := `CREATE OR REPLACE FUNCTION count_actors_in_film(film_id_param int) RETURNS int AS $$
	BEGIN
		RETURN(SELECT count(*)
			   FROM films f
			   JOIN films_actors f_a ON f.id=f_a.film_id
			   WHERE f.id=film_id_param);
	END;
	$$ LANGUAGE plpgsql;`

	_, err := db.DB.Exec(createFunc)
	if err != nil {
		return err
	}

	var actors float64
	err = db.DB.QueryRow("SELECT count_actors_in_film(1);").Scan(&actors)
	if err != nil {
		return err
	}

	fmt.Println("RESULT:")
	fmt.Println("actors: ", actors)

	return nil
}

func (db *dataBase) tableFunc() error {
	createFunc := `DROP FUNCTION IF EXISTS count_films_by_director();
	CREATE OR REPLACE FUNCTION count_films_by_director()
	RETURNS TABLE (id int, director varchar, count_films bigint) AS $$
	BEGIN
		RETURN QUERY
		SELECT d.id, name, count(*) AS count_films
		FROM directors d
		JOIN films f ON d.id=f.director GROUP BY d.id, name;
	END;
	$$ LANGUAGE plpgsql;`

	_, err := db.DB.Exec(createFunc)
	if err != nil {
		return err
	}

	query := `SELECT * FROM count_films_by_director();`
	rows, err := db.DB.Query(query)
	if err != nil {
		return err
	}
	defer rows.Close()

	fmt.Println("RESULT:")
	fmt.Println("id    name   count_films")
	for rows.Next() {
		var director DirectorFilms
		err := rows.Scan(&director.id, &director.name, &director.films)
		if err != nil {
			return err
		}
		fmt.Println(director.id, director.name, director.films)
	}

	return nil
}

func (db *dataBase) storedProc() error {
	createFunc := `CREATE OR REPLACE PROCEDURE set_death_date(_id int, _death_date date)
	AS $$
	BEGIN
		UPDATE directors
		SET death_date = _death_date
		WHERE id = _id;
	END;
	$$ LANGUAGE plpgsql;`

	_, err := db.DB.Exec(createFunc)
	if err != nil {
		return err
	}

	_, err = db.DB.Exec(`CALL set_death_date(2, '2022-10-18');`)
	if err != nil {
		return err
	}

	var director Director
	err = db.DB.QueryRow(`SELECT * FROM directors WHERE id = 2;`).Scan(&director.id,
		&director.gender, &director.name, &director.birthDate, &director.deathDate)
	if err != nil {
		return err
	}

	fmt.Println("RESULT:")
	fmt.Println("id   gender   name   birth_date   death_date")
	fmt.Println(director.id, director.gender, director.name, director.birthDate, director.deathDate)

	return nil
}

func (db *dataBase) systemFunc() error {
	var name string
	err := db.DB.QueryRow("SELECT * FROM current_user;").Scan(&name)

	if err != nil {
		return err
	}

	fmt.Println("RESULT:")
	fmt.Println("current_user:", name)

	return nil
}

func (db *dataBase) createTable() error {
	createTable := `CREATE TABLE IF NOT EXISTS operators(
						id serial PRIMARY KEY,
						gender varchar(6) NOT NULL,
						name varchar(32) NOT NULL, 
						birth_date DATE NOT NULL
					);`

	_, err := db.DB.Exec(createTable)
	if err != nil {
		return err
	}

	return nil
}

func (db *dataBase) insertIntoTable() error {
	_, err := db.DB.Exec(`INSERT INTO operators(gender, name, birth_date)
	VALUES ('female', 'Alisa', '1996-10-19');`)
	if err != nil {
		return err
	}

	var operator Operator
	err = db.DB.QueryRow("SELECT * FROM operators;").Scan(&operator.id,
			&operator.gender, &operator.name, &operator.birthDate)
	if err != nil {
		return err
	}

	fmt.Println("RESULT:")
	fmt.Println("id gender name   birth_date")
	fmt.Println(operator.id, operator.gender, operator.name, operator.birthDate)

	return nil
}

