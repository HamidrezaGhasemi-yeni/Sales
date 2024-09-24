select * 
from Sales..Sales_Data
--cheking if there is duplicate data
SELECT order_id, COUNT(*)
FROM Sales..Sales_data
GROUP BY order_id
HAVING COUNT(*) > 1;
--deleting duplicate date by cte
WITH cte_duplicate AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY order_id	 ORDER BY order_id) AS row_num
    FROM Sales..Sales_data
)
DELETE FROM cte_duplicate
WHERE row_num > 1;
--seperating order time from order Date
select Order_Date,
cast(order_date as date) date_order,
cast(order_date as time(0)) time_order --using time(0) to remove the fractional seconds 
from Sales..Sales_data
--droping the old Oeder_date and inserting new columns that we made before
--adding and updating Date_order column
ALTER TABLE Sales_data
ADD Date_order date
UPDATE Sales_data
SET Date_order = cast(order_date as date) 
--adding and updating Time_order column
ALTER TABLE Sales_data
ADD Time_order time(0)
UPDATE Sales_data
SET Time_order = cast(order_date as time(0)) 
--checking if it is down
select order_id ,Date_order,Time_order
from Sales_data
--droping the old Order_date column
alter table Sales_data
drop COLUMN  order_date	
--separating each pat of the purchase_address
select  purchase_address,
		substring (purchase_address,1,charindex(' ',purchase_address)-1) as house_number,
        substring (purchase_address,charindex(' ',purchase_address),charindex(',',purchase_address)-charindex(' ',purchase_address))as street_name,
		substring (purchase_address,(charindex(',',purchase_address)+2),charindex(',', purchase_address, charindex(',', purchase_address) + 1) - charindex(',', purchase_address) - 2) as city,
		substring(purchase_address, charindex(',', purchase_address, charindex(',', purchase_address) + 1) + 2, 2) as state,
		substring(purchase_address, LEN(purchase_address) - 4, 5) AS zip_code
from Sales_data
--inserting the separated address and droping the old one
alter table Sales..Sales_Data
add house_number varchar(255),
    street_name  varchar(255),
--	city  varchar(255), it already had the city column :))
	state varchar(255),
	zip_code varchar(255)
--updating the table(inserting values)
update  Sales..Sales_Data
set house_number = substring (purchase_address,1,charindex(' ',purchase_address)-1),
	street_name = substring (purchase_address,charindex(' ',purchase_address),charindex(',',purchase_address)-charindex(' ',purchase_address)),
	state = substring(purchase_address, charindex(',', purchase_address, charindex(',', purchase_address) + 1) + 2, 2),
	zip_code = substring(purchase_address, LEN(purchase_address) - 4, 5) 

--selecting everything from the Table to get a export for visualization
select * 
from Sales_data