from faker import *
from random import choice, randint, randrange, uniform
from datetime import date

GENRES = ['Documentary', 'Thriller', 'Mystery', 'Horror', 'Action', 'Comedy', 'Drama', 'Romance', 'Anime',
'Biographical', 'Western', 'Military', 'Detective', 'Children', 'Historical', 'Film Comic', 'Crime', 'Melodrama',
'Music', 'Cartoon', 'Musical', 'Science', 'Noir', 'Adventure', 'Reality Show', 'Family', 'Sports', 'Talk Show',
'Science fiction', 'Fantasy', 'Erotica']

FILMS_FILE = "data/films.csv"
DIRECTORS_FILE = "data/directors.csv"
ACTORS_FILE = "data/actors.csv"
COMPANIES_FILE = "data/companies.csv"
GENRES_FILE = "data/genres.csv"
FILMS_GENRES_FILE = "data/films_genres.csv"
FILMS_ACTORS_FILE = "data/films_actors.csv"
FILMS_SCREENWRITERS_FILE = "data/films_screenwriters.csv"
SCREENWRITERS_FILE = "data/screenwriters.csv"

MIN_DURATION = 50
MAX_DURATION = 150

COUNT_RECORDS = 1000

def capitalize(str):
    return str.capitalize()

def generate_films():

    file = open(FILMS_FILE, "w")
    
    faker = Faker()

    for _ in range(COUNT_RECORDS):

        words = faker.words()
        capitalized_words = list(map(capitalize, words))
        title = ' '.join(capitalized_words)

        year = faker.year()

        company = randint(1, 1000)

        director = randint(1, 1000)

        duration = randrange(MIN_DURATION, MAX_DURATION)

        rating = round(uniform(1.0, 10.0), 1)

        line = "{0},{1},{2},{3},{4},{5}\n".format(title, year, company, director, duration, rating)
        file.write(line)
    
    file.close()

    print("Table of films created")


def generate_directors():

    faker = Faker()

    file = open(DIRECTORS_FILE, "w")

    for _ in range(COUNT_RECORDS):

        gender = choice(["male", "female"])

        name = faker.name_male() if gender == "male" else faker.name_female()

        birth_date = faker.date_of_birth(minimum_age = 25, maximum_age=150)

        death_date = str(faker.date_between_dates(birth_date, date.today())) if birth_date.year < 1922 else ""

        line = "{0},{1},{2},{3}\n".format(gender, name, str(birth_date), death_date)
        file.write(line)
    
    file.close()

    print("Table of directors created")


def generate_actors():

    faker = Faker()

    file = open(ACTORS_FILE, "w")

    for _ in range(COUNT_RECORDS):

        gender = choice(["male", "female"])

        name = faker.name_male() if gender == "male" else faker.name_female()

        birth_date = faker.date_of_birth(minimum_age = 25, maximum_age=150)

        death_date = str(faker.date_between_dates(birth_date, date.today())) if birth_date.year < 1922 else ""

        line = "{0},{1},{2},{3}\n".format(gender, name, str(birth_date), death_date)
        file.write(line)
    
    file.close()

    print("Table of actors created")

def generate_screenwriters():

    faker = Faker()

    file = open(SCREENWRITERS_FILE, "w")

    for _ in range(COUNT_RECORDS):

        gender = choice(["male", "female"])

        name = faker.name_male() if gender == "male" else faker.name_female()

        genre = choice(GENRES)

        birth_date = faker.date_of_birth(minimum_age = 25, maximum_age=150)

        line = "{0},{1},{2},{3}\n".format(gender, name, str(birth_date), genre)
        file.write(line)
    
    file.close()

    print("Table of screenwriters created")

def generate_companies():

    faker = Faker()

    file = open(COMPANIES_FILE, "w")

    for _ in range(COUNT_RECORDS):
        name = faker.unique.company()
        country = faker.country()
        director = faker.name()
        rating = round(uniform(1.0, 10.0), 1)
        year = faker.year()

        line = "{0};{1};{2};{3};{4}\n".format(name, country, director, rating, year)
        file.write(line)
    
    file.close()

    print("Table of companies created")

def generate_genres():

    file = open(GENRES_FILE, "w")

    faker = Faker()

    for i in range(len(GENRES)):
        name = GENRES[i]

        description = faker.paragraph(variable_nb_sentences=False)

        line = "{0},{1}\n".format(name, description)
        file.write(line)
    
    file.close()

    print("Table of genres created")
    
def generate_films_genres():

    file = open(FILMS_GENRES_FILE, "w")

    for film_id in range(COUNT_RECORDS):
        count_genres = randint(1, 4)
        for _ in range(count_genres):
            genre_id = randint(1, len(GENRES))
            line = "{0},{1}\n".format(film_id + 1, genre_id)
            file.write(line)
    
    file.close()

    print("Table of films and genres created")

def generate_films_actors():

    file = open(FILMS_ACTORS_FILE, "w")

    for film_id in range(COUNT_RECORDS):
        count_actors = randint(10, 150)
        for _ in range(count_actors):
            actor_id = randint(1, COUNT_RECORDS)
            line = "{0},{1}\n".format(film_id + 1, actor_id)
            file.write(line)
    
    file.close()

    print("Table of films and actors created\n")

def generate_films_screenwriters():

    file = open(FILMS_SCREENWRITERS_FILE, "w")

    for film_id in range(COUNT_RECORDS):
        count_screenwriters = randint(2, 20)
        for _ in range(count_screenwriters):
            screenwriter_id = randint(1, COUNT_RECORDS)
            line = "{0},{1}\n".format(film_id + 1, screenwriter_id)
            file.write(line)
    
    file.close()

    print("Table of films and screenwriters created\n")

if __name__ == "__main__":
    # generate_films()
    # generate_directors()
    # generate_actors()
    # generate_companies()
    # generate_genres()
    # generate_films_genres()
    # generate_films_actors()
    generate_screenwriters()
    generate_films_screenwriters()
