-- 1. Инструкция SELECT, использующая предикат сравнения.
SELECT profile, competition
FROM Participant
WHERE Participant.competition = 2;

-- 2. Инструкция SELECT, использующая предикат BETWEEN.
SELECT participant, score.score, competition
FROM Score
WHERE score.score BETWEEN 5 AND 10;

-- 3. Инструкция SELECT, использующая предикат LIKE.
SELECT first_name
FROM Profile
WHERE first_name LIKE 'А%';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- участницы соревновния от 2 школы
SELECT competition, profile
FROM Participant
WHERE competition in (
    SELECT id
    FROM Competition
    WHERE school = 2
    );

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- участницы без оценок
SELECT id, profile
FROM Participant as Pr
WHERE NOT EXISTS(
    SELECT id
    FROM Score
    WHERE Score.participant = Pr.id
    );

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- участницы с наибльшом результатом в соревновании
SELECT participant, competition, sum(score)
FROM Score as Sc
GROUP BY participant, competition
HAVING sum(score) >= ALL (
    SELECT sum(score)
    FROM Score
    WHERE Score.competition = Sc.competition
    GROUP BY Score.participant, Score.competition
);

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
SELECT sum(score)
FROM Score;

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
SELECT profile, competition,
       (SELECT sum(score) FROM Score WHERE Score.participant = Pr.id) as sum_score,
       (SELECT count(score) FROM Score WHERE Score.participant = Pr.id) as count_score,
       (SELECT avg(score) FROM Score WHERE Score.participant = Pr.id) as avg_score
FROM Participant as Pr;

-- 9. Инструкция SELECT, использующая простое выражение CASE.

SELECT score,
       CASE score
            WHEN 10 THEN 'WOW!!'
            ELSE 'Можно было и лучше'
        END as title
FROM Score
LIMIT 100;

-- 10. Инструкция SELECT, использующая поисковое выражение CASE.

SELECT score,
       CASE
            WHEN score = 10 THEN 'WOW!!'
            ELSE 'Можно было и лучше'
        END as title
FROM Score
LIMIT 100;

-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
-- [6]

DROP TABLE IF EXISTS TmpMaxScore;

SELECT participant, competition, sum(score)
INTO TmpMaxScore
FROM Score as Sc
GROUP BY participant, competition
HAVING sum(score) >= ALL (
    SELECT sum(score)
    FROM Score
    WHERE Score.competition = Sc.competition
    GROUP BY Score.participant, Score.competition
);

SELECT * FROM TmpMaxScore;

-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.

SELECT profile, sm
FROM Participant
JOIN (
    SELECT sum(score) as sm, participant
    FROM Score
    GROUP BY participant
    ) as smT ON smT.participant = id;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3

SELECT last_name, first_name, sm
FROM Profile
JOIN (
    SELECT profile, sm
    FROM Participant
    JOIN (
        SELECT sum(score) as sm, participant
        FROM Score
        GROUP BY participant
        ) as smT ON smT.participant = id
    ) as Pt ON Pt.profile = id;

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- [6]

SELECT AVG(sm)
FROM (
    SELECT sum(score) as sm
    FROM Score
    GROUP BY Score.participant, Score.competition
) as smT;

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- [6]


SELECT sum(score), participant, competition
FROM Score
GROUP BY Score.participant, Score.competition
HAVING sum(score) > (
    SELECT AVG(sm)
    FROM (
        SELECT sum(score) as sm
        FROM Score
        GROUP BY Score.participant, Score.competition
    ) as smT
);

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.

INSERT INTO Competition (school, title) VALUES (1, 'test') RETURNING *;

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.

INSERT INTO Competition (school, title)
SELECT id, title
FROM School
WHERE id=1;

SELECT Co.*, Sc.* FROM Competition as Co
JOIN School as Sc on Co.school = Sc.id;

-- 18. Простая инструкция UPDATE.

UPDATE Competition
Set title='asd'
WHERE id=1;

SELECT * FROM Competition
WHERE id=1;

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.

UPDATE Competition
Set title=(SELECT title FROM school WHERE id = 1)
WHERE id=1;

SELECT * FROM Competition
WHERE id=1;

-- 20. Простая инструкция DELETE.

DELETE FROM Competition
WHERE id=4;

SELECT *
FROM Competition;

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.

DELETE FROM Participant
WHERE id not in (
    SELECT score.participant
    FROM Score
    GROUP BY score.participant
) AND id = 77;

SELECT *
FROM Participant;

SELECT *
FROM Participant
WHERE id not in (
    SELECT score.participant
    FROM Score
    GROUP BY score.participant
);

-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- [15]

WITH Score_sum (sum, participant) AS (
    SELECT sum(score) as sm, participant
    FROM Score
    GROUP BY Score.participant, Score.competition
)
SELECT AVG(sum), participant
FROM Score_sum as smT
GROUP BY participant;

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.

-- WITH School_CTE (id) AS (
--     SELECT c.school
--     FROM Participant
--     JOIN competition c on participant.competition = c.id
--     GROUP BY c.school
-- )
-- SELECT * FROM School_CTE;

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()

SELECT participant.id, participant.profile,
       AVG(Score.score) OVER (PARTITION BY participant.id) as AvgScore,
       MIN(Score.score) OVER (PARTITION BY participant.id) as MinScore,
       MAX(Score.score) OVER (PARTITION BY participant.id) as MaxScore
FROM participant
LEFT JOIN score on participant.id = score.participant;

-- 25. Оконные фнкции для устранения дублей
