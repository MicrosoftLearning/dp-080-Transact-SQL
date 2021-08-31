---
lab:
    title: 'Create stored procedures in T-SQL'
    module: 'Module 2: Create Stored Procedures in T-SQL'
---

In this lab, you'll use T-SQL statements to create and understand stored procedure techniques in the **adventureworks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Create and execute stored procedures

1. Start Azure Data Studio.
1. From the Servers pane, double-click the **AdventureWorks connection**. A green dot will appear when the connection is successful.
1. Right click on the AdventureWorks connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
1. Type the following T-SQL code:
    
    ``` 
    CREATE PROCEDURE SalesLT.TopProducts AS
    SELECT TOP(10) name, listprice
        		FROM SalesLT.Product
        		GROUP BY name, listprice
        		ORDER BY listprice DESC;
    ```
    
1. Select **&#x23f5;Run**. You've created a stored procedure named SalesLT.TopProducts.
1. In the query pane, type the following T-SQL code after the previous code:

    ```
    EXECUTE SalesLT.TopProducts;
    ```

1. Highlight the written T-SQL code and click **&#x23f5;Run**. You've now executed the stored procedure.
1. Now modify the stored procedure so that it returns only products from a specific product category by adding an input parameter. In the query pane, type the following T-SQL code:

    ```
    ALTER PROCEDURE SalesLT.TopProducts @ProductCategoryID int
    AS
    SELECT TOP(10) name, listprice
        	FROM SalesLT.Product
            WHERE ProductCategoryID = @ProductCategoryID 
        	GROUP BY name, listprice
        	ORDER BY listprice DESC; 
    ```
    
1. In the query pane, type the following T-SQL code:

    ```
    EXECUTE SalesLT.TopProducts @ProductCategoryID = 18;
    ```

1. Highlight the written T-SQL code and click **&#x23f5;Run** to execute the stored procedure, passing the parameter value by name.

### Challenge

1. Pass a value to the stored procedure by position instead of by name. Try Product Category 41.

### Challenge answer

    ``` 
    EXECUTE SalesLT.TopProducts 41;
    ``` 

## Create an inline table valued function

1. In the query pane, type the following T-SQL code:

    ```
    CREATE FUNCTION SalesLT.GetFreightbyCustomer
    (@orderyear AS INT) RETURNS TABLE
    AS
    RETURN
    SELECT
    customerid, SUM(freight) AS totalfreight
    FROM SalesLT.SalesOrderHeader
    WHERE YEAR(orderdate) = @orderyear
    GROUP BY customerid; 
    ```

1. Highlight the written T-SQL code and click **&#x23f5;Run** to create the table-valued function.

### Challenge

1. Run the table-valued function to return data for the year 2008.

### Challenge answer

    ```
    SELECT * FROM SalesLT.GetFreightbyCustomer(2008)
    ```
