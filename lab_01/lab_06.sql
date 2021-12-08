-- 1. Выполнить скалярный запрос;
SELECT id, title
FROM competition
WHERE id = 2;

-- 2. Выполнить запрос с несколькими соединениями (JOIN);
-- имена всех судей, которые судили соревнования, в которых участвовали школы с 3 по 5

SELECT DISTINCT c.id, j.id, prJ.*
FROM lab_01.public.competition c
JOIN participant p on c.id = p.competition
JOIN lab_01.public.profile pr on p.profile = pr.id
JOIN lab_01.public.judge j on c.id = j.competition
JOIN lab_01.public.profile prJ on j.profile = prJ.id
WHERE pr.school in (3)

-- 3. Выполнить запрос с ОТВ(CTE) и оконными функциями;


-- 4. Выполнить запрос к метаданным;
SELECT datname
FROM pg_stat_database;

-- 5. Вызвать скалярную функцию (написанную в третьей лабораторной работе);


-- 6. Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе);


-- 7. Вызвать хранимую процедуру (написанную в третьей лабораторной работе);


-- 8. Вызвать системную функцию или процедуру;


-- 9. Создать таблицу в базе данных, соответствующую тематике БД;


-- 10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.

