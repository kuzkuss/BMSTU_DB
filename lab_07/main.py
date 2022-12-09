import psycopg2
from py_linq import *
import json
from peewee import *

db_name = 'postgres'
db_user = 'postgres'
ds_pass = 'postgres'
db_host = 'localhost'
db_port = '8080'

def start_connection():
    try:
        connection = psycopg2.connect(
            database=db_name,
            user=db_user,
            password=ds_pass,
            host=db_host,
            port=db_port,
        )
        return connection
    except Exception as e:
        print(f'Error occurred: {e}')


def stop_task(connection, cursor):
    connection.close()
    cursor.close()

class Films():
    id = int()
    title = str()
    year = int()
    company = int()
    director = int()
    duration = int()
    rating = float()

    def __init__(self, id, title, year, company, director, duration, rating):
        self.id = id
        self.title = title
        self.year = year
        self.company = company
        self.director = director
        self.duration = duration
        self.rating = rating

    def get(self):
        return {'id': self.id, 'title': self.title, 'year': self.year,
                'company': self.company, 'director': self.director,
                'duration': self.duration, 'rating': self.rating}

    def __str__(self):
        return f"{self.id:<5} {self.title:<30} {self.year:<5} " \
               f"{self.company:<5} {self.director:<5}" \
               f"{self.duration:<5} {self.rating:<5}"

class Director():
    id = int()
    gender = str()
    name = str()

    def __init__(self, id, gender, name):
        self.id = id
        self.gender = gender
        self.name = name

    def get(self):
        return {'id': self.id, 'gender': self.gender, 'name': self.name}

    def __str__(self):
        return f"{self.id:<5} {self.gender:<20} {self.name:<30}"


def create_film(file_name):
    file = open(file_name, 'r')
    films = list()

    count = 0
    for line in file:
        arr = line.split(';')

        result = [count, arr[0], int(arr[1]), int(arr[2]), arr[3], arr[4], float(arr[5])]
        count += 1
        films.append(Films(*result).get())

    return films


def create_director(file_name):
    file = open(file_name, 'r')
    directors = list()
    count = 0
    for line in file:
        arr = line.split(';')

        result = [count, arr[0], arr[1]]
        count += 1
        directors.append(Director(*result).get())

    return directors


def request_1(films):
	result = films.where(lambda x: x['rating'] > 3).order_by(lambda x: x['rating']).select(
		lambda x: {x['title'], x['year'], x['rating']})
	return result


def request_2(films):
	result = Enumerable([({films.count(lambda x: x['title'][0] == 'A')})])
	return result


def request_3(films):
	result = Enumerable([{films.min(lambda x: x['rating']), films.max(lambda x: x['rating'])}])
	return result


def request_4(films):
	result = films.group_by(key_names=['director'], key=lambda x: x['director']).\
		select(lambda g: {'Director id': g.key.director, 'Count of fields': g.count()})
	return result


def request_5(films, directors):
	result = films.join(films, lambda s: s['id'], lambda c: c['director'])
	return result


def print_first_requests(request, count=5):
	for i in range(0, count):
		if not request[i]:
			break
		print(request[i])

def task_1():
    films = Enumerable(create_film('csv/films.csv'))
    directors = Enumerable(create_director('csv/directors.csv'))

    print('\n1. Films with rating more than 1:')
    print_first_requests(request_1(films))

    print('\n2. Count of films which title begins with the letter A:')
    print_first_requests(request_2(films))

    print('\n3. Maximum and minimum film rating:')
    print_first_requests(request_3(films))

    print('\n4.Group by director:')
    print_first_requests(request_4(films))

    print('\n5. Join a film and a director:\n')
    print_first_requests(request_5(films, directors))

def read_table_json(cursor, count=5):
    cursor.execute("select * from films_json")

    rows = cursor.fetchmany(count)
    array = list()
    for elem in rows:
        array.append(Films(elem[0]['id'], elem[0]['title'], elem[0]['year'], elem[0]['company'],
            elem[0]['director'], elem[0]['duration'], elem[0]['rating']))

    print(f"{'id':<5} {'title':<30} {'year':<5} " \
               f"{'company':<8} {'director':<10}" \
               f"{'duration':<10} {'rating':<10}")
    print(*array, sep='\n')

    return array


def output_json(array):
    for elem in array:
        print(json.dumps(elem.get()))


def update_films(films, current_id, new_id):
    for elem in films:
        if elem.director == current_id:
            elem.director = new_id
    output_json(films)


def add_film(films, new_film):
    films.append(new_film)
    output_json(films)


def task_2():
    connection = start_connection()
    cursor = connection.cursor()

    print("1. Read from JSON:")
    films_array = read_table_json(cursor)

    print("\n2. Update JSON:")
    current_id = int(input("Input current durector id: "))
    new_id = int(input("Input new director id: "))
    update_films(films_array, current_id, new_id)

    print("\n3. Write to JSON:")
    title = input("Film title: ")
    year = int(input("Year: "))
    company_id = int(input("Company id (1-999): "))
    director_id = int(input("Director id (1-999): "))
    duration = int(input("Duration: "))
    rating = float(input("Rating: "))
    add_film(films_array, Films(15, title, year, company_id, director_id, duration, rating))

    stop_task(connection, cursor)

con = PostgresqlDatabase(
    database=db_name,
    user=db_user,
    password=ds_pass,
    host=db_host,
    port=db_port,
)

class BaseModel(Model):
    class Meta:
        database = con

class FilmsSql(BaseModel):
    id = PrimaryKeyField(column_name='id')
    title = CharField(column_name='title')
    year = IntegerField(column_name='year')
    company = IntegerField(column_name='company')
    director = IntegerField(column_name='director')
    duration = IntegerField(column_name='duration')
    rating = FloatField(column_name='rating')

    class Meta:
        table_name = 'films'


class DirectorsSql(BaseModel):
    id = PrimaryKeyField(column_name='id')
    name = CharField(column_name='name')

    class Meta:
        table_name = 'directors'

def query_1():
    print("\nQuery 1:")

    query = FilmsSql.select(FilmsSql.id, FilmsSql.title, FilmsSql.year).\
        limit(5).order_by(FilmsSql.rating.desc()).where(FilmsSql.rating > 3.0)

    print("Films with rating > 3.0:")
    for elem in query.dicts().execute():
        print(elem)

def query_2():
    print("\nQuery 2:")

    print("Join directors and films:")
    query = FilmsSql.select(FilmsSql.id, FilmsSql.title, DirectorsSql.name).join(DirectorsSql, on=(
                FilmsSql.director == DirectorsSql.id)).limit(5)

    for elem in query.dicts().execute():
        print(elem)

def update_title(id, new_title):
    film = FilmsSql.get(id=id)
    film.title = new_title
    film.save()
    print(">> Updated")

def del_film(id):
    try:
        films = FilmsSql.get(id=id)
        films.delete_instance()
        print(">> Deleted")
    except:
        print(">> Record does not exist")


def query_3():
    print("\nQuery 3:")
    print_last_five_fields()

    print("Add film:")
    FilmsSql.create(title="title", year=2022, company=1, director=1, duration=150, rating=5.0)
    print(">> Added")

    print_last_five_fields()

    print("Update film:")
    update_title(5015, 'aaa')
    print_last_five_fields()

    print("Delete film:")
    del_film(5015)
    print_last_five_fields()


def query_4():
    cursor = con.cursor()

    print("\nQuery 4:")
    print_last_five_fields_on_duration_desc()

    print("Set death date:")
    cursor.execute("call set_death_date(2, '2022-10-18')")
    con.commit()

    print_last_five_fields_on_duration_desc()
    print(">> Procedure is completed")
    cursor.close()


def print_last_five_fields():
    query = FilmsSql.select().limit(5).order_by(FilmsSql.id.desc())
    for elem in query.dicts().execute():
        print(elem)
    print()


def print_last_five_fields_on_duration_desc():
    query = DirectorsSql.select(DirectorsSql.id, DirectorsSql.name).limit(5).order_by(DirectorsSql.id.desc())
    for elem in query.dicts().execute():
        print(elem)
    print()


def task_3():
    global con

    query_1()
    query_2()
    query_3()
    query_4()

    con.close()


MENU = """
0. Exit
1. Task 1
2. Task 2
3. Task 3
"""

def get_action(action_number: int):
    if action_number == 0:
        return exit(0)
    elif action_number == 1:
        return task_1()
    elif action_number == 2:
        return task_2()
    elif action_number == 3:
        return task_3()
    else:
        print('Please repeat')


def main():
    while True:
        print(MENU)
        try:
            selected = int(input(">> "))
            get_action(selected)
        except Exception as e:
            print(f'Error occurred: {e}')


if __name__ == "__main__":
    main()

