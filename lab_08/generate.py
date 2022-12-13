import datetime
from time import sleep
import json
import os
from random import randint, randrange, uniform

from faker import Faker

faker = Faker()

# constants
N = 10
MIN_DURATION = 50
MAX_DURATION = 150
# -------------------------------
counter = 0
date_mask = "%Y-%m-%d-%H.%M.%S"
file_mask = "{}_{}_{}.json"
dir = "./data/"


def gen_filename(tablename):
    global counter
    name = file_mask.format(counter, tablename, datetime.datetime.now().strftime(date_mask))
    return name

def capitalize(str):
    return str.capitalize()

def generate_films(count):
    films = []
    for i in range(count):
        words = faker.words()
        capitalized_words = list(map(capitalize, words))
        title = ' '.join(capitalized_words)

        year = faker.year()

        company = randint(1, 1000)

        director = randint(1, 1000)

        duration = randrange(MIN_DURATION, MAX_DURATION)

        rating = round(uniform(1.0, 10.0), 1)

        film = {
            "title": title,
            "year": year,
            "company": company,
            "director": director,
            "duration": duration,
            "rating": rating,
        }

        films.append(film)
    return json.dumps(films, ensure_ascii=False)


def main():
    global counter
    table = "films"
    if not os.path.exists(dir):
        os.makedirs(dir)
    while True:
        fname = gen_filename(table)
        with open(dir + fname, "w", encoding='utf-8') as file:
            file.write(generate_films(N))
        counter += 1
        sleep(5 * 60)


if __name__ == "__main__":
    main()

