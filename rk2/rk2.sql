DROP TABLE IF EXISTS Auto CASCADE;
DROP TABLE IF EXISTS Driver CASCADE;
DROP TABLE IF EXISTS Trip CASCADE;


CREATE TABLE Driver
(
    id         serial NOT NULL PRIMARY KEY,
    fullName   varchar(256),
    year       int,
    experience int,
    phone      varchar(20) unique
);

CREATE TABLE Auto
(
    id     serial      NOT NULL PRIMARY KEY,
    driver int         NOT NULL,
    number varchar(10) NOT NULL,
    color  varchar(128),
    FOREIGN KEY (driver) REFERENCES Driver (id)
);

CREATE TABLE Trip
(
    id          serial       NOT NULL PRIMARY KEY,
    driver      int          NOT NULL,
    date        date         NOT NULL,
    addressFrom varchar(128) NOT NULL,
    addressTo   varchar(128) NOT NULL,
    cargo       varchar(128),
    FOREIGN KEY (driver) REFERENCES Driver (id)
);

INSERT INTO Driver (fullName, year, experience, phone)
VALUES ('Иванов Иван Иванович', 2001, 2, '+790231456781'),
       ('Иванов Петр Иванович', 2000, 3, '+790231456782'),
       ('Иванов Алексей Иванович', 2000, 3, '+790231456783'),
       ('Иванов Валерий Иванович', 2001, 2, '+790231456784'),
       ('Иванов Станислав Иванович', 1999, 4, '+790231456785'),
       ('Иванов Владислав Иванович', 1998, 5, '+790231456786'),
       ('Иванов Инакентий Иванович', 1985, 10, '+790231456787'),
       ('Иванов Владимир Иванович', 1999, 2, '+790231456788'),
       ('Иванов Дмитрий Иванович', 1985, 1, '+790231456789'),
       ('Иванов Федор Иванович', 1998, 6, '+790231456780');

INSERT INTO Auto (driver, number, color)
VALUES (1, 'ЯЦ123У', 'Красный'),
       (2, 'ФЫ234А', 'Синий'),
       (3, 'ОЛ127Р', 'Зеленый'),
       (4, 'ИТ765Е', 'Желтый'),
       (5, 'ЕН604Г', 'Красный'),
       (6, 'АТ153О', 'Синий'),
       (7, 'ФР194Ш', 'Желтый'),
       (8, 'ИФ587Н', 'Синий'),
       (9, 'ТЛ482К', 'Красный'),
       (10, 'ИГ427Т', 'Желтый');

INSERT INTO Trip (driver, date, addressFrom, addressTo, cargo)
VALUES (1, '01-01-2021', 'МГТУ УЛК', 'Бомонка ГЗ', 'Тела студентов'),
       (2, '02-01-2021', 'МГТУ УЛК', 'Бомонка ГЗ', 'Дела студентов'),
       (7, '01-01-2020', 'МГТУ УЛК', 'МГТУ Э', 'Учебники'),
       (4, '03-01-2021', 'МГТУ УЛК', 'Бомонка ГЗ стловая', 'Еда'),
       (5, '01-01-2021', 'Бомонка ГЗ', '4 общежитие МГТУ', 'Еда'),
       (5, '04-01-2021', 'Макдональдс на бауманской', 'МГТУ УЛК', 'Еда'),
       (7, '01-01-2020', 'МГТУ УЛК', 'Бомонка ГЗ', 'Тела студентов'),
       (7, '06-01-2021', 'МГТУ УЛК', 'Бомонка ГЗ', 'Тела студентов'),
       (9, '05-01-2020', 'МГТУ УЛК', 'Бомонка ГЗ', 'Тела студентов'),
       (10, '03-01-2021', 'МГТУ УЛК', 'МГТУ УЛК', 'Тела студентов');

-- 1) Инструкцию SELECT, использующую простое выражение CASE
-- Выводит тип доставки, в УЛК (Зывоз), из УЛК(Вывоз), (Беды с головой) если из УЛК в УЛК или null
SELECT id,
       addressFrom,
       addressTo,
       CASE
           WHEN addressFROM = 'МГТУ УЛК' AND addressTo = 'МГТУ УЛК'
               THEN 'Беды с головой'
           WHEN addressFrom = 'МГТУ УЛК'
               THEN 'Вывоз'
           WHEN addressTo = 'МГТУ УЛК'
               THEN 'Завоз'
           END tripType
FROM Trip;

-- 2) Инструкцию, использующую оконную функцию
-- Вывод водителей и средний стаж за год их рождения
SELECT id,
       year,
       experience,
       AVG(experience) OVER (PARTITION BY year)
FROM Driver;

-- 3) Инструкцию SELECT, консолидирующую данные с помощью предложения GROUP BY и предложения HAVING
-- Дни, когда была только одна доставка
SELECT date
FROM Trip
GROUP BY date
HAVING count(*) = 1;


-- Задание 3
CREATE OR REPLACE PROCEDURE dumpDB(dateUpdate date)
AS
$$
select date_part('year', current_date)::varchar(255) || date_part('month', current_date)::varchar(255) || date_part('date', current_date)::varchar(255);

SELECT datname
FROM pg_stat_database
WHERE stats_reset > dateUpdate;

CREATE DATABASE newdb2 WITH TEMPLATE test;
$$ language sql;

CALL dumpDB();