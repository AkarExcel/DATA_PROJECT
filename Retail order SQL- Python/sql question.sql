SELECT * 
FROM df_orders

-- find the top 10 revenue generating product
SELECT TOP 10 product_id, SUM(sale_price) AS Sales
FROM df_orders
GROUP BY product_id
ORDER BY SUM(sale_price) DESC

-- find top 5 highest selling product in each region
with cte_region_product AS
(
SELECT region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id
) 
select * from (
select * ,
ROW_NUMBER() OVER(partition by region order by sales desc) as rn
from cte_region_product) A
where rn <= 5

-- find the month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte as (
select YEAR(order_date)as order_year ,Month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by YEAR(order_date) ,Month(order_date)
)
SELECT Order_month, 
 sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
 sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from CTE
Group by Order_month

-- For each category which month has the highest sales
WITH cte as (
SELECT category, format(order_date,'yyyy-MM') as order_month, sum(SALE_PRICE) as sales
FROM df_orders
GROUP BY format(order_date,'yyyy-MM'), category
)
Select * from 
(select *, 
ROW_NUMBER() OVER (partition by category order by sales) as rn
from CTE
) as a
Where rn = 1

-- which sub category has the highest growth by profit in 2023 compare to 2022
WITH cte as (
select sub_category, YEAR(order_date)as order_year ,
sum(profit) as profits
from df_orders
group by sub_category ,Year(order_date)
) , cte2 as (
SELECT sub_category, 
 sum(case when order_year = 2022 then profits else 0 end) as profits_2022,
 sum(case when order_year = 2023 then profits else 0 end) as profits_2023
from CTE
Group by sub_category)
Select top 1 *,
(profits_2023-profits_2022)*100/profits_2022 as change_in_profit
from cte2
order by (profits_2023-profits_2022)*100/profits_2022 desc