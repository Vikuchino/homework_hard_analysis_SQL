--1)Для каждого города выведите число покупателей из соответствующей таблицы, 
--сгруппированных по возрастным категориям и отсортированных по убыванию количества
--покупателей в каждой категории

SELECT COUNT(ID) AS BUYER_COUNT, AGE, CITY
FROM USERS 
GROUP BY AGE, CITY 
ORDER BY BUYER_COUNT DESC

--Можете дополнительно написать запрос именно для “категорий”
SELECT COUNT(ID) AS BUYER_COUNT, CITY, 
     CASE 
        WHEN AGE BETWEEN 0 AND 20 THEN 'young'
        WHEN AGE BETWEEN 21 AND 49 THEN 'adult'
        ELSE 'old'
  	 END AS AGE_CATEGORY
FROM USERS 
GROUP BY AGE_CATEGORY,CITY 
ORDER BY BUYER_COUNT DESC;

--2)Рассчитайте среднюю цену категорий товаров в таблице products, 
--в названиях товаров которых присутствуют слова «hair» или «home». Среднюю цену округлите 
--до двух знаков после запятой. Столбец с полученным значением назовите avg_price
SELECT ROUND(CAST(AVG(PRICE) AS NUMERIC), 2) AS avg_price, CATEGORY 
FROM PRODUCTS
WHERE CATEGORY IN ('Hair', 'Home') 
GROUP BY CATEGORY;
