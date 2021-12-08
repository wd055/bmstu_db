from sys import path
import psycopg2
from decouple import config

connection = None


def print_result(result):
    print("\nРезультат:")
    for row in result:
        for field in row:
            print(" ", field, end=" ")
        print()


def get_competition(cursor):
    id = int(input("Введите идентификатор сореванония: "))

    query = """ SELECT id, title
                FROM competition
                WHERE id = %s;"""
    cursor.execute(query, (str(id),))
    result = cursor.fetchall()
    print_result(result)


def select_brand(cursor):
    id = input("Введите идентификатор школы: ")

    query = """SELECT DISTINCT c.id, j.id, prJ.*
                FROM lab_01.public.competition c
                JOIN participant p on c.id = p.competition
                JOIN lab_01.public.profile pr on p.profile = pr.id
                JOIN lab_01.public.judge j on c.id = j.competition
                JOIN lab_01.public.profile prJ on j.profile = prJ.id
                WHERE pr.school in (%s)"""
    cursor.execute(query, (id,))
    result = cursor.fetchall()
    print_result(result)


def max_participant_score(cursor):
    query = """WITH Score_sum (sum, participant) AS (
                SELECT sum(score) as sm, participant
                FROM Score
                GROUP BY Score.participant, Score.competition
            )
            SELECT AVG(sum), participant
            FROM Score_sum as smT
            GROUP BY participant;"""
    cursor.execute(query)
    result = cursor.fetchall()
    print_result(result)


def get_tables(cursor):
    query = """SELECT datname
                FROM pg_stat_database;"""
    cursor.execute(query)
    result = cursor.fetchall()
    print_result(result)


def avg_score(cursor):
    id = input("Введите идентификатор соревнования: ")
    query = """SELECT * FROM avgScore(%s);"""
    cursor.execute(query, (id,))
    result = cursor.fetchall()
    print_result(result)


def participant_sum(cursor):
    id = input("Введите идентификатор соревнования: ")
    query = """SELECT * FROM sumIncrementParticipantScoreTable(%s);"""
    cursor.execute(query, (id,))
    result = cursor.fetchall()
    print_result(result)


def change_score(cursor):
    id = input("Введите идентификатор соревнования: ")
    count = input("Введите изменение оценки: ")
    query = """CALL updateScore(%s, %s);"""
    cursor.execute(query, (id, count))
    print("Оценка успешно обновлена.\n")


def current_bd_user(cursor):
    query = """SELECT current_database(), current_user;"""
    cursor.execute(query)
    result = cursor.fetchall()
    print_result(result)


def create_music_table(cursor):
    try:
        query = """DROP TABLE IF EXISTS music;
                CREATE TABLE music(
                    id SERIAL PRIMARY KEY,
                    url varchar(256),
                    participant int NOT NULL,
                    create_date timestamp DEFAULT NOW(),
                    FOREIGN KEY (participant) REFERENCES Participant (id)
                );"""
        cursor.execute(query)
        connection.commit()
        print("Запрос выполнен успешно.")
    except BaseException:
        print("Не удалось создать таблицу.")


def insert_courier(connection, cursor):
    url = input("Введите url: ")
    participant = input("Введите идентификатор участницы: ")
    try:
        query = """INSERT INTO music(url, participant)
                VALUES(%s, %s);"""
        cursor.execute(query, (url, participant))
        connection.commit()
        print("Запрос выполнен успешно.")
    except BaseException:
        print("Не удалось выполнить запрос.")


def menu():
    print("Выберите команду:\n\
    0. Выйти;\n\
    1. Вывести конкретное соревнование;\n\
    2. Имена всех судей, которые судили соревнования, в которых участвовали конкретная школа;\n\
    3. Средняя оценка участниц;\n\
    4. Имена всех БД;\n\
    5. Средний балл за соревнование;\n\
    6. Инкремент оценок в соревновании и сумма результатов в сореванований;\n\
    7. Изменить все оценки в соревновании;\n\
    8. Получить текущую БД и Пользователя;\n\
    9. Создать таблицу музыки;\n\
    10. Добавить песню;\n")


try:
    connection = psycopg2.connect(user=config("DB_USER"),
                                  password=config("DB_PASSWORD"),
                                  host=config("DB_HOST"),
                                  port=config("DB_PORT"),
                                  database=config("DB_DATABASE"))
    connection.autocommit = True

    cursor = connection.cursor()

    flag = True

    while flag:
        menu()
        cmd = input()

        if cmd == "0":
            flag = False
        elif cmd == "1":
            get_competition(cursor)
        elif cmd == "2":
            select_brand(cursor)
        elif cmd == "3":
            max_participant_score(cursor)
        elif cmd == "4":
            get_tables(cursor)
        elif cmd == "5":
            avg_score(cursor)
        elif cmd == "6":
            participant_sum(cursor)
        elif cmd == "7":
            change_score(cursor)
        elif cmd == "8":
            current_bd_user(cursor)
        elif cmd == "9":
            create_music_table(cursor)
        elif cmd == "10":
            insert_courier(connection, cursor)
        else:
            print("Ты шо ввёл!?\n")


except Exception as _ex:
    print("[INFO] Error while working with PostgreSQL", _ex)
finally:
    if connection:
        cursor.close()
        connection.close()
        print("[INFO] PostgreSQL connection closed")
