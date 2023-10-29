/*    1.Perform some Basic EDA using MySQL workbench to familiarize yourself with the data sets */

-- a. How many different models of scooter and automobile did the company produce
         
select product_type, count( distinct model) 
from products 
group by product_type;

 -- b. Which model’s production was stopped in the shortest amount of time

select *, timestampdiff(day,str_to_date(production_start_date,'%d-%m-%Y'),str_to_date(production_end_date,'%d-%m-%Y')) as duration
from products ;   
 -- ANS : FIoNex scooter : 86 days   

-- c. Which model and product has the costliest base model
select model 
from products 
where base_price = (select max(base_price) from products);
-- ANS :	DeltaPlus

-- d. Identify the top 3 customers based on the number of products purchased. 
with cte as 
(select customer_id, count(sales_transaction_date) as no_od_purchase, 
dense_rank()over(order by count(sales_transaction_date) desc) as rnk 
from sales group by customer_id)

select * from cte where rnk in (1,2,3);


-- e. How many such top 3 customers (by units purchased) exists ?
with cte as 
(select customer_id, count(sales_transaction_date) as no_od_purchase, 
dense_rank()over(order by count(sales_transaction_date) desc) as rnk 
from sales group by customer_id)

select count(distinct customer_id) from cte where rnk in (1,2,3);
-- ANS : 307

-- f. Identify the top 3 customers based on total value of products purchased
with cte as 
(select s.customer_id, sum(p.base_price) as amount, dense_rank()over(order by sum(p.base_price) desc ) as top_customers 
from products p 
join sales s on s.product_id = p.product_id 
group by s.customer_id order by amount desc)

select * from cte where top_customers <=3;

 
 -- g. How many such top 3 customers ( by value) exists
with cte as 
(select s.customer_id, sum(p.base_price) as amount, dense_rank()over(order by sum(p.base_price) desc ) as top_customers 
from products p 
join sales s on s.product_id = p.product_id 
group by s.customer_id order by amount desc)

select count(distinct customer_id) from cte where top_customers <=3
-- ANS : 4 


/*   2. Perform some basic visualization using excel and answer these questions  */

--a. Which channel of sales is bringing the maximum sales ( unit wise)
select channel, count(customer_id) as units   from sales group by channel;


-- b. Trace the daily sales of the ‘sprint’ scooter model since its launch. Trace the daily sales for only for the month in which this model was launch. I.e is the model was launched in 2016 october, so show the trend line of the daily sales for the October 2016 month only.
select date(x.sales_transaction_date) as sales_data , count(x.product_id)
from (
select s.sales_transaction_date, s.product_id
from sales s 
join  products p on p.product_id = s.product_id
where p.model = 'Sprint' and  s.sales_transaction_date between '2016-10-10' and '2016-10-31')x
group by 1 order by 1;


