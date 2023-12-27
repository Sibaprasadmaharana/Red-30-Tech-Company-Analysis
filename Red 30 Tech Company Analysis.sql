
---Sub Queries 
/*
Task 1: Write a query that uses a scalar subsquery to identify orders whose order total is higher than the 
average total price of all other order.
 */  
   SELECT *, (Select AVG([Order Total]) from[Red30Tech].[dbo].[OnlineRetailSales$]) as Avg_Total
   FROM [Red30Tech].[dbo].[OnlineRetailSales$]
WHERE [Order Total] >= (SELECT AVG([Order Total]) FROM [Red30Tech].[dbo].[OnlineRetailSales$]);

--CTE
  With AVGTOTAL (AVG_TOTAL) as 
         (SELECT AVG([Order Total]) as AVG_TOTAL
		 FROM [Red30Tech].[dbo].[OnlineRetailSales$])
  Select *  FROM [Red30Tech].[dbo].[OnlineRetailSales$], AVGTOTAL
  Where [Order Total ] >= AVG_TOTAL;
  

/*
Task 2 : Two trees Olive oil wants to know the session name, start Name, end date, and room
That their employees will be delivarieng their presentation in . write a query that uses a multiple 
row subquery to extracr this information. 
*/
   Select [Session Name], [Speaker Name], [Start Date], [Room Name]
   FROM [Red30Tech].[dbo].[SessionInfo$] 
   Inner Join (SELECT [Name] from [Red30Tech].[dbo].[SpeakerInfo$]
              WHERE [Organization] = 'Two Trees Olive Oil') as Speak
			  On [Red30Tech].[dbo].[SessionInfo$].[Speaker Name] = Speak.[Name];
/*.
Task 3: Write a query that outputs the first and last name, state, email address, 
and phone number of conference attendees who come from states that have no Online Retail Sales.
*/
   Select [First Name], [Last Name], [State], [Email], [Phone Number]
   From [Red30Tech].[dbo].[ConventionAttendees$] as C
   Where NOt Exists 
             (Select [CustState] from [Red30Tech].[dbo].[OnlineRetailSales$] as O
			 Where C.[State] = O.[Custstate] )
---- CTE---
/* Task 4
Use inventory table and return 
    ProdCategory
	ProdNumber
	ProdName
	In stock of items that have less than the avarage amounts of products left in stock
*/
   Select [ProdCategory], [ProdNumber], [ProdName], [In Stock]
   From [Red30Tech].[dbo].[Inventory$] 
   Where [In Stock] < (select avg([In Stock]) from [Red30Tech].[dbo].[Inventory$]);

   --- IN CTE

WITH AvgInventoryCTE AS (
    SELECT
        AVG([In Stock]) AS AvgInStock
    FROM
        [Red30Tech].[dbo].[Inventory$]
)
SELECT
    ProdCategory,
    ProdNumber,
    ProdName, [In Stock]
FROM
   [Red30Tech].[dbo].[Inventory$]
CROSS JOIN
    AvgInventoryCTE
WHERE
    [In Stock] < AvgInStock;

	---ROW_NUMBER
/*
Task 5: Write a query using ROW_NUMBER to return each customer's most recent order.
*/

With Row_Numbers as (
                    SELECT [OrderNum], [OrderDate], [CustName], [ProdName], [Quantity],
					ROW_NUMBER() OVER(PARTITION BY [CustName] ORDER BY OrderDate DESC) as ROW_NUM
					FROM  [Red30Tech].[dbo].[OnlineRetailSales$] )
select * from Row_Numbers where ROW_NUM = 1


/*. Task 6
 Write a query using ROW_NUMBER() that returns the OrderNum, OrderDate, CustName, ProdCategory, ProdName, and 
Order Total of the top 3 orders that have the highest Order Total from each ProdCategory purchased by Boehm Inc.
*/
With Row_Numbers as (
                     Select OrderNum, OrderDate, CustName, ProdCategory, ProdName, [Order Total],
					 Row_Number () Over(Partition By [ProdCategory] order by OrderDate DESC) as ROW_NUM
					 From [Red30Tech].[dbo].[OnlineRetailSales$]
					 where CustName = 'Boehm Inc.')
Select OrderNum, OrderDate, CustName, ProdCategory, ProdName, [Order Total] from Row_Numbers
WHERE ROW_NUM in (1,2,3)
ORDER BY [ProdCategory],[Order Total] DESC;

----LAG() and LEAD()
/*
Task 7: Write a query using LAG() and LEAD() to show the Session Name and Start Time of the previous Red30 Tech 
session conducted in Room 102,as well as what the next session will be.
*/

Select [Session Name], [Start Date],

LAG([Session Name],1) Over (Order By [Start Date] ASC ) as PrevoisSession,
LAG([Start Date],1) Over (Order By [Start Date] ASC ) as PrevoisStartdate,

Lead([Session Name],1) Over (Order By [Start Date] ASC ) as NextSession,
Lead([Start Date],1) Over (Order By [Start Date] ASC ) as NexStartdate

From [Red30Tech].[dbo].[SessionInfo$]
WHERE [Room Name] = 'Room 102';

/* Task 8
 Write a query using LAG() or LEAD() that returns the Quantity of Drones ordered on the previous 5
order dates from the OnlineRetailSales table.
*/

SELECT * FROM [Red30Tech].[dbo].[OnlineRetailSales$]
Where ProdCategory = 'Dron'
With Order_By_Days as (
                       Select OrderDate, Sum(Quantity) as Quantity_BY_Day
					   From [Red30Tech].[dbo].[OnlineRetailSales$]
					   Where ProdCategory = 'Drones'
					   Group By OrderDate
					   )
Select OrderDate, Quantity_BY_Day,
LAG(Quantity_BY_Day,1) Over (Order By [OrderDate] Asc) as Lastdatequantity_1,
LAG(Quantity_BY_Day,2) Over (Order By [OrderDate] Asc) as Lastdatequantity_2,
LAG(Quantity_BY_Day,3) Over (Order By [OrderDate] Asc) as Lastdatequantity_3,
LAG(Quantity_BY_Day,4) Over (Order By [OrderDate] Asc) as Lastdatequantity_4,
LAG(Quantity_BY_Day,5) Over (Order By [OrderDate] Asc) as Lastdatequantity_5

From Order_BY_Days;

----RANK() and DENSE_RANK() 
/*
Task 9: Write a query using RANK() and DENSE_RANK() that ranks employees in alphabetical order by their last name.
*/

Select *,
RANK() OVER (Order By [last Name]) as RANK_,
DENSE_RANK() OVER (Order By [last Name]) as DENSE_RANK_
FROM [Red30Tech].[dbo].[EmployeeDirectory$]


/* Task 10
Write a query using RANK() or DENSE_RANK() that pulls all registration information for the
first three people that registered for the Red30Tech Conference in each state.
*/

WITH RANKS AS (
              Select *, 
			  DENSE_RANK() OVER (Partition By [State] Order By [Registration Date]) as DENSE_RANK_
			  FROM [Red30Tech].[dbo].[ConventionAttendees$]
			  )
SELECT * From RANKS WHERE DENSE_RANK_ in (1,2,3)
