-- This script contains demo code for Module 4 of the Transact-SQL course



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
SELECT od.SalesOrderID, od.OrderQty,
        -- Inner query
        (SELECT Name
         FROM SalesLT.Product AS p
         --References alias in outer query
         WHERE p.ProductID = od.ProductID) AS ProductName
FROM SalesLT.SalesOrderDetail AS od
ORDER BY od.SalesOrderID
