---
lab:
    title: 'Create stored procedures and functions in Transact-SQL'
    module: 'Additional exercises'
---

# Create stored procedures and functions in Transact-SQL

In this exercise, you'll create and run stored procedures in the **Adventureworks** database.

> **Note**: This exercise assumes you have created the **Adventureworks** database.

## Create a stored procedure

Stored procedures are named groups of Transact-SQL statements that can be used and reused whenever they're needed.

1. Open a query editor for your **Adventureworks** database, and create a new query.
1. In the query pane, type the following code:

    ```sql
    CREATE PROCEDURE SalesLT.up_GetTopProducts
    AS
    SELECT TOP(10) Name, ListPrice
    FROM SalesLT.Product
    GROUP BY Name, ListPrice
    ORDER BY ListPrice DESC;
    ```
    
1. Run the code to create a stored procedure named **SalesLT.up_GetTopProducts**.
1. In the query pane, type the following code under the CREATE PROCEDURE statement:

    ```sql
    EXECUTE SalesLT.up_GetTopProducts;
    ```

1. Select the EXECUTE statement to highlight it, and then run it. The stored procedure is executed and returns the top 10 products by price.

1. Now alter the stored procedure by adding an input parameter so that you can specify how many "top" products you want to return. In the query pane, type the following T-SQL code:

    ```sql
    ALTER PROCEDURE SalesLT.up_GetTopProducts (@count int)
    AS
    SELECT TOP(@count) Name, ListPrice
    FROM SalesLT.Product
    GROUP BY Name, ListPrice
    ORDER BY ListPrice DESC;
    ```

1. Select the ALTER PROCEDURE statement to highlight it, and then run it to modify the stored procedure

1. Modify the EXECUTE statement used to call the stored procedure to pass a parameter:

    ```sql
    EXECUTE SalesLT.up_GetTopProducts @count=20;
    ```

1. Highlight the modified EXECUTE statement and run it to call the stored procedure, passing the parameter value by name. This time the stored procedure returns the top 20 products by price.

## Create functions

Functions are similar to stored procedures, but can be used in SELECT statements like built in functions.

### Create a scalar function

Scalar functions return a single value.

1. Create a new query, and add the following code, which defines a function to apply a specified percentage discount to the price of a specified product:

    ```sql
    CREATE FUNCTION SalesLT.fn_ApplyDiscount (@productID int, @percentage decimal)
    RETURNS money
    AS
    BEGIN
        DECLARE @discountedPrice money;
        SELECT @discountedPrice = ListPrice - (ListPrice * (@percentage/100))
        FROM SalesLT.Product
        WHERE ProductID = @productID;
        RETURN @discountedPrice
    END;
    ```

1. Run the code to create the function.
1. In the query pane, type the following code under the CREATE FUNCTION statement:

    ```sql
    SELECT ProductID, Name, ListPrice, StandardCost,
           SalesLT.fn_ApplyDiscount(ProductID, 10) AS SalePrice
    FROM SalesLT.Product;
    ```

1. Select and run the SELECT statement and view the results, which show the ID, name, list price, and cost of each product together with a sale price that is calculated by using the function you created to apply a 10% discount.

### Create a table-valued function

Table-valued functions return a table.

1. Create a new query, and add the following code, which defines a function that returns the ID, name, price, cost, and gross profit for all products in a specified category:

    ```sql
    CREATE FUNCTION SalesLT.fn_ProductProfit (@categoryID int)  
    RETURNS TABLE  
    AS  
    RETURN  
        SELECT ProductID, Name AS Product, ListPrice, StandardCost, ListPrice - StandardCost AS Profit 
        FROM SalesLT.Product  
        WHERE ProductCategoryID = @categoryID;
    ```

1. Run the code to create the function.
1. In the query pane, type the following code under the CREATE FUNCTION statement:

    ```sql
    SELECT * FROM SalesLT.fn_ProductProfit(18)
    ```

1. Select and run the SELECT statement and view the results, which show the ID, name, price, cost, and gross profit for products in category 18.
1. Modify the SELECT statement to use a CROSS APPLY clause:

    ```sql
    SELECT c.Name AS Category, pm.Product, pm.ListPrice, pm.Profit
    FROM SalesLT.ProductCategory AS c
    CROSS APPLY SalesLT.fn_ProductProfit(c.ProductCategoryID) AS pm
    ORDER BY Category, Product;
    ```

1. Select and run the SELECT statement and view the results., The CROSS APPLY clause runs the function for each category in the **SalesLT.ProductCategory** table - creating an inner join between the table of product categories and the table returned by the function.

## Challenges

Now it's time to try using what you've learnt.

> **Tip**: Try to determine the appropriate solutions for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Create a stored procedure to retrieve products in a specific category

Create a stored procedure that returns the ID, name, and list price of all products in a specified category ID.

Test your stored procedure by using it to retrieve details of products in category *18*.

### Challenge 2: Create a function to find the average price of a product in a specific category

Create a function that returns the average list price of a product in a specified category ID.

Test the function by writing a query that returns a the ID, names,and average product prices for each distinct category.

### Challenge 3: Create a function to find subcategories of a specified category

Product categories are hierarchical - some categories are subcategories of parent categories, identified by the **ParentProductCategoryID** field in the **SalesLT.ProductCategory** table.

Create a function that returns a table containing the ID and name of all subcategories of a specified category ID.

Test your function, initially by using it to return all subcategories of category *1*; then by using a CROSS APPLY query to return all parent category names with the names of their subcategories.

## Challenge Solutions

This section contains suggested solutions for the challenge queries.

### Challenge 1

```sql
-- Create the procedure
CREATE PROCEDURE SalesLT.up_GetProducts (@categoryID int)
AS
SELECT ProductID, Name AS Product, ListPrice
FROM SalesLT.Product
WHERE ProductCategoryID = @categoryID;

GO

-- Test the procedure with category 18
EXECUTE SalesLT.up_GetProducts @categoryID=18;
```

### Challenge 2

```sql
-- Create a function
CREATE FUNCTION SalesLT.fn_AvgProductPrice (@categoryID int)
RETURNS money
AS
BEGIN
    DECLARE @averagePrice money;
    SELECT @averagePrice = AVG(ListPrice)
    FROM SalesLT.Product
    WHERE ProductCategoryID = @categoryID;
    RETURN @averagePrice
END;
GO

-- Test the function
SELECT ProductCategoryID, Name AS Category,
       SalesLT.fn_AvgProductPrice(ProductCategoryID) AS AveragePrice
FROM SalesLT.ProductCategory;
```

### Challenge 3

```sql
-- Create a table-valued function
CREATE FUNCTION SalesLT.fn_SubCategories (@categoryID int)  
RETURNS TABLE  
AS  
RETURN  
    SELECT ProductCategoryID, Name AS SubCategory 
    FROM SalesLT.ProductCategory
    WHERE ParentProductCategoryID = @categoryID;
GO

-- Test the function
SELECT * FROM SalesLT.fn_SubCategories(1);
GO

-- Use the function in a CROSS APPLY query
SELECT c.Name AS Category, sc.SubCategory
FROM SalesLT.ProductCategory AS c
CROSS APPLY SalesLT.fn_SubCategories(c.ProductCategoryID) AS sc
ORDER BY Category, SubCategory;
```

