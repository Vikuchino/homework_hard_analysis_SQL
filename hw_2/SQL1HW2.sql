--1)Найти клиента с самым долгим временем ожидания между заказом и доставкой. 

SELECT DISTINCT -- есть клиенты у которых несколько заказов с наибольшим временем ожидания,
	            --поэтому применяем DISTINCT   
   customers.name, orders.customer_id, 
   orders.shipment_date - orders.order_date AS time_of_wait -- время ожидания
FROM customers_new_3 AS customers
JOIN orders_new_3 AS orders
USING(customer_id) 
WHERE 
    orders.shipment_date - orders.order_date = (
        SELECT MAX(shipment_date - order_date) --выбираем макс время ожидания
        FROM orders_new_3
    )
ORDER BY customers.name -- сортируем по имени клиентов


--2)Найти клиентов, сделавших наибольшее количество заказов, и для каждого из них найти среднее
--время между заказом и доставкой, а также общую сумму всех их заказов. Вывести клиентов
--в порядке убывания общей суммы заказов.

-- Напишем представление о параметрах клиентов, чтобы избежать большого количества вложенности.
	
CREATE OR REPLACE VIEW customer_order AS
SELECT customer_id, -- номер клиента
    COUNT(order_id) AS total_orders, -- количество заказов
    AVG(shipment_date - order_date) AS avg_delivery, --ср.время ожидания между заказами и их доставкой
    SUM(order_ammount) AS total_sum -- сумма всех заказов
FROM orders_new_3
GROUP BY customer_id;

-- Запрос
SELECT customer_order.customer_id,
    customers_new_3.name,
    customer_order.total_orders,
    customer_order.avg_delivery,
    customer_order.total_sum
FROM customer_order  -- из представления
JOIN customers_new_3 
USING(customer_id)  
WHERE customer_order.total_orders = (
    SELECT MAX(total_orders) -- условие на выбор макс количества заказов у каждого клиента
    FROM customer_order
)
ORDER BY customer_order.total_sum DESC -- сортируем по убыванию суммы заказов

--3)Найти клиентов, у которых были заказы, доставленные с задержкой более чем на 5 дней, 
--и клиентов, у которых были заказы, которые были отменены. Для каждого клиента вывести имя,
--количество доставок с задержкой, количество отмененных заказов и их общую сумму.
--Результат отсортировать по общей сумме заказов в убывающем порядке.

-- Используем FILTER для удобной фильтрации параметров в SELECT
-- В WHERE фильтруем клиентов, исключаем тех у которых нет отмен и нет долгих задержек
	
SELECT 
    customers.name,
    COUNT(orders.order_id) FILTER (WHERE EXTRACT(DAY FROM (orders.shipment_date - orders.order_date)) > 5)
	AS delay_orders, -- rколичество заказов с задержкой
	-- количество отмененных заказов
    COUNT(orders.order_id) FILTER (WHERE orders.order_status = 'Cancel') AS cancell_orders,
    SUM(orders.order_ammount) AS total_sum -- сумма всех заказов у каждого клиента по условиям из where
FROM customers_new_3 AS customers
JOIN orders_new_3 AS orders USING(customer_id)
WHERE 
    orders.order_status = 'Cancel' 
    OR EXTRACT(DAY FROM (orders.shipment_date - orders.order_date)) > 5
GROUP BY customers.customer_id, customers.name
ORDER BY total_sum DESC --сортируем по убыванию общей суммы заказов
