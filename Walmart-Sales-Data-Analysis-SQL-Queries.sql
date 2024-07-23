create database if not exists SalesDataWalmart;
use SalesDataWalmart;

create table if not exists sales(
invoice_id varchar(30) not null primary key, 
branch Varchar(5) not null,
city Varchar(30) not null,
customer_type Varchar(30) not null,
gender Varchar(10) not null,
product_line Varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
vat float(6,4) not null,
total decimal(12,4) not null,
date datetime not null,
time Time not null,
payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9),
gross_income decimal(12,4) not null,
rating float(2,1)
); 
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- ----------------Feature Engineering-------------------------

-- ---------------
-- time_of_day----

SELECT 
  time,
  CASE 
    WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
    ELSE 'Evening' 
  END AS time_of_day
FROM sales;


select time_of_day from sales where time_of_day = "Afternoon";
alter table sales add column time_of_day varchar(30);

update sales set time_of_day= 
 CASE 
    WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
    ELSE 'Evening' 
  END
;

-- ---------------
-- day_name-------

 select date, dayname(date) as day_name from sales;

alter table sales add column day_name varchar(10);

update sales set day_name = dayname(date);

-- ---------------
-- month_name-----

select date, monthname(date) from sales;

alter table sales add column month_name varchar(10);

update sales set month_name = monthname(date);
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- -----------------------Generic------------------------------

-- How many unique cities does the data have?
select distinct(city) from sales;

-- In which city is each branch?
select distinct(city), branch from sales;
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- ----------------------Product-------------------------------

-- How many unique product lines does the data have?
select count(distinct(product_line)) from sales;

-- What is the most common payment method?
select payment_method,count(payment_method) from sales
group by payment_method
order by count(payment_method) desc;

-- What is the most selling product line?
select product_line,count(product_line) 
from sales 
group by product_line
order by count(product_line) desc;

-- What is the total revenue by month?
select month_name as month, sum(total) as total_revenue
from sales
group by month_name;

-- What month had the largest COGS?
select month_name, sum(cogs) as total_cogs
from sales
group by month_name
order by sum(cogs) desc
limit 1;

-- What product line had the largest revenue?
select product_line, sum(total) as total_revenue 
from sales
group by product_line
order by sum(total) desc
limit 1;

-- What is the city with the largest revenue?
select city, sum(total) from sales
group by city
order by sum(total) desc
limit 1;

-- What product line had the largest VAT?
select product_line, sum(vat) from sales
group by product_line
order by sum(vat) desc
limit 1;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales?
SELECT product_line,
       total,
       CASE
           WHEN total > (SELECT AVG(total) FROM sales) THEN 'Good'
           ELSE 'Bad'
       END AS sales_performance
FROM sales;


-- Which branch sold more products than average product sold?
select branch, sum(quantity) as qty from sales
group by branch 
having sum(quantity) > avg(quantity)
order by sum(quantity) desc; 


-- What is the most common product line by gender?
select gender, product_line, count(gender) as total_count
from sales
group by gender, product_line
order by total_count;

-- What is the average rating of each product line?
select product_line, round(avg(rating),2) as avg_rating
from sales 
group by product_line
order by avg_rating desc; 
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- ----------------------Sales---------------------------------

-- Number of sales made in each time of the day per weekday
select time_of_day, count(total) as total_sales
from sales
where day_name="monday"
group by time_of_day
order by total_sales desc;

-- Which of the customer types brings the most revenue?
select customer_type, round(sum(total),2) as total_revenue
from sales 
group by customer_type
order by total_revenue desc;

-- Which city has the largest tax percent/ VAT (**Value Added Tax**)?
select city, avg(vat) as vat
from sales
group by city
order by vat desc;

-- Which customer type pays the most in VAT?
select customer_type, avg(vat) as vat
from sales
group by customer_type
order by vat desc;
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- ----------------------Customer------------------------------

-- How many unique customer types does the data have?
select count(distinct customer_type) as no_of_unique_cust
from sales;

-- How many unique payment methods does the data have?
select count(distinct payment_method) as no_of_payment_method
from sales;

-- What is the most common customer type?
select customer_type, count(customer_type) as common_customer_type 
from sales
group by customer_type
order by common_customer_type desc;

-- Which customer type buys the most?
select customer_type, sum(quantity) as total_quantity
from sales
group by customer_type
order by total_quantity desc;  

-- What is the gender of most of the customers?
select gender, count(total) as total_customers
from sales
group by gender
order by total_customers desc;

-- What is the gender distribution per branch?
select gender, branch, count(total) as total_customers
from sales
group by gender, branch
order by total_customers desc;

-- Which time of the day do customers give most ratings?
select time_of_day, avg(rating) as total_rating
from sales
group by time_of_day
order by total_rating desc;

-- Which time of the day do customers give most ratings per branch?
select time_of_day, branch, avg(rating) as total_rating
from sales
group by time_of_day, branch
order by total_rating desc;

-- Which day of the week has the best avg ratings?
select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

-- Which day of the week has the best average ratings per branch?
select day_name, branch, avg(rating) as avg_rating
from sales
group by day_name, branch
order by avg_rating desc;

-- ------------------------------------------------------------
-- ------------------------------------------------------------