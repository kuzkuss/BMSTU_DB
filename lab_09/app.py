from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
import json
from views import get_top_films, delete_last_film, add_film, change_film, get_top_films_cache
from compare_tests import benchmark
import db_connection
import redis

cfg = json.load(open("./config.json"))
DB_INFO = cfg['db']

engine = create_engine(
    f'postgresql://{DB_INFO["user"]}:{DB_INFO["password"]}@{DB_INFO["host"]}:{DB_INFO["port"]}',
    pool_pre_ping=True)

r = redis.Redis()

Session = sessionmaker(bind=engine)

QUERIES = {
    1: get_top_films,
    2: get_top_films_cache,
    3: delete_last_film,
    4: add_film,
    5: change_film,
}


def menu():
    choices = \
        '''
    1 - Получить топ фильмов.
    2 - Получить топ фильмов с кешированием.
    3 - Удалить последний пост.
    4 - Добавить тестовый пост.
    5 - Изменить один из тестовых постов.
    
    
    0 = Выход.
    '''
    print(choices)


def main():
    is_work = True
    connection = db_connection.connect(DB_INFO)
    benchmark(connection, r)
    while is_work:
        menu()
        action = input()
        try:
            action = int(action)
        except:
            print("Invalid input actions. Only nums.")
        else:
            if action == 0:
                print("End of work")
                break
            else:
                if action in QUERIES:
                    session = Session()
                    res = QUERIES[action](connection, r)
                    print(res)
                    session.commit()
                else:
                    print("Error input action")

    connection.close()


if __name__ == "__main__":
    main()

