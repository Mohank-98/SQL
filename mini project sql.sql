--SQL Advance Case Study


--Q1--BEGIN

 select ln.state  from fact_transactions as ts
 join dim_location as ln on ln.idlocation = ts.idlocation
 where [date] between '2005-01-01' and getdate();

--Q1--END

--Q2--BEGIN
	
select top 1 state,count(quantity) qty from fact_transactions as ts
left join dim_location as ln on ln.idlocation = ts.idlocation
left join dim_model as ml on ml.idmodel=ts.idmodel
left join dim_manufacturer as mr on mr.IDManufacturer=ml.IDManufacturer
where ln.country ='us' and manufacturer_name = 'samsung'
group by state;

--Q2--END

--Q3--BEGIN      

select state,model_name,zipcode,count(totalprice) no_of_trans from fact_transactions as ts
left join dim_model ml on ml.IDModel=ts.IDModel
left join dim_location ln on ln.IDLocation=ts.IDLocation
group by model_name, zipcode, state;

--Q3--END

--Q4--BEGIN

select top 1 manufacturer_name,model_name,unit_price from dim_model as ml
left join dim_manufacturer as mr on mr.IDManufacturer=ml.IDManufacturer
group by manufacturer_name,model_name,unit_price
order by unit_price;

--Q4--END

--Q5--BEGIN

select ml.model_name,avg(unit_price) from dim_model as ml
left join dim_manufacturer as mr on mr.idmanufacturer=ml.IDManufacturer
where manufacturer_name in (select manufacturer_name from 
(select top 5 manufacturer_name,sum(quantity) total_revenue,avg(totalprice) avg_price from fact_transactions as ts
left join dim_model as ml on ml.IDModel=ts.idmodel
left join dim_manufacturer as mr on mr.idmanufacturer= ml.IDManufacturer
group by manufacturer_name
order by avg_price desc)as a)
group by ml.model_name;

--Q5--END

--Q6--BEGIN

select customer_name,avg(case when year(date)='2009' then totalprice end) avg_price from fact_transactions as ts
left join dim_customer as cs on cs.IDCustomer=ts.idcustomer
group by customer_name
having avg(case when year(date)='2009' then totalprice end)> 500
order by avg_price desc;

--Q6--END
	
--Q7--BEGIN  
(select model_name from
(select top 5 model_name,sum(quantity) qty from fact_transactions as ts
left join dim_model as ml on ml.IDModel=ts.IDModel
where year([date]) = ('2008')
group by model_name
order by qty desc) A)
intersect
(select model_name from
(select top 5 model_name,sum(quantity) qty from fact_transactions as ts
left join dim_model as ml on ml.IDModel=ts.IDModel
where year([date]) = ('2009')
group by model_name
order by qty desc) B)
intersect
(select model_name from
(select top 5 model_name,sum(quantity) qty from fact_transactions as ts
left join dim_model as ml on ml.IDModel=ts.IDModel
where year([date]) = ('2010') 
group by model_name
order by qty desc) C)

--Q7--END	
--Q8--BEGIN

select t1.manufacturer_name,t1.year1,t1.sales
from(
select manufacturer_name,sum(totalprice) sales,year(date) as year1,
rank() over (partition by year(date) order by sum(totalprice) desc ) rnk from fact_transactions as ts
left join dim_model as ml on ml.idmodel=ts.idmodel
left join dim_manufacturer as mn on mn.idmanufacturer=ml.idmanufacturer
where year(date) in ('2009','2010')
group by Manufacturer_Name,year(date))t1
where rnk=2;


--Q8--END
--Q9--BEGIN

	select mr.manufacturer_name,year([date])
	 from fact_transactions as ts
	 join dim_model as ml on ml.idmodel=ts.idmodel
	 join dim_manufacturer as mr on mr.idmanufacturer=ml.IDManufacturer
    where year([date]) = 2010 and mr.manufacturer_name not in 
	(select mr.manufacturer_name from fact_transactions as ts
	 join dim_model as ml on ml.idmodel=ts.idmodel
	 join dim_manufacturer as mr on mr.idmanufacturer=ml.IDManufacturer
	where year([date])  in ('2009'))

	--Q9--END

--Q10--BEGIN

select * ,((T.totalprice - lag(T.totalprice,1) over (partition by T.idcustomer order by T.year1))*100/T.totalprice) as Per_change_of_spend
from
(select top 100 ts.idcustomer,avg(totalprice)avg_spend,avg(quantity)avg_Qty,year([date]) year1,ts.totalprice
from fact_transactions as ts
left join dim_customer as cs on cs.IDCustomer=ts.IDCustomer
group by ts.idcustomer,year([date]),ts.totalprice
order by ts.totalprice desc) T 

--Q10--END
	