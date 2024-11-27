--1)Выведите список сотрудников с именами сотрудников, получающими самую высокую зарплату в отделе.
--Столбцы в результирующей таблице: first_name, last_name, salary, industry, name_ighest_sal. 
--Последний столбец - имя сотрудника для данного отдела с самой высокой зарплатой
-- В последний столбец записываем только first_name

-- с помощью оконной функции
SELECT first_name, last_name, salary, industry, 
FIRST_VALUE(first_name) OVER w AS name_highest_sal -- берем первое значение имени из каждой группы
FROM salary
WINDOW w AS (
	PARTITION  BY industry -- делим на группы по индустриям
	ORDER BY salary DESC) -- агрегируем по убыванию зарплаты в пределах каждой группы
ORDER BY salary DESC;-- агрегируем по убыванию зарплаты всю таблицу

-- без оконной функции
SELECT 
    salary.first_name, salary.last_name, 
    salary.salary, salary.industry, 
    max_salary.first_name AS name_highest_sal
FROM salary 
JOIN 
    (SELECT industry, first_name
     FROM salary 
     WHERE (industry, salary) IN -- фильтрируем строки с максимальной зарплатой в каждой индустрии
           (SELECT industry, MAX(salary) AS max_salary 
            FROM salary 
            GROUP BY industry)
    ) AS max_salary --подзапрос возвращает отрасль и имя сотрудника с максимальной зарплатой
USING(industry) 
ORDER BY salary.salary DESC;

	
--Выведите аналогичный список, но теперь укажите сотрудников с минимальной зарплатой.
-- с помощью оконной функции
SELECT first_name, last_name, salary, industry, 
LAST_VALUE(first_name) OVER w AS name_lowest_sal -- берем последнее значение имени из каждой группы
FROM salary
WINDOW w AS (
	PARTITION  BY industry -- делим на группы по индустриям
	ORDER BY salary DESC -- агрегируем по убыванию зарплаты в пределах каждой группы
	rows between unbounded preceding and unbounded following) --определяем границы окна
ORDER BY salary DESC; -- агрегируем по убыванию зарплаты всю таблицу

--без оконной функции
SELECT 
    salary.first_name, salary.last_name, 
    salary.salary, salary.industry, 
    min_salary.first_name AS name_lowest_sal
FROM salary 
JOIN 
    (SELECT  industry, first_name 
     FROM salary 
     WHERE (industry, salary) IN 
           (SELECT industry, MIN(salary) AS min_salary 
            FROM salary 
            GROUP BY industry)
    ) AS min_salary
USING (industry) 
ORDER BY salary.salary DESC;

