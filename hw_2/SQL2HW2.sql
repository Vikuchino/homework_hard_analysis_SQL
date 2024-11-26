-- Вычислить общую сумму продаж для каждой категории продуктов.
-- Определить категорию продукта с наибольшей общей суммой продаж.
-- Для каждой категории продуктов, определить продукт с максимальной суммой продаж в этой категории.

SELECT 
    product_category, -- категории продуктов
    total_sum, -- сумма продаж на категорию
    top_product, -- название продукта в каждой категории с макс суммой продажи
    top_product_sales, -- сумма продаж top_product
	
    CASE -- проверяем, является ли текущая категория категорией с наибольшей суммой продаж
        WHEN total_sum = (SELECT MAX(total_sum) 
                         FROM (SELECT SUM(ord1.order_ammount) AS total_sum
                               FROM ORDERS_2 AS ord1
                               JOIN PRODUCTS_3 AS prod1 ON ord1.product_id = prod1.product_id
                               GROUP BY prod1.product_category
                              ) AS a)
        THEN 'Максимальные продажи' -- для категории с самыми большими продажами
        ELSE '-' -- для остальных категорий
    END AS status -- записываем результат проверки
	
FROM 
    (SELECT -- подсчитываем данные по категориям
        prod1.product_category,
        SUM(ord1.order_ammount) AS total_sum,
	
        (SELECT prod2.product_name -- определяем название продукта с макс продажами в категории
         FROM ORDERS_2 AS ord2
         JOIN PRODUCTS_3 AS prod2 ON ord2.product_id = prod2.product_id
         WHERE prod2.product_category = prod1.product_category
         GROUP BY prod2.product_name
         ORDER BY SUM(ord2.order_ammount) DESC -- сортируем по убыванию суммы
         LIMIT 1) AS top_product, -- берем первый продукт 
	
        (SELECT SUM(ord2.order_ammount) -- подсчет суммы продаж у top_product в каждой категории
         FROM ORDERS_2 AS ord2
         JOIN PRODUCTS_3 AS prod2 ON ord2.product_id = prod2.product_id
         WHERE prod2.product_category = prod1.product_category
         GROUP BY prod2.product_name
         ORDER BY SUM(ord2.order_ammount) DESC -- сортируем по убыванию суммы
         LIMIT 1) AS top_product_sales -- берем первую сумму
	
    FROM ORDERS_2 AS ord1
	
    JOIN PRODUCTS_3 AS prod1 ON ord1.product_id = prod1.product_id
	
    GROUP BY prod1.product_category
	
) AS sales_by_category
	
ORDER BY total_sum DESC; -- сортируем категории по убыванию суммы продаж
