-- 1

\t
\a
\o /db/Profile.json
SELECT ROW_TO_JSON(t) FROM profile t;

\t
\a
\o /db/User.json
SELECT ROW_TO_JSON(t) FROM "User" t;

\t
\a
\o /db/School.json
SELECT ROW_TO_JSON(t) FROM School t;

\t
\a
\o /db/Competition.json
SELECT ROW_TO_JSON(t) FROM Competition t;

\t
\a
\o /db/Judge.json
SELECT ROW_TO_JSON(t) FROM Judge t;

\t
\a
\o /db/Flow.json
SELECT ROW_TO_JSON(t) FROM Flow t;

\t
\a
\o /db/Subflow.json
SELECT ROW_TO_JSON(t) FROM Subflow t;

\t
\a
\o /db/Participant.json
SELECT ROW_TO_JSON(t) FROM Participant t;

\t
\a
\o /db/Score.json
SELECT ROW_TO_JSON(t) FROM Score t;

-- 2

CREATE TABLE score_from_json (
    competition int NOT NULL,
    judge int NOT NULL,
    participant int NOT NULL,
    score real NOT NULL,
    create_date timestamp DEFAULT NOW(),
    FOREIGN KEY (competition) REFERENCES Competition (id),
    FOREIGN KEY (judge) REFERENCES Profile (id),
    FOREIGN KEY (participant) REFERENCES Participant (id)
);
CREATE TABLE temp (
    data jsonb
);
COPY temp (data) FROM '/db/Score.json';
INSERT INTO score_from_json (competition, judge, participant, score, create_date)
SELECT (data->>'competition')::DECIMAL, (data->>'judge')::DECIMAL, (data->>'participant')::DECIMAL, (data->>'score')::DECIMAL, TO_TIMESTAMP(data->>'create_date','YYYY-MM-DDTHH:MI:SS') FROM temp;

SELECT  * FROM Score;
SELECT * FROM score_from_json;

-- 3

CREATE TEMP TABLE participant_tmp AS (SELECT * FROM participant);
ALTER TABLE participant_tmp ADD COLUMN score_json json;

UPDATE participant_tmp
SET score_json = (
    SELECT json_build_object('score',s.score,'judge',s.judge)
    FROM score as s
    WHERE s.participant = participant_tmp.id
    ORDER BY s.score
    LIMIT 1
    );

SELECT * FROM participant_tmp;


-- 4.1

SELECT '[{"id":6,"competition":1,"judge":179,"participant":2,"score":10,"create_date":"2021-11-16T04:32:04.054434"},
{"id":14,"competition":1,"judge":199,"participant":3,"score":10,"create_date":"2021-11-16T04:32:04.054434"},
{"id":16,"competition":1,"judge":183,"participant":3,"score":9,"create_date":"2021-11-16T04:32:04.054434"},
{"id":19,"competition":1,"judge":124,"participant":4,"score":9,"create_date":"2021-11-16T04:32:04.054434"}]'::json->2;

-- 4.2

SELECT score_json->'judge' AS judge FROM participant_tmp;

-- 4.3

SELECT score_json->'product_id' IS NOT NULL AS check_column FROM participant_tmp
LIMIT 1;

SELECT score_json->'asdasd' IS NOT NULL AS check_column FROM participant_tmp
LIMIT 1;

-- 4.4

SELECT jsonb_set('[{"id":6,"competition":1,"judge":179,"participant":2,"score":10,"create_date":"2021-11-16T04:32:04.054434"},
{"id":14,"competition":1,"judge":199,"participant":3,"score":10,"create_date":"2021-11-16T04:32:04.054434"},
{"id":16,"competition":1,"judge":183,"participant":3,"score":9,"create_date":"2021-11-16T04:32:04.054434"},
{"id":19,"competition":1,"judge":124,"participant":4,"score":9,"create_date":"2021-11-16T04:32:04.054434"}]', '{1, score}', jsonb '2')->1
AS score_change;

-- 4.5

SELECT json_build_object('score', score_json->'score') AS first,
json_build_object('judge', score_json->'judge') AS second
FROM (
    SELECT score_json
    FROM participant_tmp
) AS tmp;
