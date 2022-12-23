from peewee import *
from datetime import *

connect = PostgresqlDatabase(
    database="postgres",
    user="postgres",
    password="postgres",
    host="127.0.0.1",
    port=5432
)

class BaseModel(Model):
    class Meta:
        database = connect


class Workers(BaseModel):
    id = IntegerField(column_name='id')
    fio = CharField(column_name='fio')
    birthdate = DateField(column_name='birthdate')
    department = CharField(column_name='department')

    class Meta:
         table_name = 'workers'


class Timetable(BaseModel):
    worker_id = ForeignKeyField(Workers, backref="worker_id", on_delete="cascade")
    dt = DateField(column_name='dt')
    weekday = CharField(column_name='weekday')
    time_value = TimeField(column_name='time_value')
    action_type = IntegerField(column_name='action_type')

    class Meta:
         table_name = 'timetable'


def task1():

    query_sql = connect.execute_sql("select distinct department \
        from workers w \
        where department not in \
        (select distinct department \
        from workers\
        where date_part('year', age(birthdate)) < 25)")

    for worker in query_sql.fetchall():
        print(worker)

    query = Workers.select(Workers.department).distinct().where(
        Workers.department.not_in(Workers.select(Workers.department).where(
        datetime.now().year - fn.Date_part('year', Workers.birthdate) < 25).distinct()
    ))

    for worker in query.dicts():
        print(worker)

def task2():

    query_sql = connect.execute_sql("with first as (\
	select distinct on (dt, time_in) worker_id, dt, min(time_value) OVER (PARTITION BY worker_id, dt) as time_in from timetable\
	where action_type = 1) \
    select workers.id, workers.fio, time_in \
    from first join workers on first.worker_id = workers.id \
    where dt = CURRENT_DATE and time_in = (select min(time_in) \
	from first \
	where dt = CURRENT_DATE)")

    for worker in query_sql.fetchall():
        print(worker)

    query = Workers\
    .select(Workers.id, Workers.fio, SQL('time_in'))\
    .from_(Timetable\
        .select(fn.Distinct(Timetable.worker_id, Timetable.dt),
                Timetable.worker_id, 
                Timetable.dt, 
                fn.min(Timetable.time_value).over(partition_by=[Timetable.worker_id, Timetable.dt]).alias('time_in'))\
        .where(Timetable.action_type == 1))\
    .join(Workers, on=(Workers.id == SQL('worker_id')))\
    .where(SQL('dt') == date.today())\
    .order_by(SQL('time_in'))\
    .limit(1)

    for worker in query.dicts():
        print(worker)

def task3():

    query_sql = connect.execute_sql("select id , fio, count(first.worker_id) \
    from (select distinct on (worker_id , dt, time_in) worker_id, dt, min(time_value) OVER (PARTITION BY worker_id, dt) as time_in \
	from timetable \
	where action_type = 1 ) as first join workers on first.worker_id = workers.id \
    where time_in > '09:00:00' \
    group by id, fio \
    having count(first.worker_id) >= 5")


    for worker in query_sql.fetchall():
        print(worker)

    query = Workers\
    .select(Workers.id, Workers.fio, fn.count(SQL('worker_id')))\
    .from_(Timetable.select(fn.Distinct(Timetable.worker_id, Timetable.dt),
                Timetable.worker_id, 
                Timetable.dt, 
                fn.min(Timetable.time_value).over(partition_by=[Timetable.worker_id, Timetable.dt]).alias('time_in'))\
        .where(Timetable.action_type == 1))\
    .join(Workers, on=(Workers.id == SQL('worker_id')))\
    .where(SQL('time_in') > '09:00:00')\
    .group_by(Workers.id, Workers.fio)\
    .having(fn.count(SQL('worker_id')) >= 5)

    for worker in query.dicts():
        print(worker)

def main():
    print("\nQUERY 1")
    task1()

    print("\nQUERY 2")
    task2()

    print("\nQUERY 3")
    task3()


if __name__ == "__main__":
    main()

