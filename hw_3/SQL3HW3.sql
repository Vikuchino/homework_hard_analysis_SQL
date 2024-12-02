CREATE TABLE QUERY (
    SEARCHID SERIAL PRIMARY KEY,
    YEAR INT,
    MONTH INT,
    DAY INT,
    USERID INT,
    TS INT,  -- время запроса в формате unix
    DEVICETYPE VARCHAR(50), -- операционная система телефона: андроид или ios
    DEVICEID INT, -- id операционной системы (1100 - андроид, 1000 - ios)
    QUERY VARCHAR(255), -- запрос
    IS_FINAL INT
);

INSERT INTO QUERY (year, month, day, userid, ts, devicetype, deviceid, query) VALUES
(2024, 1, 1, 10001, 1704067200, 'ANDROID', 1100, 'КУ'),
(2024, 1, 1, 10001, 1704067260, 'ANDROID', 1100, 'КУП'),
(2024, 1, 1, 10001, 1704067320, 'ANDROID', 1100, 'КУПИТЬ'),
(2024, 1, 1, 10001, 1704067380, 'ANDROID', 1100, 'КУПИТЬ КУР'),
(2024, 1, 1, 10001, 1704067500, 'ANDROID', 1100, 'КУРТКУ'), 
(2024, 1, 1, 10002, 1704067200, 'ANDROID', 1100, 'ПИСЬМЕННЫЙ'),
(2024, 1, 1, 10002, 1704067260, 'ANDROID', 1100, 'ПИСЬМЕННЫЙ СТОЛ'),
(2024, 1, 1, 10002, 1704067320, 'ANDROID', 1100, 'ПИСЬМЕННЫЙ СТОЛ ДЛЯ'),
(2024, 1, 1, 10002, 1704067380, 'ANDROID', 1100, 'ПИСЬМЕННЫЙ СТОЛ ДЛЯ ШКОЛЬНИКА'),
(2024, 1, 1, 10003, 1704067200, 'ANDROID', 1100, 'ЧЕХОЛ'),
(2024, 1, 1, 10003, 1704067260, 'ANDROID', 1100, 'ЧЕХОЛ НА'),
(2024, 1, 1, 10003, 1704067320, 'ANDROID', 1100, 'ЧЕХОЛ НА НОУТБУК'),
(2024, 1, 1, 10003, 1704067380, 'ANDROID', 1100, 'ЧЕХОЛ НА НОУТБУК КУПИТЬ'),
(2024, 1, 1, 10004, 1704067200, 'IOS', 1000, 'НАУШНИКИ'),
(2024, 1, 1, 10004, 1704067260, 'IOS', 1000, 'НАУШНИКИ БЕСПРОВОДНЫЕ'),
(2024, 1, 1, 10004, 1704067320, 'IOS', 1000, 'БЕСПРОВОДНЫЕ НАУШНИКИ С'),
(2024, 1, 1, 10004, 1704067380, 'IOS', 1000, 'БЕСПРОВОДНЫЕ НАУШНИКИ С ШУМОПОДАВЛЕНИЕМ'),
(2024, 1, 1, 10005, 1704067200, 'ANDROID', 1100, 'ТЕРМОП'),
(2024, 1, 1, 10005, 1704067260, 'ANDROID', 1100, 'ТЕРМОПОТ'),
(2024, 1, 1, 10005, 1704067320, 'ANDROID', 1100, 'ТЕРМОПОТ КУ'),
(2024, 1, 1, 10005, 1704067380, 'ANDROID', 1100, 'ТЕРМОПОТ КУПИТЬ');

-- создаем CTE для ранжирования запросов
WITH RankedQueries AS (
    SELECT
        YEAR, MONTH, DAY, USERID, TS, DEVICETYPE, DEVICEID, QUERY,                       
        LAG(TS) OVER (PARTITION BY DEVICEID ORDER BY TS) AS Prev_TS, -- временная метка предыдущего запроса
        LEAD(TS) OVER (PARTITION BY DEVICEID ORDER BY TS) AS Next_TS, -- временная метка следующего запроса
        LEAD(QUERY) OVER (PARTITION BY DEVICEID ORDER BY TS) AS Next_Query -- текст следующего запроса
    FROM QUERY                        
), 

-- создаем второй CTE, в котором определяем значение is_final для каждого запроса
FinalQueries AS (
    SELECT
        YEAR, MONTH, DAY, USERID, TS, DEVICETYPE, DEVICEID, QUERY, Next_Query,                   
        CASE
            WHEN Next_TS IS NULL THEN 1 -- последний запрос (нет следующей временной метки)
            WHEN Next_TS - TS > 180 THEN 1 -- разрыв между запросами более 3 минут
	        -- следующий запрос короче текущего и разрыв больше 1 минуты      
            WHEN CHAR_LENGTH(Next_Query) < CHAR_LENGTH(QUERY) AND Next_TS - TS > 60 THEN 2 
            ELSE 0 
        END AS is_final               
    FROM RankedQueries
)

-- извлекаем данные из финального CTE
SELECT
    YEAR, MONTH, DAY, USERID, TS, DEVICETYPE, DEVICEID, QUERY, Next_Query, is_final                          
FROM FinalQueries
WHERE is_final IN (1, 2)              -- фильтруем только запросы с is_final = 1 или 2
  AND DEVICETYPE = 'ANDROID'          -- учитываем только устройства типа ANDROID
  AND YEAR = 2024 AND MONTH = 1 AND DAY = 1; -- фильтруем данные за конкретный день (1 января 2024 года)



