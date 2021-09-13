---
lab:
    title: 'Combine query results with set operators'
    module: 'Additional exercises'
---
# Combine query results with set operators

In this lab, you will use set operators to retrieve results from the **adventureworks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).
![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)
> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Write a query that uses the UNION operator

1. Start Azure Data Studio and create a new query (you can do this from the **File** menu or on the *welcome* page).

1. In the new **SQLQuery_...** pane, use the **Connect** button to connect the query to the **AdventureWorks** saved connection.

1. In the query editor, enter the following code:

    ```
    SELECT CompanyName 
    FROM SalesLt.Customer  
    WHERE CustomerID BETWEEN 1 and 20000   
    UNION
        SELECT CompanyName 
        FROM SalesLt.Customer  
        WHERE CustomerID BETWEEN 20000 and 40000;
    ```

1. Highlight the T-SQL code and select **&#x23f5;Run**. Notice that the result set contains **CompanyNames** from both result sets.

## Write a query that uses the INTERSECT operator

Now let's try a query using the INTERSECT operator.

1. In the query editor, below the existing code, enter the following code:

    ```
    -- Prepare tables
    DECLARE @t1 AS table
    (Name nvarchar(30) NOT NULL);
    DECLARE @t2 AS table
    ([Name] nvarchar(30) NOT NULL);
    INSERT INTO @t1 ([Name])
        VALUES
            (N'Daffodil'),
            (N'Camembert'),
            (N'Neddy'),
            (N'Smudge'),
            (N'Molly');
    INSERT INTO @t2 ([Name])
        VALUES
            (N'Daffodil'),
            (N'Neddy'),
            (N'Molly'),
            (N'Spooky');
    SELECT [Name]
    FROM @t1
    INTERSECT
    SELECT [Name]
    FROM @t2
        ORDER BY [Name];
    ```

1. Highlight the code and select **&#x23f5;Run** to execute it. Notice that values in both **t1** and **t2** are returned.

## Write a query that uses the CROSS APPLY operator

Now you will write a table-valued function to return the product category and quantity ordered by specific customers. You will pass the **CustomerID** fom the select statement to the table-valued function in a CROSS APPLY statement.

1. In the query editor, enter the following code:

    ```
    CREATE OR ALTER FUNCTION dbo.ProductSales (@CustomerID int)
    RETURNS TABLE
    RETURN
        SELECT C.[Name] AS 'Category', SUM(D.OrderQty) AS 'Quantity'
            FROM SalesLT.SalesOrderHeader AS H
                INNER JOIN SalesLT.SalesOrderDetail AS D
                    ON H.SalesOrderID = D.SalesOrderID
                INNER JOIN SalesLT.Product AS P
                    ON D.ProductID = P.ProductID
                INNER JOIN SalesLT.ProductCategory AS C
                    ON P.ProductCategoryID = C.ProductCategoryID
            WHERE H.CustomerID = @CustomerID
                GROUP BY C.[Name]
    ```

1. Highlight the code and select **&#x23f5;Run** to execute it.

1. Then, enter the following code on a new line:

    ```
    SELECT C.CustomerID, C.CompanyName, P.Category, P.Quantity
    FROM SalesLT.Customer AS C
        CROSS APPLY dbo.ProductSales(C.CustomerID) AS P;
    ```

1. Highlight the code and select **&#x23f5;Run** to execute it.

## Challenges

Now it's your turn to use set operators.
> **Tip**: Try to determine the appropriate code for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Return all company names

Amend the T-SQL code containing the UNION operator, to return ALL company names, including duplicates.

### Challenge 2: Return names from t1

Amend the T-SQL code containing the INTERSECT operator to return names from **t1** that do not appear in **t2**.

## Challenge Solutions

This section contains suggested solutions for the challenge queries.

### Challenge 1

```
SELECT CompanyName 
FROM SalesLt.Customer
WHERE CustomerID BETWEEN 1 and 20000 
UNION ALL
    SELECT CompanyName 
    FROM SalesLt.Customer
    WHERE CustomerID BETWEEN 20000 and 40000;
```

### Challenge 2

```
DECLARE @t1 AS table
(Name nvarchar(30) NOT NULL);
DECLARE @t2 AS table
([Name] nvarchar(30) NOT NULL);
INSERT INTO @t1 ([Name])
    VALUES
        (N'Daffodil'),
        (N'Camembert'),
        (N'Neddy'),
        (N'Smudge'),
        (N'Molly');
INSERT INTO @t2 ([Name])
    VALUES
        (N'Daffodil'),
        (N'Neddy'),
        (N'Molly'),
        (N'Spooky');
SELECT [Name]
FROM @t1
    EXCEPT
SELECT [Name]
FROM @t2
    ORDER BY [Name];
```
