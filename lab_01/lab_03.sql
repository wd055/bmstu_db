-- функции

-- Скалярную функцию
CREATE OR REPLACE FUNCTION avgScore(competitionId INT)
    RETURNS int AS
$$
BEGIN
    RETURN (SELECT AVG(smT.sm)
            FROM (
                     SELECT sum(score) as sm
                     FROM Score
                     WHERE Score.competition = competitionId
                     GROUP BY Score.participant, Score.competition
                 ) as smT);
END;
$$
    LANGUAGE plpgsql;

SELECT avgScore(2);

-- Подставляемую табличную функцию
-- участницы с наибльшом результатом в соревновании
CREATE OR REPLACE FUNCTION maxParticipantScore()
    RETURNS TABLE
            (
                participant int,
                competition int,
                sm          real
            )
AS
$$
BEGIN
    RETURN QUERY (SELECT Sc.participant,
                         Sc.competition,
                         sum(Sc.score) as sm
                  FROM Score as Sc
                  GROUP BY Sc.participant, Sc.competition
                  HAVING sum(Sc.score) >= ALL (
                      SELECT sum(score)
                      FROM Score
                      WHERE Score.competition = Sc.competition
                      GROUP BY Score.participant, Score.competition
                  ));
END;
$$
    LANGUAGE plpgsql;

SELECT *
FROM maxParticipantScore();

-- Многооператорную табличную функцию
-- Сумма результатов в соревановании
CREATE OR REPLACE FUNCTION sumIncrementParticipantScoreTable(competitionId INT)
    RETURNS TABLE
            (
                participant int,
                competition int,
                sm          real
            )
AS
$$
BEGIN
    DROP TABLE TmpMaxScore;
    CREATE TEMP TABLE TmpMaxScore
    (
        participant int,
        competition int,
        sm          real
    );

    UPDATE Score s
    Set score = s.score + 1
    WHERE s.competition = competitionId
      AND s.score < 9;

    INSERT INTO TmpMaxScore
    SELECT Sc.participant,
           Sc.competition,
           sum(Sc.score) as sm
    FROM Score as Sc
    GROUP BY Sc.participant, Sc.competition;

    RETURN QUERY
        SELECT * FROM TmpMaxScore;
END;
$$ LANGUAGE PLPGSQL;

SELECT *
FROM sumIncrementParticipantScoreTable(7);

-- Рекурсивную функцию или функцию с рекурсивным ОТВ
CREATE OR REPLACE FUNCTION getTrainers()
    RETURNS TABLE
            (
                id      int,
                trainer int,
                level   int
            )
AS
$$
WITH RECURSIVE Profile_Trainers (id, trainer, level) AS (
    SELECT Pr.id,
           Pr.trainer,
           0
    FROM Profile AS Pr
    WHERE Pr.id = 5
    UNION ALL
    SELECT Pr.id,
           Pr.trainer,
           level + 1
    FROM Profile AS Pr
             INNER JOIN Profile_Trainers AS PrT ON Pr.trainer = PrT.id
    WHERE level < 3
)
SELECT *
FROM Profile_Trainers;
$$
    LANGUAGE SQL;

SELECT *
FROM getTrainers();


-- Хранимые процедуры
-- Хранимую процедуру без параметров или с параметрами
CREATE OR REPLACE PROCEDURE updateScore(competitionId INT, change DECIMAL)
AS
$$
BEGIN
    UPDATE Score s
    Set score=score + change
    WHERE competition = competitionId
      AND score < 9;
    COMMIT;
END;
$$ LANGUAGE PLPGSQL;

CALL updateScore(1, 1);

-- Рекурсивная хранимая процедура.
-- CREATE OR REPLACE PROCEDURE RecursiveLevel(id int, trainer int, level int) AS $$
-- DECLARE
--     nextid int;
-- BEGIN
--     nextid := (SELECT age FROM donor WHERE donorid = did);
--     IF nextid > did THEN
--         CALL CountDonorsDepth(nextid, rdepth + 1);
--     ELSE
--         RAISE NOTICE 'Depth is %', rdepth;
--     END IF;
-- END;
-- $$ LANGUAGE plpgsql ;

-- Хранимая процедура с курсором.
CREATE OR REPLACE PROCEDURE cursor_fetch(competitionId INT)
AS $$
DECLARE
    reclist RECORD;
    listcur CURSOR FOR
        SELECT * FROM Score Sc
        WHERE Sc.competition = competitionId;
BEGIN
    OPEN listcur;
    LOOP
        FETCH listcur INTO reclist;
        RAISE NOTICE '% is %', reclist.score, reclist.participant;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE listcur;
END;
$$ LANGUAGE PLPGSQL;

CALL cursor_fetch(1);

-- Хранимая процедура доступа к метаданным.
-- Выводит количество созданных процедур и функций
CREATE OR REPLACE PROCEDURE functionsCount() AS
$$
DECLARE
    num int;
BEGIN
    num := (SELECT count(*)
            FROM pg_proc
            where pronamespace =
                  (SELECT oid
                   FROM pg_namespace
                   WHERE nspname = 'public'));
    RAISE NOTICE 'Создано % функций и процедур', num;
END;
$$ LANGUAGE plpgsql;

CALL functionsCount();


-- Два DML триггера
-- Триггер AFTER
CREATE OR REPLACE FUNCTION UpdateResult() RETURNS TRIGGER AS
$$
DECLARE
    NewResult int;
BEGIN
    NewResult := (SELECT sum(score.score)
                  FROM Score
                  WHERE score.participant = NEW.participant
                    AND score.competition = NEW.competition
                  GROUP BY participant);

    UPDATE participant
    SET result = NewResult
    WHERE id = NEW.participant;

    RAISE NOTICE 'Новый результат: %', NewResult;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER UpdateResult
    AFTER
        INSERT OR UPDATE
    ON lab_01.public.score
    FOR EACH ROW
EXECUTE PROCEDURE UpdateResult();

SELECT *
from lab_01.public.participant
where id = 1;

SELECT *
from lab_01.public.score
where participant = 1;

insert into lab_01.public.score
    (competition, judge, participant, score)
values (1, 1, 1, 5);

-- Триггер INSTEAD OF
CREATE VIEW hackScoreView AS
SELECT *
FROM score s;

CREATE OR REPLACE FUNCTION HackParticipant() RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.score > 10 THEN
        RAISE EXCEPTION 'Jwtyrf ljk;yf ,snm vtymit 10';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER HackParticipant
    INSTEAD OF
        INSERT
    ON hackScoreView
    FOR EACH ROW
EXECUTE PROCEDURE HackParticipant();

insert into hackScoreView
    (competition, judge, participant, score)
values (1, 1, 1, 10);