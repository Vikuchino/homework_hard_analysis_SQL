--1)Назовем “успешными” (’rich’) селлерами тех:кто продает более одной категории товаров
--и чья суммарная выручка превышает 50 000
--Остальные селлеры (продают более одной категории, но чья суммарная выручка менее 50 000)
--будут обозначаться как ‘poor’. Выведите для каждого продавца количество категорий, 
--средний рейтинг его категорий, суммарную выручку, а также метку ‘poor’ или ‘rich’.

-- Выводятся только селлеры, которые подходят под условия и являются rich или poor.

SELECT seller_id, 
	COUNT(DISTINCT category) AS total_categ,  
	ROUND(AVG(rating)) AS avg_rating,
	SUM(revenue) AS total_revenue,             
    CASE 
        WHEN SUM(revenue) > 50000 THEN 'rich'  
        ELSE 'poor'                           
    END AS seller_type
FROM sellers
WHERE category != 'Bedding'
GROUP BY seller_id
HAVING COUNT(DISTINCT category) > 1 
ORDER BY seller_id

--2)Для каждого из неуспешных продавцов (из предыдущего задания) посчитайте, сколько полных
-- месяцев прошло с даты регистрации продавца.Отсчитывайте от того времени, когда вы выполняете
--задание. Считайте, что в месяце 30 дней. Например, для 61 дня полных месяцев будет 2.
--Также выведите разницу между максимальным и минимальным сроком доставки среди неуспешных продавцов. 
--Это число должно быть одинаковым для всех неуспешных продавцов.

--Напишем представление, которое будет отображать продавцов из категории poor
--За дату регистрации берем минимальное значение в столбце date_reg

CREATE or REPLACE VIEW poor_sellerss AS
    SELECT seller_id,
   	 	COUNT(DISTINCT category) AS total_categ,
    	SUM(revenue) AS total_revenue,             
    	MIN(date_reg) AS date_reg,                
    	MIN(delivery_days) AS min_delivery_days,  
    	MAX(delivery_days) AS max_delivery_days   
    FROM sellers
    WHERE category != 'Bedding'  
    GROUP BY seller_id
    HAVING COUNT(DISTINCT category) > 1  
        AND SUM(revenue) <= 50000

-- Запрос. Макс и мин дней доставки оборачиваем в мин и макс, чтобы не группировать по ним
-- Не получилось одинаковое количество дней в разнице доставки

SELECT 
    seller_id, 
    ((current_date - date_reg) / 30) AS month_from_registration, 
    MAX(max_delivery_days) - MIN(min_delivery_days) AS max_delivery_difference 
FROM poor_sellerss
GROUP BY seller_id, date_reg	
ORDER BY seller_id


--3)Отберите продавцов, зарегистрированных в 2022 году и продающих ровно 2 категории
--товаров с суммарной выручкой, превышающей 75 000.
-- Здесь будем использовать подзапрос, но также можно и представление
	
SELECT seller_id, 
    STRING_AGG(category, ' - ' ORDER BY category) AS category_pair
FROM (
    SELECT seller_id, category,
        SUM(revenue) AS total_revenue
    FROM sellers
    WHERE EXTRACT(YEAR FROM date_reg) = 2022 
    GROUP BY seller_id, category
) AS sellers_2
GROUP BY seller_id
HAVING COUNT(DISTINCT category) = 2 
   AND SUM(total_revenue) > 75000 
ORDER BY seller_id