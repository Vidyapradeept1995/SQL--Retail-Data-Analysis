select * from CAMPAIGN
select * from demographic
select * from CAMPAIGN_DESC
select * from PRODUCT
select * from TRANSACTION_d
select * from coupon
select * from COUPON_REDEMPT

1. Customer Demographics KPIs:
o Count of unique households: Measure the total number of unique households in the Demographic table.

sol:
select count(distinct (household_key)) as unique_household from demographic


o Household composition distribution: Analyze the distribution of household 
compositions (HH_COMP_DESC) to understand the composition of households.
Sol:

Select HH_COMP_DESC, Count(Household_size_desc) as Total_count, from Demographic
Group by HH_COMP_DESC

(or)

Select HH_COMP_DESC, Count(Household_key) as Total_count from Demographic
Group by HH_COMP_DESC


o Age distribution: Calculate the percentage or rcount of customes in different age 
groups (AGE_DESC).
Sol:

select age_desc,count(household_key) as cx_count,
count(household_key)*100.0/(select count(*) from demographic) as perc
From demographic
Group by age_desc

(or)

with cte as 
(
select age_desc,count(household_key) as cx_count
From demographic
Group by age_desc
),
total as 
(
select count(household_key) as total from demographic
)
select age_desc, cx_count, (cx_count*1.0/total) *100 as perc from cte,total



o Marital status distribution: Analyze the proportion of customers in different 
marital status categories (MARITAL_STATUS_CODE).

select Marital_status_code,count(household_key) as cx_count,
count(household_key)*100.0/(select count(*) from demographic) as perc
From demographic
Group by Marital_status_code



o Income distribution: Determine the distribution of customers across income levels 
(INCOME_DESC).
Sol:
select Income_desc, count(household_key) No_of_cx,
count(household_key)*100/(select count(*) from demographic) as perc
from demographic
Group by Income_desc


o Homeownership distribution: Calculate the percentage or count of customers who 
own or rent their homes (HOMEOWNER_DESC).

select Homeowner_desc, count(household_key) as no_of_cx, 
count(household_key)*100/(select count(*) from demographic) as perc
from demographic
Group by Homeowner_desc
 (OR)

 select Homeowner_desc, count(household_key) as no_of_cx, 
 (count(household_key)*100/sum(count(*)) over ()) as perc
 from demographic
Group by Homeowner_desc


2. Campaign KPIs: select * from CAMPAIGN_DESC
select * from CAMPAIGN
o Number of campaigns: Count the total number of campaigns in the Campaign table.
Sol:
 select count(campaign) as total_no_campaigns from campaign


o Campaign duration: Calculate the duration of each campaign by subtracting the 
start day from the end day (in the Campaign_desc table).
Sol:
select campaign,(End_day-Start_day)/30 as duration_inmonths from Campaign_desc
order by campaign Asc
(OR)
select campaign, (End_day-Start_day) as duration_indays from Campaign_desc
order by campaign Asc


o Campaign effectiveness: Analyze the number of households associated with each 
campaign (in the Campaign table) to measure campaign reach.
Sol:
Select campaign, count(household_key) as No_of_households
From campaign
Group by campaign
order by campaign

3. Coupon KPIs:
select * from coupon
select * from COUPON_REDEMPT

o Coupon redemption rate: Calculate the percentage of coupons redeemed (from the 
coupon_redempt table) compared to the total number of coupons distributed (from 
the Coupon table).
Sol:


select count(distinct coupon_upc)*100.0/(select count (distinct(coupon_upc)) from coupon)
from
coupon_redempt

(or)

with cte as(
select count(distinct coupon_UPC) count1 from coupon_redempt
),
cte2 as
(
select count(distinct coupon_UPC) count2 from coupon
)
select count1*100.0/count2 from cte,cte2

(or)

select count(distinct c.coupon_upc) as tot_dis_cp,
count(distinct cr.coupon_upc) as total_red_cp,
  (count(distinct cr.coupon_upc)*100.0/count(distinct c.coupon_upc))
 AS Redemption_Perc from coupon c left join 
  coupon_redempt cr on c.COUPON_UPC = cr.COUPON_UPC;

o Coupon usage by campaign: Measure the number of coupon redemptions (from 
the coupon_redempt table) for each campaign (in the Coupon table).
Sol:

SELECT count(cr.coupon_upc) No_of_coupredem ,c.campaign
FROM Coupon_redempt cr Join coupon c on c. campaign= cr.campaign
group by c.campaign
order by campaign Asc 

(or)

select count(coupon_upc) No_of_coupredem, campaign from coupon_redempt 
group by campaign
order by campaign Asc


select * from Transaction_d
4. Product KPIs:
o Sales value: Calculate the total sales value for each product (in the 
Transaction_data table) to identify top-selling products.
Sol:

Select product_id, sum(sales_value) tot_sales
from transaction_d 
Group by product_id
order by tot_sales Desc

/*(or)*/

select * from 
(
select product_id, sales_value,
sum(sales_value) over(partition by product_id) as tot_sales
from transaction_d 
)a
order by Tot_sales desc

select * from PRODUCT
o Manufacturer distribution: Analyze the distribution of products across different 
manufacturers (in the Product table).
sol:
select manufacturer, count(product_id) as no_of_products
from product
Group by MANUFACTURER


o Department-wise sales: Measure the sales value by department (in the Product 
table) to understand which departments contribute most to revenue.
Sol:
select p.department,sum(t.sales_value) as tot
from product p Join Transaction_d t on p.product_id=t.product_id
Group by p.department


o Brand-wise sales: Calculate the sales value for each brand (in the Product table) to 
identify top-selling brands.
Sol:
select p.brand,sum(t.sales_value) as tot
from product p Join Transaction_d t on p.product_id=t.product_id
Group by p.brand
order by tot desc

**Customer Spending Segmentation**: I created Household segments based on 
their spending patterns to help businesses understand who their high-value 
customers are.

  SELECT Household_key, COUNT(product_id) AS total_orders, SUM(sales_value) AS total_spent
  FROM Transaction_d
  GROUP BY Household_key
  HAVING SUM(sales_value) > 1000
  ORDER BY total_spent DESC;

5. Transaction KPIs:
o Total sales value: Calculate the sum of sales values (in the Transaction_data table) 
to measure overall revenue.
Sol:
select sum(sales_value) as Tot_sum
from transaction_d

o Average transaction value: Calculate the average sales value per transaction to 
understand customer spending patterns.
sol:
select product_id, Avg(sales_value) avg_value from transaction_d
group by product_id

o Quantity sold: Measure the total quantity sold (in the Transaction_data table) to 
understand product demand.
sol:
select product_id,sum(quantity) as tot_quantity from transaction_d
group by product_id

o Discounts: Analyze the amount and impact of discounts (RETAIL_DISC, 
COUPON_DISC, COUPON_MATCH_DISC) on sales value
sol:

select sum(retail_disc+coupon_disc+coupon_match_disc) as tot_disc,
sum(sales_value) as tot_sales, 
(sum(retail_disc+coupon_disc+coupon_match_disc)/sum(sales_value))*100 as discount_perc
from transaction_d

*/explaination:The discount_perc is 17% of tot_sales*/
