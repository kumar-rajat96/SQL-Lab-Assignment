use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		

select date_format(Order_Date, '%Y-%m') as Month,
	   sum(Quantity) as Quantities_sold,
       sum(Sales) as Sales
from orders as o
inner join ordered_items as oi
using(Order_Id)
inner join product_info as pi
on oi.Item_Id = pi.Product_Id
where lower(Product_Name) like "%nike%"
group by month(Order_Date)
order by Month; 



-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/

select Product_Id,
	   Product_Name,
	   c.Name as Category_Name,
	   d.Name as Department_Name,
	   Product_Price
from product_info as pi
inner join category as c
on pi.Category_Id = c.Id
inner join department as d
on pi.Department_Id = d.Id
order by Product_Price desc
limit 5;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/


select Product_Name,
	   sum(Quantity*Sales) as Sales,
       count(distinct Order_Id) as Order_Counts
from orders as o
inner join ordered_items as oi
using(Order_Id)
inner join product_info as pi
on oi.Item_Id = pi.Product_Id
where Type = "CASH"
group by Product_Name
order by Order_Counts desc , Sales desc
limit 10;



	   

-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/

select Order_ID,
	   Type,
       Real_Shipping_Days,
       Scheduled_Shipping_Days,
       Customer_Id,
       Order_City,
       Order_Date,
       Order_Region,
       Order_State,
       Order_Status,
       Shipping_Mode
from Orders as o
inner join customer_info as ci
on o.Customer_Id = ci.Id
where Street like "%Plaza%" and street not like "%Mountains" and State = "TX"
order by Order_ID;


-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/

select count(*) as Order_Count
from customer_info as ci
inner join orders as o
on ci.Id = o.Customer_Id
inner join ordered_items as oi
on o.Order_Id = oi.Order_id
inner join product_info as pi
on oi.Item_Id = pi.Product_Id
inner join department as d
on pi.Department_Id = d.Id
where ci.Segment = "Home Office" and (d.Name = "Apparel" or d.name = "Outdoors");

-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/

select Order_State,
	   Order_City, 
	   count(*) as Order_Count,
       dense_rank() over(partition by Order_State order by count(*) desc) as City_Rank
from customer_info as ci
inner join orders as o
on ci.Id = o.Customer_Id
inner join ordered_items as oi
on o.Order_Id = oi.Order_id
inner join product_info as pi
on oi.Item_Id = pi.Product_Id
inner join department as d
on pi.Department_Id = d.Id
where ci.Segment = "Home Office" and (d.Name = "Apparel" or d.name = "Outdoors")
group by Order_State,Order_City
order by Order_State,City_Rank,Order_City;



-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/

select Shipping_Mode,
	   count(*) as Shipping_Underestimated_Order_Count,
       row_number() over(partition by year(Order_Date) order by count(*) desc) as Shipping_Mode_Rank
from orders as o
inner join customer_info as ci
on o.Customer_Id = ci.Id
where Order_Status in ("COMPLETE","CLOSED") and Segment = "Consumer" and Scheduled_Shipping_Days < Real_Shipping_Days
group by year(Order_Date),Shipping_Mode
order by year(Order_Date) desc ,Shipping_Underestimated_Order_Count desc;


-- **********************************************************************************************************************************





