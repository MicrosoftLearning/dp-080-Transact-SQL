---
lab:
    title: 'Introduction to programming with T-SQL'
    module: 'Module 1: Introduction to programming with T-SQL'
---

In this lab, you'll use get an introduction to programming using T-SQL techniques using the **adventureworks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Declare variables and retrieve values

1. Start Azure Data Studio
1. From the Servers pane, double-click the **AdventureWorks connection**. A green dot will appear when the connection is successful.
1. Right click on the AdventureWorks connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
1. The previous step will open a query screen that is connected to the adventureworks database.
1. In the query pane, type the following T-SQL code:

    ```
    DECLARE @num int = 5;

    SELECT @num AS mynumber;
    ```

1. Highlight the above T-SQL code and select **&#x23f5;Run**.
1. This will give the result:

   | mynumber |
   | -------- |
   | 5 |

1. In the query pane, type the following T-SQL code after the previous one:

    ```
    DECLARE
    @num1 int,
    @num2 int;
    
    SET @num1 = 4;
    SET @num2 = 6;
    
    SELECT @num1 + @num2 AS totalnum;
    ```

1. Highlight the written T-SQL code and select **&#x23f5;Run**.
1. This will give the result:

   | totalnum |
   | -------- |
   | 10 |

   You've now seen how to declare variables and how to retrieve values.

## Use variables with batches

Now, we'll look at how to declare variables in batches.

1. Right click on the TSQL connection and select **New Query**
1. In the query pane, type the following T-SQL code:

    ```
    DECLARE 
    @empname nvarchar(30),
    @empid int;
    
    SET @empid = 5;
    
    SET @empname = (SELECT FirstName + N' ' + LastName FROM SalesLT.Customer WHERE CustomerID = @empid)
    
    SELECT @empname AS employee;
    ```

1. Highlight the written T-SQL code and Select **&#x23f5;Run**.
1. This will give you this result:

   | employee |
   | -------- |
   | Lucy Harrington |

1. Change the @empid variable’s value from 5 to 2 and execute the modified T-SQL code you'll get:

   | employee |
   | -------- |
   | Keith Harris |

1. Now, in the code you just copied, add the batch delimiter GO before this statement:

   ```
   SELECT @empname AS employee;
   ```

1. Make sure your T-SQL code looks like this:

   ```
    DECLARE 
    @empname nvarchar(30),
    @empid int;
    
    SET @empid = 5;
    
    SET @empname = (SELECT FirstName + N' ' + LastName FROM SalesLT.Customer WHERE CustomerID = @empid)
    
    GO
    SELECT @empname AS employee;
    ```

1. Highlight the written T-SQL code and select **&#x23f5;Run****.
1. Observe the error:

    Must declare the scalar variable "@empname".

Variables are local to the batch in which they're defined. If you try to refer to a variable that was defined in another batch, you get an error saying that the variable wasn't defined. Also, keep in mind that GO is a client command, not a server T-SQL command.

## Write basic conditional logic

1. Right click on the TSQL connection and select **New Query**
1. In the query pane, type the following T-SQL code:

    ```
    DECLARE 
    @i int = 8,
    @result nvarchar(20);
    
    IF @i < 5
        SET @result = N'Less than 5'
    ELSE IF @i <= 10
        SET @result = N'Between 5 and 10'
    ELSE if @i > 10
        SET @result = N'More than 10'
    ELSE
        SET @result = N'Unknown';
    
    SELECT @result AS result;
    ```

1. Highlight the written T-SQL code and select **&#x23f5;Run**.
1. Which should result in:

   | result |
   | -------- |
   | Between 5 and 10 |

1. In the query pane, type the following T-SQL code after the previous code:

    ```
    DECLARE 
    @i int = 8,
    @result nvarchar(20);
    
    SET @result = 
    CASE 
    WHEN @i < 5 THEN
        N'Less than 5'
    WHEN @i <= 10 THEN
        N'Between 5 and 10'
    WHEN @i > 10 THEN
        N'More than 10'
    ELSE
        N'Unknown'
    END;

    SELECT @result AS result;
    ```

This code uses a CASE expression and only one SET expression to get the same result as the previous T-SQL code. Remember to use a CASE expression when it's a matter of returning an expression. However, if you need to execute multiple statements, you can't replace IF with CASE.

1. Highlight the written T-SQL code and select **&#x23f5;Run**.
1. Which should result in the same answer that we had before:

   | result |
   | -------- |
   | Between 5 and 10 |

## Execute loops with WHILE statements

1. Right click on the TSQL connection and select **New Query**
1. In the query pane, type the following T-SQL code:

    ```
    DECLARE @i int = 1;
    
    WHILE @i <= 10
    BEGIN
        PRINT @i;
        SET @i = @i + 1;
    END;
    ```

1. Highlight the written T-SQL code and select **&#x23f5;Run**.
1. This will result in:

    | Started executing query at Line 1 |
    | ------------- |
    | 1 |
    | 2 |
    | 3 |
    | 4 |
    | 5 |
    | 6 |
    | 7 |
    | 8 |
    | 9 |
    | 10 |

## Return to Microsoft Learn

When you've finished the exercise, make sure to end the lab environment before you complete the knowledge check in Microsoft Learn.  

## Challenges

Now it's time to try using what you've learnt.

> **Tip**: Try to determine the appropriate solutions for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Assignment of values to variables

You are developing a new T-SQL application that needs to temporarily store values drawn from the database, and depending on their values, display the outcome to the user.

1. Create your variables.
    - Write a T-SQL statement to declare two variables. The first is an nvarchar with length 30 called salesOrderNumber, and the other is an integer called customerID.
1. Assign a value to the integer variable.
    - Extend your TSQL code to assign the value 29847 to the customerID.
1. Assign a value from the database and display the result.
    - Extend your TSQL to set the value of the variable salesOrderNumber using the column **salesOrderNUmber** from the SalesOrderHeader table, filter using the **customerID** column and the customerID variable.  Display the result to the user as OrderNumber.

### Challenge 2: Aggregate product sales

The sales manager would like a list of the first 10 customers that registered and made purchases online as part of a promotion. You've been asked to build the list.

1. Declare the variables:
   - Write a T-SQL statement to declare three variables. The first is called **customerID** and will be an Integer with an initial value of 1. The next two variables will be called **fname** and **lname**. Both will be NVARCHAR, give fname a length 20 and lname a length 30.
1. Construct a terminating loop:
   - Extend your T-SQL code and create a WHILE loop that will stop when the customerID variable reaches 10.
1. Select the customer first name and last name and display:
   - Extend the T-SQL code, adding a SELECT statement to retrieve the **FirstName** and **LastName** columns and assign them respectively to fname and lname. Combine and PRINT the fname and lname.  Filter using the **customerID** column and the customerID variable.

## Challenge Solutions

This section contains suggested solutions for the challenge queries.

### Challenge 1

1. Create your variables

    ```
    DECLARE 
    @salesOrderNUmber nvarchar(30),
    @customerID int;
    ```

1. Assign a value to the integer variable.

    ```
    DECLARE 
    @salesOrderNUmber nvarchar(30),
    @customerID int;

    SET @customerID = 29847;
    ```

1. Assign a value from the database and display the result

    ```
    DECLARE 
    @salesOrderNUmber nvarchar(30),
    @customerID int;

    SET @customerID = 29847;
    
    SET @salesOrderNUmber = (SELECT salesOrderNumber FROM SalesLT.SalesOrderHeader WHERE CustomerID = @customerID)

    SELECT @salesOrderNUmber as OrderNumber;
    ```

### Challenge 2

The sales manager would like a list of the first 10 customers that registered and made purchases online as part of a promotion. You've been asked to build the list.

1. Declare the variables:

    ```
    DECLARE @customerID AS INT = 1;
    DECLARE @fname AS NVARCHAR(20);
    DECLARE @lname AS NVARCHAR(30);
    ```

1. Construct a terminating loop:

    ```
    DECLARE @customerID AS INT = 1;
    DECLARE @fname AS NVARCHAR(20);
    DECLARE @lname AS NVARCHAR(30);
    
    WHILE @customerID <=10
    BEGIN
        SET @customerID += 1;
    END;
    ```

1. Select the customer first name and last name and display:

    ```
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
