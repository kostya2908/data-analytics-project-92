--Запрос считает количество покупателей из таблицы customers по полю customer_id:
select 
count(customer_id) as customers_count
from customers;
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--Анализ отдела продаж ОТЧЕТ №1:
--Запрос №1 (group by):
with t as
(
select
	concat(e.first_name, ' ', last_name) as name,
	s.product_id,
	sum(s.quantity) as operations,
	p.price,
	sum(s.quantity)*p.price as income
from sales as s
join employees as e on e.employee_id = s.sales_person_id
join products as p on p.product_id = s.product_id
group by 1, 2, 4
)
select 
	t.name as name, 
	sum(t.operations) as operations,
	sum(t.income) as income
from t
group by 1
order by 3 desc limit 10;
-------------------------------------------------------------------------------------------
--Анализ отдела продаж ОТЧЕТ №1:
--Запрос №2 (partition by):
with t as
(
select 
	distinct concat(e.first_name, ' ', e.last_name) as full_name,
	sum(s.quantity) over (partition by s.sales_person_id, s.product_id) as quantity_per_product,
	(sum(s.quantity) over (partition by s.sales_person_id, s.product_id))*p.price as income_per_product
from sales s
join products p on p.product_id = s.product_id
join employees e on e.employee_id = s.sales_person_id
order by 1 asc
)
select
	distinct full_name as name,
	sum(quantity_per_product) over (partition by full_name) as operations,
	sum(income_per_product) over (partition by full_name) as income
from t
order by 3 desc limit 10;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--Анализ отдела продаж ОТЧЕТ №2:
with tab as
(
select 
	distinct concat(e.first_name, ' ', e.last_name) as full_name,
	round(avg(s.quantity * p.price) over (partition by s.sales_person_id), 0) as average_income,
	(
	select
		round(avg(s.quantity * p.price), 0)
	from sales s
	join products p on p.product_id = s.product_id
	) as total_average
from sales s
join employees e on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id
)
select
	full_name as name,
	average_income
from tab
where average_income < total_average
order by 2 asc
;
---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--Анализ отдела продаж ОТЧЕТ №3:




















