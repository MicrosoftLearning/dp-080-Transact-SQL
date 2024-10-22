---
lab:
    title: 'Introduction to programming with Transact-SQL'
    module: 'Additional exercises'
---

# Introduction to programming with Transact-SQL

In this exercise, you'll use get an introduction to programming with Transact-SQL using the **Adventureworks** database.

> **Note**: This exercise assumes you have created the **Adventureworks** database.

## Declare variables and retrieve values

1. Open a query editor for your **Adventureworks** database, and create a new query.
1. In the query pane, type the following code:

    ```sql
    DECLARE @productID int = 680;

    SELECT @productID AS ProductID;
    ```

1. Run the query and review the result, which is returned as a resultset from the SELECT statement:

   | ProductID |
   | -------- |
   | 680 |

1. Modify the code as follows:

    ```sql
    -- Variable declarations
    DECLARE
        @productID int,
        @productPrice money;
    
    -- Specify a product
    SET @productID = 680;
    PRINT @productID;
    
    -- Get the product price
    SELECT @productPrice = ListPrice FROM SalesLT.Product WHERE ProductID = @productID;
    PRINT @ProductPrice;
    ```

1. Run the code and review the output. This time, the PRINT statements result in the variable values being included in the messages produced by the code:

    ```
    8:02:11 AM	Started executing on line 1
    8:02:01 AM	Started executing query.
    8:02:01 AM	680
    8:02:01 AM	1431.50
    8:02:01 AM	Finished executing query.
    8:02:13 AM	SQL Server execution time: 00:00:00.010 | Total duration: 00:00:01.782
    ```

1. Add a SELECT statement to output the variables as a resultset:

    ```sql
    -- Variable declarations
    DECLARE
        @productID int,
        @productPrice money;
    
    -- Specify a product
    SET @productID = 680;
    PRINT @productID;
    
    -- Get the product price
    SELECT @productPrice = ListPrice FROM SalesLT.Product WHERE ProductID = @productID;
    PRINT @productPrice;

    -- Output the results
    SELECT @productID AS ProductID, @productPrice AS Price;
    ```

1. Run the code, and view the results, which should look like this:

    | ProductID | Price |
    | -------- | -- |
    | 680 | 1431.50 |

    (Note that the variable values are still included in the messages because of the PRINT statements)

## Explore variable scope

Now, we'll look at the behavior of variables when code is run in batches.

1. Modify the code to add the batch delimiter GO before the final SELECT statement. This causes the client to sent the code after the GO statement to the server in a new batch:

    ```sql
    -- Variable declarations
    DECLARE
        @productID int,
        @productPrice money;
    
    -- Specify a product
    SET @productID = 680;
    PRINT @productID;
    
    -- Get the product price
    SELECT @productPrice = ListPrice FROM SalesLT.Product WHERE ProductID = @productID;
    PRINT @productPrice;

    GO

    -- Output the results
    SELECT @productID AS ProductID, @productPrice AS Price;
    ```

1. Run the code, and review the error that is returned:

   *Must declare the scalar variable "@productID"*

   Variables are local to the batch in which they're defined. If you try to refer to a variable that was defined in another batch, you get an error saying that the variable wasn't defined. Also, keep in mind that GO is a client command, not a server T-SQL command.

1. Remove the GO statement and verify that the code works as before.

## Use table variables

So far, you've used variables that encapsulate a single value of a specific data type. In Transact-SQL, you can also use *table* variables to encapsulate multiple rows of data.

1. Modify the code to add a declaration for a table variable to insert the results into:

    ```sql
    -- Variable declarations
    DECLARE
        @productID int,
        @productPrice money;
    
    DECLARE @priceData TABLE(ProductID int, Price money);
    
    -- Specify a product
    SET @productID = 680;
    
    -- Get the product price
    SELECT @productPrice = ListPrice FROM SalesLT.Product WHERE ProductID = @productID;
    
    -- Insert the data into a table variable
    INSERT INTO @priceData VALUES(@productID, @productPrice);
    
    -- Output the results
    SELECT * FROM @priceData;
    ```

1. Run the code, and view the results (the data in the table variable).

## Write conditional logic

Conditional logic is used to *branch* program execution flow based on specific conditions. The most common form of conditional logic is the IF..ELSE statement. Transact-SQL also supports a CASE statement.

1. Modify the code as follows to add logic that assigns a price level based on some conditional logic comparing the price of a specific to the averege product price:

    ```sql
    -- Variable declarations
    DECLARE 
        @productID int,
        @productPrice money,
        @averagePrice money,
        @priceLevel nvarchar(20);

     DECLARE @priceData TABLE(ProductID int, Price money, PriceLevel nvarchar(20));
    
    -- Specify a product
    SET @productID = 680;
    PRINT @productID;
    
    -- Get the product price
    SELECT @productPrice = ListPrice FROM SalesLT.Product WHERE ProductID = @productID;
    PRINT @productPrice;
    
    -- Get average product price
    SELECT @averagePrice = AVG(ListPrice) FROM SalesLT.Product;
    PRINT @averagePrice;
    
    -- Determine the price level
    IF @ProductPrice < @averagePrice
        SET @priceLevel = N'Below average'
    ELSE IF @ProductPrice > @averagePrice
        SET @priceLevel = N'Above average'
    ELSE
        SET @priceLevel = N'Average';
    
    -- Insert the data into a table variable
    INSERT INTO @priceData VALUES(@productID, @productPrice, @priceLevel);
    
    -- Output the results
    SELECT * FROM @priceData;
    ```

1. Run the code and review the results.

    The IF..ELSE statement block checks a series of conditions, running the statements for the first one that is found to be true, or statement under the final ELSE block if no match is found.

1. Modify the code to perform the conditional logic using a CASE statement:

    ```sql
    -- Variable declarations
    DECLARE 
        @productID int,
        @productPrice money,
        @averagePrice money,
        @priceLevel nvarchar(20);
    
    DECLARE @priceData TABLE(ProductID int, Price money, PriceLevel nvarchar(20));

    -- Specify a product
    SET @productID = 680;
    PRINT @productID;
    
    -- Get the product price
    SELECT @productPrice = ListPrice FROM SalesLT.Product WHERE ProductID = @productID;
    PRINT @productPrice;
    
    -- Get average product price
    SELECT @averagePrice = AVG(ListPrice) FROM SalesLT.Product;
    PRINT @averagePrice;
    
    -- Determine the price level
    SET @priceLevel =
        CASE
            WHEN @ProductPrice < @averagePrice THEN
                N'Below average'
            WHEN @ProductPrice > @averagePrice THEN
                N'Above average'
            ELSE
                N'Average'
        END;
    
    -- Insert the data into a table variable
    INSERT INTO @priceData VALUES(@productID, @productPrice, @priceLevel);
    
    -- Output the results
    SELECT * FROM @priceData
    ```

1. Run the code and verify that the results are same as before.

## Use a loop to write iterative code

Loops are used to perform logic iteratively, running the same code multiple times - usually until a condition is met. In Transact-SQL, you can implement loops using the WHILE statement.

1. Modify the code to use a WHILE loop to retrieve the price for each of the top 10 selling products (by quantity sold) and determine the price level for each of those products:

    ```sql
    -- Variable declarations
    DECLARE 
        @productID int,
        @productPrice money,
        @averagePrice money,
        @priceLevel nvarchar(20);
    
    DECLARE @priceData TABLE(Rank int, ProductID int, Price money, PriceLevel nvarchar(20));
    
    -- Get average product price
    SELECT @averagePrice = AVG(ListPrice) FROM SalesLT.Product;
    
    -- Loop through the top 10 selling product to determine their price levels
    DECLARE @salesRank int = 1
    WHILE @salesRank <= 10
    BEGIN
        -- Get the product ID for the current sales rank
        WITH RankedProductSales AS(
            SELECT ProductID, RANK() OVER(ORDER BY SUM(OrderQty) DESC) AS 'Rank'
            FROM SalesLT.SalesOrderDetail
            GROUP BY ProductID)
        SELECT @productID = ProductID FROM RankedProductSales WHERE Rank = @salesRank;
    
        -- Get the product price
        SELECT @productPrice = ListPrice FROM SalesLT.Product WHERE ProductID = @productID;
    
        -- Determine the price level
        SET @priceLevel =
            CASE
                WHEN @ProductPrice < @averagePrice THEN
                    N'Below average'
                WHEN @ProductPrice > @averagePrice THEN
                    N'Above average'
                ELSE
                    N'Average'
            END;
    
        -- Insert the results into a table variable
        INSERT INTO @priceData VALUES (@salesRank, @productID, @productPrice, @priceLevel);
    
        -- Increment the sales rank by 1 so we can get the next one in the next loop iteration
        SET @salesRank += 1;
    
    END;
    
    -- Display the results
    SELECT * FROM @priceData;
    ```

1. Run the code and review the results.

    > **Note**: This code is designed to demonstrate how to use a loop. While loops can be useful, it can often be more efficient to use set-based operations to achieve similar results.

## Challenges

Now it's time to try using what you've learnt.

> **Tip**: Try to determine the appropriate solutions for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Assignment of values to variables

You are developing a new Transact-SQL application that needs to temporarily store values drawn from the database, and depending on their values, display the outcome to the user.

1. Create your variables.
    - Write a Transact-SQL statement to declare two variables. The first is an nvarchar with length 30 called salesOrderNumber, and the other is an integer called customerID.
1. Assign a value to the integer variable.
    - Extend your Transact-SQL code to assign the value 29847 to the customerID.
1. Assign a value from the database and display the result.
    - Extend your Transact-SQL to set the value of the variable salesOrderNumber using the column **salesOrderNumber** from the SalesOrderHeader table, filter using the **customerID** column and the customerID variable.  Display the result to the user as OrderNumber.

### Challenge 2: Aggregate product sales

The sales manager would like a list of the first 10 customers that registered and made purchases online as part of a promotion. You've been asked to build the list.

1. Declare the variables:
   - Write a Transact-SQL statement to declare three variables. The first is called **customerID** and will be an Integer with an initial value of 1. The next two variables will be called **fname** and **lname**. Both will be NVARCHAR, give fname a length 20 and lname a length 30.
1. Construct a terminating loop:
   - Extend your Transact-SQL code and create a WHILE loop that will stop when the customerID variable reaches 10.
1. Select the customer first name and last name and display:
   - Extend the Transact-SQL code, adding a SELECT statement to retrieve the **FirstName** and **LastName** columns and assign them respectively to fname and lname. Combine and PRINT the fname and lname.  Filter using the **customerID** column and the customerID variable.

## Challenge Solutions

This section contains suggested solutions for the challenge queries.

### Challenge 1

```sql
DECLARE 
    @salesOrderNUmber nvarchar(30),
    @customerID int;

SET @customerID = 29847;

SET @salesOrderNUmber = (SELECT salesOrderNumber FROM SalesLT.SalesOrderHeader WHERE CustomerID = @customerID)

SELECT @salesOrderNUmber as OrderNumber;
```

### Challenge 2

```sql
DECLARE @customerID AS INT = 1;
DECLARE @fname AS NVARCHAR(20);
DECLARE @lname AS NVARCHAR(30);

WHILE @customerID <=10
BEGIN
    SELECT @fname = FirstName, @lname = LastName FROM SalesLT.Customer
        WHERE CustomerID = @CustomerID;
    PRINT @fname + N' ' + @lname;
    SET @customerID += 1;
END;
```
