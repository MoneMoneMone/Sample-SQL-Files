
select 
	a.customer_id,
	a.order_line,
	a.product_id,
	a.sales,
	b.customer_id,
	b.customer_name,
	b.age
from sales_2015 as a
full join customer_20_60 as b
on a.customer_id = b.customer_id
order by a.customer_id,b.customer_id

/*Cross Join*/
create table month_values (MM integer)
create table year_values (YYYY integer)
insert into month_values values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)
insert into year_values values (2011),(2012),(2013),(2014),(2015),(2016),(2017),(2018),(2019)
select * from year_values
select * from month_values

select a.yyyy, b.mm
from year_values as a,month_values as b
order by a.YYYY,b.MM

/* Intersect */

select customer_id from sales_2015 -- 2131
intersect
select customer_id from customer_20_60 -- 2985
-- 736
/* Except */

select customer_id from sales_2015
Except
select customer_id from customer_20_60
--except 142
--except all 791
/* Union */

select customer_id from sales_2015
Union
select customer_id from customer_20_60

--exercise for joins and union 1
--error
select
	a.customer_id as a_id,
	b.customer_id as b_id,
sum	(a.sales) as Total_Sales,
	b.state
from sales_2015 as a
full join customer_20_60 as b
on a.customer_id=b.customer_id
group by a.customer_id,b.customer_id,b.state
order by b.state 

--correct
select
sum	(a.sales) as Total_Sales,
	b.state
from sales_2015 as a
full join customer_20_60 as b
on a.customer_id=b.customer_id
group by b.state
order by Total_Sales asc
--for checking
select *
from sales_2015
where customer_id = 'AA-10315'

select * 
from customer_20_60
where customer_id = 'AA-10315'

--exercise for joins and union 2
select * 
from product

select *
from sales
where product_id = 'FUR-BO-10001798'

select
	a.product_id,
	a.product_name,
	a.category,
sum (b.sales) as total_sales,
sum (b.quantity) as total_quantity
from product as a
full join sales as b
on a.product_id=b.product_id
group by a.product_id,a.product_name,a.category
order by total_sales asc


--query within a query , where

select * from sales
where customer_id in
(select distinct customer_id 
from customer
where age > '60')

--query within a query , from
--correct syntax
select distinct
	a.product_id,
	a.product_name,
	a.category,
	b.quantity
from product as a
left join (select product_id, sum(quantity) as quantity
		  from sales
		  group by product_id
		  order by quantity desc) as b
on a.product_id=b.product_id
order by b.quantity desc 
-- end of correct syntax
--start of incorrect syntax
select distinct
	a.product_id,
	a.product_name,
	a.category,
	sum(b.quantity) as total_quantity
from product as a
left join sales as b
on a.product_id=b.product_id
group by a.product_id,a.product_name,a.category
order by total_quantity desc

select count (product_id) 
from sales
where product_id = 'FUR-BO-10001798'
--end of incorrect syntax

/* Select subquery*/

select customer_id, order_line, (select distinct customer_name from customer where customer.customer_id=sales.customer_id)
from sales
order by customer_id

/* Subquery Exercise */
/* Get data with all columns of sales table, and customer name, customer age, product name, and category are in in the same result 
(Use Join in Subquery)
*/

select a.*
from sales as a

select b.*
from customer as b 

select c.*
from product as c

select
		a.*,
		b.customer_name,
		b.age,
		(select distinct c.category from product as c where a.product_id=c.product_id),
		(select distinct c.product_name from product as c where a.product_id=c.product_id)
from sales as a
inner join customer as b
on a.customer_id=b.customer_id
group by a.* ,a.order_line, b.customer_name, b.age
order by a.order_line

select 
c.product_name,
c.category
from product as c
inner join
	(select 
		a.*,
		b.customer_name,
		b.age
	from sales as a
	inner join customer as b
	on a.customer_id=b.customer_id
	group by a.order_line, b.customer_name, b.age
	order by a.order_line) as z
on c.product_id=z.product_id
group by c.product_name, c.category, a.*, z.product_id
order by z.product_id




/*
SELECT *
FROM table1
JOIN (
   SELECT *
   FROM table2
   JOIN table3
   ON table2.column = table3.column
) subquery
ON table1.column = subquery.column;
*/

select a.customer_name, a.age, subquery.*
from customer as a 
left join (
	select b.*, c.product_name, c.category
	from sales as b
	right join product as c
	on b.product_id=c.product_id
) as subquery
on a.customer_id=subquery.customer_id

/*
SELECT *
FROM table1
JOIN table2 ON table1.column = table2.column
JOIN table3 ON table2.column = table3.column
*/

select *
from sales
join customer on sales.customer_id = customer.customer_id
join product on sales.product_id = product.product_id

select *
from sales
 join (select customer_id, customer_name, age from customer) as customer on sales.customer_id = customer.customer_id
 join (select product_id, product_name, category from product) as product on sales.product_id = product.product_id


/* View */

create or replace view logistics as 
select
	a.order_line,
	a.order_id,
	b.customer_name,
	b.city,
	b.state,
	b.country
from sales as a
left join customer as b
on a.customer_id=b.customer_id
order by a.order_line

select *
from logistics

drop view logistics

-- Cannot update view since it does not contain actual data
/*
update logistics
set country = 'US' 
where country = 'United States'
*/
 
/*
VIEW can be update under certain conditions which are given below-

1. The SELECT clause may not c ontain the keyword DISTINCT
2. The SELECT clause may not cointain summary functions 
3. the SELECT  clause may not contain set functions
4. The SELECT  clause may not contain set operators 
5. The SELECT  clause may not contain an ORDER BY clause
6. The FROM clause may not contain multiple tables
7. The WHERE clause may not contain subqueries
8. Calculated comlumns may not be updated 
9. All NOT NULL columns from the base table must be included in the view
in order for the INSERT query to function
*/

/*Index*/
create index mon_idx
on month_values(MM)

select *
from month_values

drop index mon_idx restrict


/* Exercise on Views */
select *
from sales
order by order_date asc

create or replace view Daily_Billing as 
select 
	order_line,
	product_id,
	sales,
	discount
from sales
order by order_date asc
limit 1

select *
from Daily_Billing
limit 1

drop view Daily_Billing

/* String Functions */
select customer_name, length (customer_name) as characters_num
from customer
where age > 30

--Lower and Upper

select lower ('gwen ebas')
select upper ('gwen ebas')

/*Replace*/
update customer
set country = replace (country, 'United States', 'US')

select country as new_country
from customer
/* Trim */

select trim(leading ' ' from '    Start-Tech Academy');
select trim(trailing ' ' from '    Start-Tech Academy      ') ;
select trim(both ' ' from '    Start-Tech Academy       ');
select trim ('    Start_Tech Academy   ');
select rtrim ('    Start-Tech Academy    ');
select ltrim('     Start-tech Academy    ');

/* Concatenate */
select customer_name,
	city || ', ' || state || ', ' || country as address
from customer

select city,state,country
from customer

/* Substring */
select 
	customer_id,
	customer_name,
	substring(customer_id for 2) as customer_group
from customer
where substring(customer_id for 2) = 'AB'

select 
	customer_id,
	customer_name,
	substring (customer_id from 4 for 5) as customer_number
from customer
where substring(customer_id for 2) = 'AB'


select 
	customer_id,
	customer_name,
	substring (customer_id from 4 for 5) as customer_number,
	substring(customer_id for 2) as customer_group
from customer
where substring(customer_id for 2) = 'AB'

/* String_Aggregate */
select * from sales order by order_id

select
	order_id,
	string_agg (product_id,',') as product_list,
	string_agg (customer_id, ' , ') as customer_ids,
	string_agg (order_date::text, ' , ') as dates_ordered
from sales
group by order_id
order by order_id

/* 
SELECT TO_CHAR(date_column, 'YYYY-MM-DD') AS formatted_date
FROM your_table;
 */
 
select to_char(order_date, 'YYYY-MM-DD') as formatted_date
from sales

/*
string_agg + to_char
*/

select
	order_id,
	string_agg(to_char(order_date, 'mm-dd-yyyy'), ' , ') as formatted_date,
	count ('formatted_date') as orders_made
from sales
group by order_id
order by orders_made desc

/* Exercise String Functions */

select * 
from product
order by product_name

-- 1.
select
	product_id,
	product_name,
	length(product_name) as product_char_num
from product
order by product_id

--2.
select
	product_name,
	sub_category,
	category,
	product_name || ',' || sub_category || ',' || category as product_details
from product
order by product_name

--3.
select *
from product

select
	product_id,
	substring(product_id from 1 for 3) as category_type,
	substring(product_id from 5 for 2) as sub_category_type,
	substring(product_id from 8) as prod_id
from product
order by product_id

--4.
select * from sales
select * from product


select
	sub_category,
	string_agg(product_name, ' , ') as product_lists
from product 
where sub_category = 'Chairs' or sub_category = 'Tables'
group by sub_category
order by sub_category

/* Ceil & Floor */
select
	order_line,
	sales,
	ceil (sales),
	floor(sales)
from sales
where discount > 0

/* Random */ -- a=10 ; b= 50
select random(), random()*40+10 , floor(random()*41)+10

/* Setseed */
select setseed(0.5)
select random()

/* Round */
select order_line,sales, round(sales)
from sales

/* Power */
select customer_name, age, power(age,2)
from customer

/* Exercise 14  */
--1.
select setseed (1)
select customer_name
from customer
order by random()
limit 5

select setseed (-1)
select customer_name
from customer
order by random()
limit 5

select customer_name
from customer
order by random()
limit 5

--2. 
	-- lower integer
select a.customer_name, a.customer_id,b.sales, floor(b.sales)
from customer as a 
join sales as b
on a.customer_id=b.customer_id
group by a.customer_name,a.customer_id, b.sales, floor(b.sales)
order by b.sales asc 

	-- upper integer
select a.customer_name, a.customer_id,b.sales, ceil(b.sales)
from customer as a 
join sales as b
on a.customer_id=b.customer_id
group by a.customer_name,a.customer_id, b.sales, ceil(b.sales)
order by b.sales asc 

-- rounding off integer
select a.customer_name, a.customer_id,b.sales, round(b.sales)
from customer as a 
join sales as b
on a.customer_id=b.customer_id
group by a.customer_name,a.customer_id, b.sales, round(b.sales)
order by b.sales asc 

/* Current Date Time */
select current_date
select current_time(3)
select current_timestamp

/* Age */
select age('2014-04-25', '2014-01-01') as age_diff
select 
	order_line,
	order_date,
	ship_date,
	age(ship_date,order_date) as time_taken
from sales
order by time_taken desc

/*Extract*/

select extract( epoch from timestamp '2023-05-15');

select 
	order_date,
	ship_date,
	(extract (epoch from ship_date) - extract(epoch from order_date)) as sec_taken
from sales

/* Exercise current time */
--1. age of batman who was born on April 6,1939

select age(current_date,'1939-05-06') as batman_age

--2.
select * from product
where sub_category = 'Chairs'
select * from sales

select
	   extract(month from a.order_date ) as month_ordered,
	   sum(round(sales)) as total_sales
from sales as a
join product as b 
on a.product_id = b.product_id
where sub_category = 'Chairs'
group by month_ordered
order by total_sales ASC

/* Pattern Matching */
--1st example
select *
from customer
where customer_name ~*'^a+[a-z\s]+$';

--2nd example
select *
from customer
where customer_name ~* '^(a|b|c|d)+[a-z\s]+$';

--3rd example
select distinct * 
from customer
where customer_name ~* '^(a|b|c|d)[a-z]{3}\s[a-z]{4}$';

--4th example
create table users (name varchar)
select * from users

drop table users
insert into users (name)
values ('Alex'), ('Jon Snow'), ('Christopher'), ('Arya'), ('Sandip Debnath'),
('Lakshmi'), ('alex@gmail.com'), ('@sandip5004'), ('lakshmi@gmail.com')
`
select *
from users
where name ~*'^[a-z0-9\.\-\_]+@[a-z0-9\-]+\.[a-z]{2,5}';
`
/* Exercise Pattern Matching */
--1
select *
from customer
where customer_name ~* '^[a-z]{5}\s(a|b|c|d)[a-z]{4}$';

select * from customer
where customer_name ~* '^[a-z]+\s(a|b|c|d)[a-z]{4}$';

--2
create table zipcode(PIN_ZIP_codes varchar);
drop table zipcode
insert into zipcode
values ('234432'),('23345'),('sdfe4'),('123&3'),('67424'),('7895432'),('12312');

select * from zipcode

select * from zipcode
where pin_zip_codes ~* ('^[0-9]{5,6}$');

/* Window Function */
select * from sales

select * from customer

select * from(
select
	a.customer_id,
	a.customer_name,
	a.state,
	b.quantity,
	sum(round(sales)) as sales,
	row_number()
over(
	partition by a.state
	order by sales desc) as row
from customer as a
join sales as b
on a.customer_id=b.customer_id
group by a.customer_id, a.customer_name, a.state, b.quantity,b.sales
) as c where c.row<=3;

/*Rank & DenseRank*/
--Rank
select * from(select 
	a.customer_id,
	a.customer_name,
	a.state,
	b.quantity,
	sum(round(sales)) as sales,
	rank()
over(partition by a.state
	order by sales desc) as ranks
from customer as a
join sales as b
on a.customer_id=b.customer_id
group by a.customer_id, a.customer_name, a.state, b.quantity, b.sales)as c
where c.ranks <=10; 

--DenseRank

select * from(select 
	a.customer_id,
	a.customer_name,
	a.state,
	b.quantity,
	sum(round(sales)) as sales,
	dense_rank()
over(partition by a.state
	order by sales desc) as dense_ranks
from customer as a
join sales as b
on a.customer_id=b.customer_id
group by a.customer_id, a.customer_name, a.state, b.quantity, b.sales)as c
where c.dense_ranks <=10; 

/* Ntile */

select * from (
select 
	a.customer_id,
	a.customer_name,
	a.state,
	b.quantity,
	sum(round(sales)) as sales,
	ntile(4)
over(partition by a.state
	order by sales desc) as n_tile
from customer as a
join sales as b
on a.customer_id=b.customer_id
group by a.customer_id, a.customer_name, a.state, b.quantity, b.sales) as c
where c.n_tile = 2;

/* Average */

select * from (
select 
	a.state,
	avg(sales)
over(partition by a.state) as avg_sales
from customer as a
join sales as b
on a.customer_id=b.customer_id
group by a.state, b.sales) as c;

/* Count */

select * from (
select distinct
	a.customer_id,
	a.customer_name,
	a.state,
	count(a.customer_id)
over(partition by a.state) as count_cust
from customer as a
order by count_cust asc) as c;

/* Sum Total*/
select * from (
select 
	a.order_id,
	max(a.customer_id) as customer_id,
	max(a.order_date) as order_date,
	b.state,
	sum(a.sales) over(partition by b.state) as sales	
from sales as a
join customer as b
on a.customer_id=b.customer_id
group by a.order_id, b.state, a.sales) as c

/* Running Total*/
select * from (
select
	max(a.customer_id) as customer_id,
	max(a.order_date) as order_date,
	b.state,
	a.sales,
	sum(a.sales) over(partition by b.state) as tot_sales,
	sum(a.sales) over(partition by b.state
					 order by a.order_date asc) as ordered_sales	
from sales as a
join customer as b
on a.customer_id=b.customer_id
group by a.order_date, b.state, a.sales) as c


/* Lag & Lead*/

select * from (
select
	max(a.customer_id) as customer_id,
	max(a.order_date) as order_date,
	b.state,
	a.sales,
	sum(a.sales) over(partition by a.customer_id) as tot_sales,
	lag(a.sales,2) over(partition by a.customer_id
					 order by a.order_date asc) as lagged_sales	,
	lead(a.sales,2) over(partition by a.customer_id
					  order by a.order_date asc) as lead_sales
from sales as a
join customer as b
on a.customer_id=b.customer_id
group by a.customer_id, a.order_date, b.state, a.sales) as c

-- example 1

select customer_id, order_date, order_id, sales,
lag(sales,1) over(partition by customer_id order by order_date) as previous_sale,
lag(order_id,1) over(partition by customer_id order by order_date) as previous_order
from sales

/*Convert Number Date to String */
select sales, to_char(sales,'09999.99')
from sales

select sales, 'Total sales value for this order is '|| to_char(sales,'l9,999.99')
from sales

select order_date,to_char(order_date,'MMDDYYYY')
from sales

select order_date, to_char(order_date,'Month DD,YYYY')
from sales

/*Converting String to Numbers Date*/

select to_date('2014/04/25', 'YYYY/MM/DD')

select to_date('26122018', 'DDMMYYYY')

/* String to Number*/

select to_number('1210.73', '99999.99')


select to_number('$1,210.73', 'L99,999.99')