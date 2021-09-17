import psycopg2
from psycopg2 import Error
import random
from decouple import config
import mimesis


def get_id_or_none(count):
    return random.randint(1, count) if count > 0 else None


try:
    connection = psycopg2.connect(user=config("DB_USER"),
                                  password=config("DB_PASSWORD"),
                                  host=config("DB_HOST"),
                                  port=config("DB_PORT"),
                                  database=config("DB_DATABASE"))

    count_profiles = int(input('profiles count:'))
    count_schools = int(input('schools count:'))
    count_competitions = int(input('competitions count:'))
    count_flows = int(input('flows in comp.:'))
    count_participants = 16
    count_scores = 8
    print('participant in flow: {count_participants}'.format(
        count_participants=count_participants))
    print('score by participant: {count_scores}'.format(
        count_scores=count_scores))

    cursor = connection.cursor()
    if count_schools:
        insert_query_user = []
        insert_query_school = []
        for i in range(count_profiles):
            insert_query_user.append("('{username}', '{email}', '{passworad}')".format(
                username=mimesis.Person('en').username(),
                email=mimesis.Person('en').email(),
                passworad=mimesis.Person('en').title()))
            insert_query_school.append("('{user}', '{title}', '{city}', '{address}')".format(
                user=i+1,
                title=mimesis.Person('ru').title(),
                city=mimesis.Address('ru').city(),
                address=mimesis.Address('ru').address(),
            ))

        cursor.execute(
            'INSERT INTO "User" (username, email, password) VALUES ' + (', ').join(insert_query_user))
        connection.commit()
        cursor.execute(
            'INSERT INTO School ("user", title, city, address) VALUES ' + (', ').join(insert_query_school))
        connection.commit()

    if count_profiles:
        insert_query_user = []
        insert_query_profile = []
        for i in range(count_profiles):
            insert_query_user.append("('{username}', '{email}', '{passworad}')".format(
                username=mimesis.Person('en').username(),
                email=mimesis.Person('en').email(),
                passworad=mimesis.Person('en').title()))
            insert_query_profile.append("('{user}', '{first_name}', '{last_name}')".format(
                user=i+1,
                first_name=mimesis.Person('ru').first_name(),
                last_name=mimesis.Person('ru').last_name(),
            ))
        cursor.execute(
            'INSERT INTO "User" (username, email, password) VALUES ' + (', ').join(insert_query_user))
        connection.commit()
        cursor.execute(
            'INSERT INTO Profile ("user", first_name, last_name) VALUES ' + (', ').join(insert_query_profile))
        connection.commit()

    if count_competitions and count_schools:
        insert_query_competitions = []
        insert_query_flows = []
        insert_query_participants = []
        insert_query_scores = []
        for i in range(count_competitions):
            insert_query_competitions.append("('{school}', '{title}')".format(
                school=random.randint(1, count_schools),
                title=mimesis.Person('ru').title(),
            ))
            for j in range(count_flows):
                insert_query_flows.append("('{competition}')".format(
                    competition=i + 1
                ))
                if count_profiles:
                    for k in range(count_participants):
                        insert_query_participants.append("('{competition}', '{flow}', '{profile}')".format(
                            competition=i + 1,
                            flow=i*count_flows + j+1,
                            profile=random.randint(1, count_profiles)
                        ))
                        for g in range(count_scores):
                            insert_query_scores.append("('{competition}', '{judge}', '{participant}', '{score}')".format(
                                competition=i + 1,
                                judge=random.randint(1, count_profiles),
                                participant=i*count_flows + j + count_participants*j+1 + k+1,
                                score=random.randint(1, 10),
                            ))

        cursor.execute(
            "INSERT INTO Competition (school, title) VALUES " + (", ").join(insert_query_competitions))
        connection.commit()
        cursor.execute(
            "INSERT INTO Flow (competition) VALUES " + (", ").join(insert_query_flows))
        connection.commit()
        cursor.execute(
            "INSERT INTO Participant (competition, flow, profile) VALUES " + (", ").join(insert_query_participants))
        connection.commit()
        cursor.execute(
            "INSERT INTO Score (competition, judge, participant, score) VALUES " + (", ").join(insert_query_scores))
        connection.commit()


except (Exception, Error) as error:
    print("Ошибка при работе с PostgreSQL", error)
finally:
    if connection:
        cursor.close()
        connection.close()
        print("Соединение с PostgreSQL закрыто")
