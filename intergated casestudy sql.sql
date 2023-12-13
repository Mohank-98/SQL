   
   select * from transdata
select * from [dbo].[custdata]

 --Drop the observations(rows) if MCN is null or storeID is null or Cash_Memo_No

delete from transdata
where mcn is null or store_id is null or cash_memo_no is null

--Join both tables considering Transaction table as base table and name the table as Final_Data

select * into finaldata from (select * from transdata t left join custdata c on t.mcn = c.custid)t;

--Q1. Count the number of observations having any of the variables is having null value/missing values?

 select count(*) count_of_null from finaldata
 where itemcount is null or transactiondate is null or 
 totalamount is null or saleamount is null or 
 salepercent is null or cash_memo_no is null or dep1amount is null or 
 dep2amount is null or dep3amount is null or dep4amount is null or
 Store_ID is null or mcn is null or custid is null or 
 gender is null or [location] is null or 
 age is null or cust_seg is null or sample_flag is null;

 --Q2. How many customers have shopped? 
 
select count(distinct mcn) count_of_customer from finaldata
where store_id is not null;

--Q3.  How many shoppers (customers) visiting more than 1 store?

 select count(*) countcustomer from 
 (
   select mcn from finaldata
   group by mcn
   having count(distinct store_id)>1)t;

--Another    
   select count(*),mcn from finaldata
   group by mcn
   having count(distinct store_id)>1;

--Q4.   What is the distribution of shoppers by day of the week? How the customer shopping 
--behavior on each day of week?

select count(distinct mcn) No_of_customer,count(Cash_Memo_No) No_of_transaction,
sum(saleamount) Total_sale_amt,sum(itemcount) total_Qty,datepart(weekday,transactiondate) [weekday]
from finaldata
group by datepart(weekday,transactiondate)
order by [weekday];

--Another

select count(distinct mcn) No_of_customer,count(Cash_Memo_No) No_of_transaction,
sum(saleamount) Total_sale_amt,sum(itemcount) total_Qty,datename(weekday,transactiondate) [weekday]
from finaldata
group by datename(weekday,transactiondate)
order by weekday;

--Q5.  What is the average revenue per customer/average revenue per customer by each location?

select mcn,location,avg(saleamount) avg_sale_amt from finaldata
group by mcn,location; 

--Q6.  Average revenue per customer by each store etc?

select mcn,store_id,avg(saleamount) avg_sale_amt from finaldata
group by mcn,store_id;

--Q7. Find the department spend by store wise?

select store_id, sum(dep1amount)Det_1_amt,sum(dep2amount)Dep_2_Amt,sum(dep3amount)Dep_3_Amt,
sum(dep4amount)Dep_4_Amt from finaldata
group by store_id
order by store_id;

--Q8. What is the Latest transaction date and Oldest Transaction date?

select max(transactiondate) Latest_trans_date, min(transactiondate) Oldest_trans_date 
from finaldata;

--Q9. How many months of data provided for the analysis?

select datediff(month,min(transactiondate),max(transactiondate))+1 months from finaldata

--Q10. Find the top 3 locations interms of spend and total contribution of sales out of total sales?

select location, sum(saleamount) total_sales,sum(dep1amount)Det_1_amt,sum(dep2amount)Dep_2_Amt,
sum(dep3amount)Dep_3_Amt,sum(dep4amount)Dep_4_Amt from finaldata
group by [location]
order by total_sales desc;

--Another

select *,(total_sales/(select sum(saleamount) from finaldata))*100 percent_of_sales from
(select top 3 location,sum(saleamount) total_sales,sum(dep1amount)Det_1_amt,sum(dep2amount)Dep_2_Amt,
sum(dep3amount)Dep_3_Amt,sum(dep4amount)Dep_4_Amt from finaldata
group by [location]
order by total_sales desc)t1

--Q11. Find the customer count and Total Sales by Gender?

select gender,count(distinct mcn) No_of_customer,sum(saleamount) Total_sales from finaldata
group by gender;       --distinct customer

--Q12. What is total  discount and percentage of discount given by each location?

select [location],total_discount,discounter from (
 select rank() over (partition by [location] order by total_discount desc) rnk,
 [location],total_discount,discounter from (
select [location],sum((totalamount)-(saleamount)) as  total_discount,
 salepercent*100 as discounter  from finaldata
group by [location],salepercent)t)t      --salepercent)t)t
where rnk ='1';

--Q13. Which segment of customers contributing maximum sales?

select Age,max(saleamount) max_sales from finaldata
group by age
order by max_sales desc;

--Another

select cust_seg,sum(saleamount) max_sales from finaldata
group by cust_seg
order by max_sales desc;


--Q14. What is the average transaction value by location, gender, segment?

select [location],Gender,age,avg(totalamount) Avg_transaction from finaldata
group by [location],gender,age

--Another

select [location],Gender,age,(sum(totalamount)/count(cash_memo_no)) Avg_transaction from finaldata
group by [location],gender,age


--Q15. Create Customer_360 Table with below columns.

create table customer_360
(
customer_id int,
gender varchar(10),
[location] varchar(50),
age int,
cust_seg varchar(50),
no_of_transactions int,
no_of_items int,
total_sale_amount decimal(20,2),
TotalSpend_Dep1 decimal(20,2),
TotalSpend_Dep2 decimal(20,2),
TotalSpend_Dep3 decimal(20,2),
TotalSpend_Dep4 decimal(20,2),
No_Transactions_Dep1 int,
No_Transactions_Dep2 int,
No_Transactions_Dep3 int,
No_Transactions_Dep4 int,
No_Transactions_Weekdays int,
No_Transactions_Weekends int,
Rank_based_on_Spend int,
decile int
);

select * from customer_360

--d. Filter the Final_Data using sample_flag=1 and export this data into Excel File and call this table as sample_data

select * into sample_data from finaldata
where sample_flag = 1

select * from sample_data
select * from finaldata

