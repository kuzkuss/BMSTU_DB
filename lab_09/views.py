import datetime

import db_connection, random

CACHE_KEY = "cache"

QUERY_GET_ID_TEST_FILMS = "SELECT id from films where title = 'test film';"

QUERY_TOP_FILMS = "select title from films order by rating desc limit 10;"

QUERY_DELETE_LAST_FILM = "delete from films where id = (select id from films where title = 'test film' order by rating desc limit 1) returning id;"
QUERY_ADD_FILM = "insert into films(title, year, company, director, duration, rating) values ('{}', {}, {}, {}, {}, {}) returning id;"
QUERY_CHANGE_FILM = "update films set title = 'change title' where id = {};"

def get_top_films(connection, r):
    data = "Top Films: "
    cursor = db_connection.execute_query(connection, QUERY_TOP_FILMS)
    if cursor is not None:
        res = cursor.fetchall()
        for film in res:
            data += film[0] + ", "
        data = data.rstrip(", ")

    return data

def get_top_films_cache(connection, r):
    data = "Top Films: "
    redis_cache = r.get(CACHE_KEY)
    if redis_cache is not None:
        print("DATA FROM CACHE")
        return redis_cache.decode("utf-8")
    else:
        cursor = db_connection.execute_query(connection, QUERY_TOP_FILMS)
        if cursor is not None:
            res = cursor.fetchall()
            for film in res:
                data += film[0] + ", "
            data = data.rstrip(", ")

        r.set(CACHE_KEY, data)

        return "NO DATA IN CACHE"


def delete_last_film(connection, r):
    data = "Success deleted film with id = {}"
    res = db_connection.execute_query(connection, QUERY_DELETE_LAST_FILM)
    res = res.fetchall()
    if len(res) == 0:
        return "NO TEST FILMS"
    r.expire(CACHE_KEY, datetime.timedelta(seconds=0))

    return data.format(res[0][0])


def add_film(connection, r):
    data = "Success add film - id = {}"

    query = QUERY_ADD_FILM.format("test film", 2015, random.randint(0, 1000), random.randint(0, 1000), 150, 10)
    res = db_connection.execute_query(connection, query)

    r.expire(CACHE_KEY, datetime.timedelta(seconds=0))

    return data.format(res.fetchall()[0][0])


def change_film(connection, r):
    data = "Success change film with id = {}"
    films_ids = []
    films = db_connection.execute_query(connection, QUERY_GET_ID_TEST_FILMS).fetchall()
    for row in films:
        films_ids.append(row[0])
        
    id = random.randint(0, len(films_ids) - 1)

    res = db_connection.execute_query(connection, QUERY_CHANGE_FILM.format(films_ids[id]))

    r.expire(CACHE_KEY, datetime.timedelta(seconds=0))

    return data.format(films_ids[id])

