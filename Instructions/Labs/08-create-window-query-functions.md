---
lab:
    title: 'Use window functions'
    module: 'Additional exercises'
---
# Use window functions

In this lab, you'll run window functions on the **adventureworks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).
![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)
> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Ranking function

In this exercise you will create a query that uses a window function to return a ranking value. The query uses a CTE (common table expression) called **sales**. You then use the **sales** CTE to add the RANK window function.

1. Start Azure Data Studio, and create a new query (you can do this from the **File** menu or on the *welcome* page).
1. In the new **SQLQuery_...** pane, use the **Connect** button to connect the query to the **AdventureWorks** saved connection.
1. Copy the following T-SQL code into the query window, highlight it and select **&#x23f5;Run**.

    ```
    WITH sales AS
    (
        SELECT C.Name AS 'Category', CAST(SUM(D.LineTotal) AS numeric(12, 2)) AS 'SalesValue'
        FROM SalesLT.SalesOrderDetail AS D
        INNER JOIN SalesLT.Product AS P
            ON D.ProductID = P.ProductID
        INNER JOIN SalesLT.ProductCategory AS C
            ON P.ProductCategoryID = C.ProductCategoryID
        WHERE C.ParentProductCategoryID = 4
            GROUP BY C.Name
    )
    SELECT Category, SalesValue, RANK() OVER(ORDER BY SalesValue DESC) AS 'Rank'
    FROM sales
        ORDER BY Category;
    ```

The product categories now have a rank number according to the **SalesValue** for each category. Notice that the RANK function required the rows to be ordered by **SalesValue**, but the final result set was ordered by **Category**.

## Offset function

In this exercise you will create a new table called **Budget** populated with budget values for five years. You will then use the LAG window function to return each year's budget, together with the previous year's budget value.  

1. In the query editor, under the existing code enter the following code:

    ```
    CREATE TABLE dbo.Budget
    (
        [Year] int NOT NULL PRIMARY KEY,
        Budget int NOT NULL
    );

    INSERT INTO dbo.Budget ([Year], Budget)
        VALUES
            (2017, 14600),
            (2018, 16300),
            (2019, 18200),
            (2020, 21500),
            (2021, 22800);

    SELECT [Year], Budget, LAG(Budget, 1, 0) OVER (ORDER BY [Year]) AS 'Previous'
        FROM dbo.Budget
        ORDER BY [Year]; 
    ```

1. Highlight the code and select **&#x23f5;Run**.

## Aggregation function

In this exercise you will create a query that uses PARTITION BY to count the number of subcategories in each category.

1. In the query editor, under the existing code enter the following code to return a count of products in each category:

    ```
    SELECT C.Name AS 'Category', SC.Name AS 'Subcategory', COUNT(SC.Name) OVER (PARTITION BY C.Name) AS 'SubcatCount'
    FROM SalesLT.SalesOrderDetail AS D
    INNER JOIN SalesLT.Product AS P
        ON D.ProductID = P.ProductID
    INNER JOIN SalesLT.ProductCategory AS SC
        ON P.ProductCategoryID = SC.ProductCategoryID
    INNER JOIN SalesLT.ProductCategory AS C
        ON SC.ParentProductCategoryID = C.ProductCategoryID
        GROUP BY C.Name, SC.Name
        ORDER BY C.Name, SC.Name;
    ```

1. Highlight the code and select **&#x23f5;Run**.

## Challenges

Now it's your turn to use window functions.

> **Tip**: Try to determine the appropriate code for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Return a RANK value for products

Amend the T-SQL code with the RANK clause so that it returns a Rank value for products within each category.

### Challenge 2: Return the next year's budget value

Using the **Budget** table you have already created, amend the SELECT statement to return the following year’s budget value as "Next".

### Challenge 3: Return the first and last budget values for each year

Using the **Budget** table you have already created, amend the select statement to return the first budget value in one column, and the last budget value in another column, where budget values are ordered by year in ascending order.

### Challenge 4: Count the products in each category

Amend the code containing the aggregation function to return a count of products by category.

## Challenge Solutions

This section contains suggested solutions for the challenge queries.

### Challenge 1

```
WITH sales AS
(
    SELECT C.Name AS 'Category', SC.Name AS 'Subcategory', CAST(SUM(D.LineTotal) AS numeric(12, 2)) AS 'SalesValue'
    FROM SalesLT.SalesOrderDetail AS D
    INNER JOIN SalesLT.Product AS P
        ON D.ProductID = P.ProductID
    INNER JOIN SalesLT.ProductCategory AS SC
        ON P.ProductCategoryID = SC.ProductCategoryID
    INNER JOIN SalesLT.ProductCategory AS C
        ON SC.ParentProductCategoryID = C.ProductCategoryID
        GROUP BY C.Name, SC.Name
)
SELECT Category, Subcategory, SalesValue, RANK() OVER(PARTITION BY Category ORDER BY SalesValue DESC) AS 'Rank'
FROM sales
    ORDER BY Category, SalesValue DESC;
```

### Challenge 2

```
SELECT [Year], Budget, LEAD(Budget, 1, 0) OVER (ORDER BY [Year]) AS 'Next'
FROM dbo.Budget
    ORDER BY [Year];
```

### Challenge 3

```
SELECT [Year], Budget,
        FIRST_VALUE(Budget) OVER (ORDER BY [Year]) AS 'First_Value',
        LAST_VALUE(Budget) OVER (ORDER BY [Year] ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS 'Last_Value'
FROM dbo.Budget
    ORDER BY [Year];
```

### Challenge 4

```
SELECT C.Name AS 'Category', SC.Name AS 'Subcategory', COUNT(P.Name) OVER (PARTITION BY C.Name) AS 'ProductCount'
FROM SalesLT.SalesOrderDetail AS D
    INNER JOIN SalesLT.Product AS P
        ON D.ProductID = P.ProductID
    INNER JOIN SalesLT.ProductCategory AS SC
        ON P.ProductCategoryID = SC.ProductCategoryID
    INNER JOIN SalesLT.ProductCategory AS C
        ON SC.ParentProductCategoryID = C.ProductCategoryID
    GROUP BY C.Name, SC.Name, P.Name
    ORDER BY C.Name, SC.Name, P.Name;
```
