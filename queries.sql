--Запрос считает количество покупателей из таблицы customers по полю customer_id:
select 
count(customer_id) as customers_count
from customers;
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--Анализ отдела продаж ОТЧЕТ №1 (top_10_total_income):
with t as
(
select
	concat(e.first_name, ' ', last_name) as name,
	s.product_id,
	count(s.sales_id) as operations,
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
	floor(sum(t.income)) as income
from t
group by 1
order by 3 desc limit 10;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--Анализ отдела продаж ОТЧЕТ №2 (lowest_average_income):
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
--Анализ отдела продаж ОТЧЕТ №3 (day_of_week_income):
with t as
(
select
	distinct concat(e.first_name||e.last_name) as name,
	to_char(s.sale_date, 'day') as weekday,
	extract(isodow from s.sale_date) as weekday_no,
	round(sum(s.quantity * p.price) over (partition by s.sales_person_id, to_char(s.sale_date, 'day')), 0) as income
from sales s
join employees e on e.employee_id = s.sales_person_id 
join products p on p.product_id = s.product_id
order by 3, 1
)
select 
	name,
	weekday,
	income
from t;
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--Анализ покупателей ОТЧЕТ №1 (age_groups):
create table a_c 
(
	id bigint primary key generated always as identity,
	age_category varchar(255),
	count bigint
);

insert into a_c (age_category, count) values
	('16-25', (select count(customer_id) from customers where age >= 16 and age <= 25)),
	('26-40', (select count(customer_id) from customers where age >= 26 and age <= 40)),
	('40+', (select count(customer_id) from customers where age >= 41));

select 
	age_category,
	count
from a_c;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--Анализ покупателей ОТЧЕТ №2 (customers_by_month):
select 
	to_char(s.sale_date, 'yyyy-mm') as date,
	count(distinct s.customer_id) as total_customers,
	round(sum(s.quantity*p.price), 0) as income
from sales s
join products p on p.product_id = s.product_id
group by 1
order by 1;
-----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--Анализ покупателей ОТЧЕТ №3 (special_offer):
--Анализ покупателей ОТЧЕТ №3 (special_offer):
with t as
(
select distinct on (s.customer_id)
	s.*,
	p.price,
	concat(c.first_name, ' ', c.last_name) as customer,
	concat(e.first_name, ' ', e.last_name) as seller
from sales s 
left join customers c on c.customer_id = s.customer_id 
left join products p on p.product_id = s.product_id
left join employees e on e.employee_id = s.sales_person_id
where p.price = 0
order by s.customer_id, s.sale_date
)
select 
	customer,
	sale_date,
	seller
from t
order by customer_id
;
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------














