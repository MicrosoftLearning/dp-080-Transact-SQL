-- This script contains demo code for Module 3 of the Transact-SQL course


-- INNER joins

-- Implicit
SELECT p.ProductID, m.Name AS Model, p.Name AS Product
FROM SalesLT.Product AS p
JOIN SalesLT.ProductModel AS m
    ON p.ProductModelID = m.ProductModelID
ORDER BY p.ProductID;

-- Explicit
SELECT p.ProductID, m.Name AS Model, p.Name AS Product
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductModel AS m
    ON p.ProductModelID = m.ProductModelID
ORDER BY p.ProductID;

-- Multiple joins
SELECT od.SalesOrderID, m.Name AS Model, p.Name AS ProductName, od.OrderQty
FROM SalesLT.Product AS p
JOIN SalesLT.ProductModel AS m
    ON p.ProductModelID = m.ProductModelID
JOIN SalesLT.SalesOrderDetail AS od
    ON p.ProductID = od.ProductID
ORDER BY od.SalesOrderID;



-- OUTER Joins

-- Left outer join
SELECT od.SalesOrderID, p.Name AS ProductName, od.OrderQty
FROM SalesLT.Product AS p
LEFT OUTER JOIN SalesLT.SalesOrderDetail AS od
    ON p.ProductID = od.ProductID
ORDER BY od.SalesOrderID;

-- Outer keyword is optional
SELECT od.SalesOrderID, p.Name AS ProductName, od.OrderQty
FROM SalesLT.Product AS p
LEFT JOIN SalesLT.SalesOrderDetail AS od
    ON p.ProductID = od.ProductID
ORDER BY od.SalesOrderID;



-- CROSS JOIN

-- Every product/city combination
SELECT p.Name AS Product, a.City
FROM SalesLT.Product AS p
CROSS JOIN SalesLT.Address AS a;



-- SELF JOIN

-- Prepare the demo
-- There's no employee table, so we'll create one for this example
CREATE TABLE SalesLT.Employee
(EmployeeID int IDENTITY PRIMARY KEY,
EmployeeName nvarchar(256),
ManagerID int);
GO
-- Get salesperson from Customer table and generate managers
INSERT INTO SalesLT.Employee (EmployeeName, ManagerID)
SELECT DISTINCT Salesperson, NULLIF(CAST(RIGHT(SalesPerson, 1) as INT), 0)
FROM SalesLT.Customer;
GO
UPDATE SalesLT.Employee
SET ManagerID = (SELECT MIN(EmployeeID) FROM SalesLT.Employee WHERE ManagerID IS NULL)
WHERE ManagerID IS NULL
AND EmployeeID > (SELECT MIN(EmployeeID) FROM SalesLT.Employee WHERE ManagerID IS NULL);
GO
 
-- Here's the actual self-join demo
SELECT e.EmployeeName, m.EmployeeName AS ManagerName
FROM SalesLT.Employee AS e
LEFT JOIN SalesLT.Employee AS m
ON e.ManagerID = m.EmployeeID
ORDER BY e.ManagerID;



-- SIMPLE SUBQUERIES

-- Scalar subquery
-- Outer query
SELECT p.Name, p.StandardCost
FROM SalesLT.Product AS p
WHERE StandardCost <
     -- Inner query
     (SELECT AVG(StandardCost)
      FROM SalesLT.Product)
ORDER BY p.StandardCost DESC;

--Multivalue subquery
-- Outer query
SELECT p.Name, p.StandardCost
FROM SalesLT.Product AS p
WHERE p.ProductID IN
     -- Inner query
    (SELECT ProductID
     FROM SalesLT.SalesOrderDetail)
ORDER BY p.StandardCost DESC;



-- CORRELATED SUBQUERY

-- Outer query
SELECT SalesOrderID, CustomerID, OrderDate
FROM SalesLT.SalesOrderHeader AS o1
WHERE SalesOrderID =
    -- Inner query
    (SELECT MAX(SalesOrderID)
	 FROM SalesLT.SalesOrderHeader AS o2
     --References alias in outer query
	 WHERE o2.CustomerID = o1.CustomerID)
ORDER BY CustomerID, OrderDate;

-- Outer query
SELECT od.SalesOrderID, od.OrderQty,
        -- Inner query
        (SELECT Name
         FROM SalesLT.Product AS p
         --References alias in outer query
         WHERE p.ProductID = od.ProductID) AS ProductName
FROM SalesLT.SalesOrderDetail AS od
ORDER BY od.SalesOrderID

-- Using EXISTS
-- Outer query
SELECT CustomerID, CompanyName, EmailAddress
FROM SalesLT.Customer AS c
WHERE EXISTS
    -- Inner query
	(SELECT * 
 	 FROM SalesLT.SalesOrderHeader AS o
      --References alias in outer query
 	 WHERE o.CustomerID = c.CustomerID);

