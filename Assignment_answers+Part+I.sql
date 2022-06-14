 use supply_db ;


Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/

select Product_Name,
    Product_Id
from product_info as p
inner join category as c
on p.Category_Id = c.Id
where c.Name like "%golf%"
order by Product_Id;


-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.


*/

select Product_Name,
    sum(Sales) as Sales
from orders as o 
inner join ordered_items as oi 
using(Order_Id)
inner join product_info as pi 
on oi.Item_Id = pi.Product_Id
inner join category as c 
on pi.Category_Id = c.Id 
where Name like "%golf%"
group by Product_Name
order by Sales desc 
limit 10;


-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/

select Segment as customer_segment,
    count(Order_Id) as Orders
from customer_info as ci 
inner join orders as o
on ci.Id = o.Customer_Id
group by Segment
order by Orders desc;


-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.


*/

with order_seg as
(
select ci.segment as customer_segment,
	count(o.order_id) as orders
from orders o
left join customer_info ci
on o.customer_id = ci.id
where real_shipping_days=6
group by 1
)
select a.customer_segment,
	round(a.orders/sum(b.orders)*100,1) as percentage_order_split
from order_seg as a
join order_seg as b
group by 1
order by 2 desc;


-- **********************************************************************************************************************************
