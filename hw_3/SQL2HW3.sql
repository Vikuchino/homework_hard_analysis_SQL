--1)Отберите данные по продажам за 2.01.2016. Укажите для каждого магазина его адрес,
--сумму проданных товаров в штуках, сумму проданных товаров в рублях.
--Столбцы в результирующей таблице: SHOPNUMBER , CITY , ADDRESS, SUM_QTY SUM_QTY_PRICE

SELECT DISTINCT SHOPS.SHOPNUMBER, SHOPS.CITY, SHOPS.ADDRESS, 
    SUM(SALES.QTY) OVER w AS SUM_QTY,  -- cумма проданных товаров в штуках
    SUM(SALES.QTY * GOODS.PRICE) OVER w AS SUM_QTY_PRICE  -- cумма проданных товаров в рублях
FROM  SALES 
JOIN  GOODS 
USING(ID_GOOD)                          
JOIN SHOPS 
USING(SHOPNUMBER)                      
WHERE SALES.DATE = '2016-01-02'                             
WINDOW w AS (PARTITION BY SHOPS.SHOPNUMBER)  -- оконная функция с партициями по номеру магазина    
ORDER BY SHOPS.SHOPNUMBER;   -- сортируем по номеру магазина

--2)Отберите за каждую дату долю от суммарных продаж (в рублях на дату). Расчеты проводите только 
--по товарам направления ЧИСТОТА.Столбцы в результирующей таблице: DATE_, CITY, SUM_SALES_REL

SELECT 
    SALES.DATE AS DATE_, SHOPS.CITY,                                        
    ROUND((SUM(SALES.QTY * GOODS.PRICE) * 100.0) / SUM(SUM(SALES.QTY * GOODS.PRICE)) OVER w )            
    AS SUM_SALES_REL -- доля в % от суммарных продаж за конкретную дату на город
FROM  SALES 
JOIN GOODS 
USING (ID_GOOD)                                    
JOIN SHOPS 
USING (SHOPNUMBER)                                
WHERE GOODS.CATEGORY = 'ЧИСТОТА'   -- выбираем  товары категории ЧИСТОТА
GROUP BY  SALES.DATE, SHOPS.CITY  -- группируем по дате и городу
WINDOW w AS (PARTITION BY SALES.DATE);   -- оконная функция партицируем по дате

--3)Выведите информацию о топ-3 товарах по продажам в штуках в каждом магазине в каждую дату.
--Столбцы в результирующей таблице:DATE_ , SHOPNUMBER, ID_GOOD

SELECT 
    DATE_, SHOPNUMBER, ID_GOOD                            
FROM (
    SELECT 
        SALES.DATE AS DATE_,SALES.SHOPNUMBER,              
        SALES.ID_GOOD, SALES.QTY,  -- количество продаж
        DENSE_RANK() OVER ( -- присваивания рангов товарам в каждом магазине и на каждой дате
            PARTITION BY SALES.DATE, SALES.SHOPNUMBER   -- партиции по дате и магазину
            ORDER BY SALES.QTY DESC    
        ) AS RANK_VALUE                
    FROM SALES
    JOIN GOODS 
    USING (ID_GOOD)                   
) AS RankedSales
WHERE RANK_VALUE <= 3  -- Фильтруем только топ-3 товара
ORDER BY DATE_, SHOPNUMBER, RANK_VALUE; 



--4)Выведите для каждого магазина и товарного направления сумму продаж в рублях за предыдущую дату.
--Только для магазинов Санкт-Петербурга.Столбцы в результирующей таблице:
--DATE_, SHOPNUMBER, CATEGORY, PREV_SALES
-- В первый день нет продаж за пред день

SELECT 
    SALES.DATE AS DATE_,                           
    SALES.SHOPNUMBER,                               
    GOODS.CATEGORY,  
	-- используем lag чтобы подтягивать сумму продаж на предыдущую дату
    LAG (SUM(SALES.QTY * GOODS.PRICE),1) OVER (
            PARTITION BY SALES.SHOPNUMBER, GOODS.CATEGORY -- создаем окно по номеру магазина и категории товаров
            ORDER BY SALES.DATE -- сортируем по дате
            ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING -- диапазон строк
        ) AS PREV_SALES                    
FROM  SALES 
JOIN  GOODS 
USING (ID_GOOD)                                
JOIN SHOPS 
USING (SHOPNUMBER)                              
WHERE  SHOPS.CITY = 'СПб'  -- магазины только в спб  
GROUP BY SALES.DATE,SALES.SHOPNUMBER,  GOODS.CATEGORY
ORDER BY SALES.SHOPNUMBER, SALES.DATE, GOODS.CATEGORY;

