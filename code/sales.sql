use ev_data;
select * from sales; 
select * from products;

drop table if exists sprint_sales;
create temporary table sprint_sales
 select date( sales_transaction_date) as sales_date, count(product_id) as no_sold 
 from(
select p.product_id,p.model, s.sales_transaction_date
from  products p 
join sales s on p.product_id = s.product_id 
where p.model ='sprint')x 
group by 1 order by 1 ;

select * from sprint_sales;


-- 7 days cumulative sales volume 
drop table if exists  cumu_7_sales;
create table cumu_7_sales
select sales_date, no_sold, sum(no_sold)over(order by sales_date rows between 6 preceding and current row ) as sum_last_7_sold
from sprint_sales;

select * from cumu_7_sales;

-- percentage change 
drop table if exists percentage_7_change;
create table percentage_7_change
select *,row_number()over(order by sales_date) as day_since_launch, case when lag(sum_last_7_sold)over(order by sales_date) is null then null
 else ((sum_last_7_sold - lag(sum_last_7_sold)over(order by sales_date) ) /(lag(sum_last_7_sold)over(order by sales_date))) end as percent
 from cumu_7_sales;
 
 select * from percentage_7_change;
 
--  a. What is the cumulative sales volume (in units) of Sprint Scooter for the first 7 days 
-- between 10-10-2016 and 16-10-2016?
-- ans. 64 

select sum_last_7_sold as cumulative_sales from cumu_7_sales
where sales_date = '2016-10-16' ;

-- b. On 20th Oct 2016, What are the last 7 days' Cumulative Sales of Sprint Scooter (in units)?
-- ans. 71
 select sum_last_7_sold as cumulative_sales from cumu_7_sales where sales_date = '2016-10-20';
 
 -- c. On which date did the sales volume of Sprint Scooter reach its highest point? 
 -- ans. 2016-10-16
 
 select sales_date from sprint_sales where sales_date between '2016-10-10' and '2016-10-31' group by sales_date order by max(no_sold) desc limit 1;
 
--  d. On 22-10-2016 by what percentage, cumulative sales of last 7 days dropped compared to last 7
-- days cumulative sales on 21-10-2016 ?
-- ans. -0.1111

select percent from percentage_7_change where sales_date = '2016-10-22';

-- e. No of Units of Sprint Scooters sold in the month of Oct-16 is
-- ans. 160

select month(sales_date)as month , sum(no_sold) as no_units from sprint_sales where year(sales_date) = '2016' group by 1;

-- f. The highest cumulative sales in the last seven days for Sprint Scooter sold is ------- on ------
-- ans. 21 and 21-10-2016

select max(sum_last_7_sold) as highest_cumulative , sales_date  
from percentage_7_change where year(sales_date) = '2016' and month(sales_date) = '10' 
group by 2 order by 1 desc limit 1; 

-- sprint limited edition model 

drop table if exists sprint_limited;
create table sprint_limited 
 select date( sales_transaction_date) as sales_date, count(product_id) as no_sold 
 from(
select p.product_id,p.model, s.sales_transaction_date
from  products p 
join sales s on p.product_id = s.product_id 
where p.model ='Sprint Limited Edition')x 
group by 1 order by 1 ;

select * from sprint_limited;

-- cumulative sum 
drop table if exists cum_limited;
create table cum_limited 
select sales_date, no_sold, sum(no_sold)over(order by sales_date rows between 6 preceding and current row ) as sum_last_7_sold
from sprint_limited;

select * from cum_limited;

-- percentage change limited edition 
drop table if exists percentage_7_le;
create table percentage_7_le 
select *,row_number()over(order by sales_date) as day_since_launch, case when lag(sum_last_7_sold)over(order by sales_date) is null then null
 else ((sum_last_7_sold - lag(sum_last_7_sold)over(order by sales_date) ) /(lag(sum_last_7_sold)over(order by sales_date))) end as percent
 from cum_limited;
 
 -- comapring sprint with limited edition 
 select * from percentage_7_le;
 select  p1.day_since_launch, p1.no_sold as no_sold_sprint, p1.sum_last_7_sold as last_7_days_sprint, 
    p2.no_sold as no_sold_le, p2.sum_last_7_sold as last_7_days_le, p1.percent as sprint_percent_change, p2.percent as le_percentage_change
 from percentage_7_change  p1 
 join percentage_7_le p2 
 on p1.day_since_launch = p2.day_since_launch;
 