/* The data set was from ANil that I found in Kaggle */
/*Title: E-Commerce Sales DataSet*/
create table aws (index int, order_ID varchar, Date date, Status varchar,
				 Fulfilment varchar, Sales_Channel varchar, ship_service_level 
				 varchar, Style varchar, SKU varchar, Category varchar, Size
				 varchar, ASIN varchar, Courier_Status varchar, Qty int, currency 
				 text, Amount numeric, ship_city text, ship_state varchar, ship_postal_code numeric,
				  ship_country text, promotion_ids varchar, B2B text, fulfilled_by text)
				 
copy aws from 'C:\Users\ADMIN\Desktop\Edited\AWS.csv' delimiter ',' csv header;
-- to check if the copy was succesful
select * from aws
-- need to remove the column due to unnecessary information
alter table aws
drop column promotion_ids

-- need to create a second table where isr = international sales report
create table isr (index int, date date, months varchar, customer varchar, style varchar, sku varchar,
				  size text, pcs int, rate numeric, gross_amt numeric, stock int)
copy isr from 'C:\Users\ADMIN\Desktop\Edited\ISR-edited.csv' delimiter ',' csv header;
-- to check if the copy was succesful
select * from isr
-- need to create a third table where sr = sales report
create table sr (index int, sku_code varchar, design_no varchar, stock int, category varchar, size text, color text)
copy sr from 'C:\Users\ADMIN\Desktop\Edited\SR.csv' delimiter ',' csv header;
-- to check if the copy was succesful
select * from sr
--there are cells that are labled as '#REF!', instead it was updated to '[null]'
alter table sr
update sr set sku_code = '[null]'
where sku_code = '#REF!'

select status from aws

/*from here, I would like to know which order id had the highest amount and qty ordered*/
/*this would give me an idea on the top order ids that were considered vip since they have the largest contribution to the business*/
/*it is also important to recognize the name of the customer*/

select 
	a.order_id,
	a.style,
	a.status,
	a.sku,
	a.category,
	a.qty,
	a.amount,
	(a.qty * a.amount) as total,
	b.customer,
	b.sku,
	c.design_no
from aws as a
join isr as b on a.index=b.index
join sr as c on a.index=c.index
where a.amount is not null and a.status <> 'Cancelled'
order by (a.qty * a.amount) desc

select
	(a.qty * a.amount) as total,
	b.customer,
	sum(a.qty * a.amount) over(partition by b.customer) as grand_total
from aws as a
full join isr as b
on a.index=b.index
where b.customer is not null
order by grand_total desc

/* next is I want to know which category has the highest amount and grand total
 grand total = sum of total by category*/

select 
	order_id, style, status, sku, category, qty, amount, (qty * amount) as total,  
	count(category) over(partition by category) as category_count,
	sum(qty * amount) over (partition by category) as grand_total
from aws
group by category, order_id, style, status, sku, category, qty, amount
order by category

/* I can now clearly see that Kurta from the category has the highest amount equal to 49874 while the lowest quantity is bottom 
   This would give me an idea on the demand based on category*/
   
select *
from aws as a
join(select * from isr) as b on a.index=b.index
join(select * from sr) as c on a.index=c.index

/* I want to know which year has the highest gross. However, it appears that all gross was made on year 2022 */

select 
	index,
	order_id,
	date,
	extract (year from date) as year,
	count(order_id) over(partition by (extract (year from date))) as count
from aws
where extract (year from date) = '2022'

/* Instead, I want to know it by month */

select 
	index,
	order_id,
	date,
	extract (month from date) as month,
	count(order_id) over(partition by (extract (month from date))) as count
from aws
where extract (month from date) = '4'

/* Based on this info, the query showed that most transactions were made on the 4th month of the year 2022 */