create  database adventure;
use adventure;
#1.(a).append the two tables(just to display)
select * from factinternetsales 
union all 
select * from fact_internet_sales_new;
#1.(b). append (per change)
create table sales as 
select * 
from factinternetsales;
insert into sales 
select * 
from fact_internet_sales_new;
select * from sales;
#2.customer full name (just to display)
select customerkey,
       concat(firstname, " ",middlename," ",lastname) as cutomerfullname
       from dimcustomer;
#2.customerfullname (per change)
alter table dimcustomer add column customername varchar(255);
set sql_safe_updates=0;
update dimcustomer set customername=concat(firstname," ",middlename," ",lastname);
select customerkey,customername from dimcustomer;
#3.join product,subcategory and category
select * from dimproduct;
select * from sales;
SELECT
    p.ProductKey,
    p.EnglishProductName,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName
FROM dimproduct p
inner JOIN dimproductsubcategory s
ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
inner JOIN dimproductcategory c
ON s.ProductCategoryKey = c.ProductCategoryKey;
#4.create date columns
alter table sales add column neworderdate date;
update sales set neworderdate=date_add("1899-12-30",interval orderdate day);
select 
year(neworderdate) as year,
month(neworderdate) as monthno,
monthname(neworderdate) as monthname,
concat("Q",quarter(neworderdate)) as quarter from sales;
select orderdate, year(orderdate) as year from factinternetsales;
#5.total sales
select sum(salesamount) as totalsales from sales;
#6.total product cost
select sum(totalproductcost) as totalproductcost from sales;
#7.total orders
select count(salesordernumber) as totalorders from sales;
#8.total customers
select count(distinct customerkey) as totalcustomers from sales;
#9.total profit
select sum(salesamount-totalproductcost) as totalprofit from sales;
#10.total products
select count(distinct productkey) as totalproducts from dimproduct;
select * from dimproduct;
#11.top 10 selling products
SELECT
    p.EnglishProductName,
    CONCAT(ROUND(SUM(s.SalesAmount)/1000000,2),'M') AS TotalSales
FROM sales s
JOIN dimproduct p
ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY SUM(s.SalesAmount) DESC
LIMIT 10;
#12.sales by year
SELECT
    YEAR(newOrderDate) AS Year,
    CONCAT(ROUND(SUM(SalesAmount)/1000000,2),'M') AS TotalSales
FROM sales
GROUP BY YEAR(newOrderDate)
ORDER BY Year;
#13.profit by year
SELECT
    YEAR(newOrderDate) AS Year,
    CONCAT(ROUND(SUM(SalesAmount-TotalProductCost)/1000000,2),'M') AS TotalProfit
FROM sales
GROUP BY YEAR(newOrderDate)
ORDER BY Year;
#14.sales by month
SELECT
    MONTHNAME(newOrderDate) AS Month,
    CONCAT(ROUND(SUM(SalesAmount)/1000000,2),'M') AS TotalSales
FROM sales
GROUP BY MONTH(newOrderDate), MONTHNAME(newOrderDate)
ORDER BY MONTH(newOrderDate);
#15.best category
SELECT
    pc.EnglishProductCategoryName,
    CONCAT(ROUND(SUM(s.SalesAmount)/1000000,2),'M') AS TotalSales
FROM sales s
JOIN dimproduct p
ON s.ProductKey = p.ProductKey
JOIN dimproductsubcategory ps
ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN dimproductcategory pc
ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName
ORDER BY SUM(s.SalesAmount) DESC;
#16.best region
SELECT
    t.SalesTerritoryRegion,
    CONCAT(ROUND(SUM(s.SalesAmount)/1000000,2),'M') AS TotalSales
FROM sales s
JOIN dimsalesterritory t
ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion
ORDER BY SUM(s.SalesAmount) DESC;
#17.top customers
SELECT
CustomerName,
SUM(s.SalesAmount) AS TotalSales
FROM sales s
JOIN dimcustomer c
ON s.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, CustomerName
ORDER BY SUM(s.SalesAmount) DESC
LIMIT 10;