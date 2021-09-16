---
lab:
    title: 'Implement error handling with T-SQL'
    module: 'Module 3: Implement error handling with T-SQL'
---

In this lab, you'll use T-SQL statements to test various error handling techniques in the **adventureworks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Write a basic TRY/CATCH construct

1. Start Azure Data Studio
1. From the Servers pane, double-click the **AdventureWorks connection**. A green dot will appear when the connection is successful.
1. Right click on the AdventureWorks connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.

   :::image type="content" source="../media/select-new-query.png" alt-text="Screenshot showing the selection of the new query option":::

1. The previous step will open a query screen that is connected to the TSQL database.

1. In the query pane, type the following T-SQL code:

    ```
    SELECT CAST(N'Some text' AS int);
    ```

1. Select **Run**.
1. Notice the conversion error:

   ```text
    Msg 245, Level 16, State 1, Line 1
    Conversion failed when converting the nvarchar value 'Some text' to data type int.
   ```

1. Write a TRY/CATCH construct. Your T-SQL code should look like this:

    ```
    BEGIN TRY
        SELECT CAST(N'Some text' AS int);
    END TRY
    BEGIN CATCH
        PRINT 'Error';
    END CATCH;
    ```

1. Highlight the written T-SQL code and select **Run**.
1. Now, we get this response:

   ```text
   Error
   ```

## Display an error number and an error message

1. Right click on the TSQL connection and select New Query
1. Highlight the following T-SQL code:

    ```
    DECLARE @num varchar(20) = '0';
    
    BEGIN TRY
        PRINT 5. / CAST(@num AS numeric(10,4));
    END TRY
    BEGIN CATCH
    
    END CATCH;
    ```

1. Select **Run**. Notice that you didn't get an error because you used the TRY/CATCH construct.
1. Modify the T-SQL code by adding two PRINT statements. The T-SQL code should look like this:

    ```
    DECLARE @num varchar(20) = '0';
    
    BEGIN TRY
        PRINT 5. / CAST(@num AS numeric(10,4));
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS varchar(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;
    ```

1. Highlight the T-SQL code and select **Run**.
1. Notice that an error is now produced, but it's one that you defined.

   ```text
   Error Number: 8134
   Error Message: Divide by zero error encountered.
   ```

1. Now change the value of the @num variable to look like this:

    ```
    DECLARE @num varchar(20) = 'A';
    ```

1. Highlight the T-SQL code and select **Run**. Notice that you get a different error number and message.

    ```text
    Error Message: Error converting data type varchar to numeric.
    Error Number: 8114
    ```

1. Change the value of the @num variable to look like this:

    ```
    DECLARE @num varchar(20) = ' 1000000000';
    ```

1. Highlight the T-SQL code and select **Run**. Notice that you get a different error number and message.

   ```text
   Error Number: 8115
   Error Message: Arithmetic overflow error converting varchar to data type numeric.
   ```

## Add conditional logic to a CATCH block

1. Modify the T-SQL code you used previously so it looks like this:

```
DECLARE @num varchar(20) = 'A';

BEGIN TRY
    PRINT 5. / CAST(@num AS numeric(10,4));
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() IN (245, 8114)
    BEGIN
        PRINT 'Handling conversion error...'
    END
    ELSE
    BEGIN 
        PRINT 'Handling non-conversion error...';
    END;

    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS varchar(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
END CATCH;
```

1. Highlight the written query and select **Run**.  You'll see that message returned now contains more information:

   ```text
   Handling conversion error...
   Error Number: 8114
   Error Message: Error converting data type varchar to numeric.
   ```

1. Change the value of the @num variable to look like this:

    ```
    DECLARE @num varchar(20) = '0';
    ```

1. Highlight the T-SQL code and select **Run**. This produces a different type of error message:

```text
Handling non-conversion error...
Error Number: 8134
Error Message: Divide by zero error encountered.
```

## Use THROW to pass an error message back to the client

1. Right click on the TSQL connection and select New Query
1. Highlight the following T-SQL code:

    ```
    CREATE PROCEDURE dbo.GetErrorInfo AS
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS varchar(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS varchar(10));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS varchar(10));
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS varchar(10));
    PRINT 'Error Proc: ' + COALESCE(ERROR_PROCEDURE(), 'Not within procedure');
    ```

1. Select **Run**. You've created a stored procedure named dbo.GetErrorInfo.
1. Modify the T-SQL code under TRY/CATCH to look like this:

    ```
    DECLARE @num varchar(20) = '0';
    
    BEGIN TRY
        PRINT 5. / CAST(@num AS numeric(10,4));
    END TRY
    BEGIN CATCH
        EXECUTE dbo.GetErrorInfo;
    END CATCH;
    ```

1. Highlight the written T-SQL code and select **Run**.  This will trigger the stored procedure and display:

   ```text
    Error Number: 8134
    Error Message: Divide by zero error encountered.
    Error Severity: 16
    Error State: 1
    Error Line: 4
    Error Proc: Not within procedure
   ```

## Rethrow the Existing Error Back to a Client

1. If you still have the T-SQL from the first exercise, then modify it to look like this, otherwise type this:

    ```
    DECLARE @num varchar(20) = '0';
    
    BEGIN TRY
        PRINT 5. / CAST(@num AS numeric(10,4));
    END TRY
    BEGIN CATCH
        EXECUTE dbo.GetErrorInfo; 
        THROW;
    END CATCH;
    ```

1. Highlight the written T-SQL code and select **Run**.  Here you'll see that it executes the stored procedure, and then throws the error message again.

   ```text
    Error Number: 8134
    Error Message: Divide by zero error encountered.
    Error Severity: 16
    Error State: 1
    Error Line: 4
    Error Proc: Not within procedure
    Msg 8134, Level 16, State 1, Line 4
    Divide by zero error encountered.
   ```

## Add an Error Handling Routine

1. If you still have the T-SQL from the second exercise, then modify it to look like this, otherwise type this:

```
DECLARE @num varchar(20) = 'A';

BEGIN TRY
    PRINT 5. / CAST(@num AS numeric(10,4));
END TRY
BEGIN CATCH
    EXECUTE dbo.GetErrorInfo;
    
    IF ERROR_NUMBER() = 8134
    BEGIN
        PRINT 'Handling devision by zero...';
    END
    ELSE 
    BEGIN
        PRINT 'Throwing original error';
        THROW;
    END;
    
END CATCH;
```

1. Highlight the written T-SQL code and select **Run**.  As you'll see, it executes the stored procedure to display the error, Identifies that it isn't error number 8134, and throws the error again.

    ```txt
    Error Number: 8114
    Error Message: Error converting data type varchar to numeric.
    Error Severity: 16
    Error State: 5
    Error Line: 5
    Error Proc: Not within procedure
    Throwing original error
    Msg 8114, Level 16, State 5, Line 5
    Error converting data type varchar to numeric.
    ```

## Return to Microsoft Learn

When you've finished the exercise, complete the knowledge check-in Microsoft Learn.
When the link above opens in another browser tab, return to this one to end the lab environment.

## Challenges

Now it's time to try using what you've learnt.

> **Tip**: Try to determine the appropriate solutions for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Catch errors and display only valid records

The marketing manager is using a T-SQL query, but he is getting unexpected results. They have asked you to make the code more resilient, to stop it crashing and to not display duplicates when there is no data.

```
    DECLARE @customerID AS INT = 30110;
    DECLARE @fname AS NVARCHAR(20);
    DECLARE @lname AS NVARCHAR(30);
    DECLARE @maxReturns AS INT = 1; 
    
    WHILE @maxReturns <= 10
    BEGIN
        SELECT @fname = FirstName, @lname = LastName FROM SalesLT.Customer
            WHERE CustomerID = @CustomerID;
        PRINT @fname + N' ' + @lname;
        SET @maxReturns += 1;
        SET @CustomerID += 1;
    END;
```

1. Catch the error
    - Add a TRY .. CATCH block around the SELECT query.
2. Warn the user that an error has occurred
    - Extend your TSQL code to display a warning to the user that their is an error.
3. Only display valid customer records
    - Extend the T-SQL using the @@ROWCOUNT > 0 check to only display a result if the customer ID exists.

### Challenge 2: Create a simple error display procedure

Error messages and error handling are essential for good code. Your manager has asked you to develop a common error display procedure.  Use this sample code as your base.

```
    DECLARE @num varchar(20) = 'Challenge 2';
    
    PRINT 'Casting: ' + CAST(@num AS numeric(10,4));
```

1. Catch the error
   - Add a TRY...CATCH around the PRINT statement.
1. Create a stored procedure
   - Create a stored procedure called dbo.DisplayErrorDetails.  It should display a title and the value for **ERROR_NUMBER**, **ERROR_MESSAGE** and **ERROR_SEVERITY**.
1. Display the error information
   - Use the stored procedure to display the error information when an error occurs.

## Challenge Solutions

This section contains suggested solutions for the challenge queries.

### Challenge 1

1. Catch the error

```
DECLARE @customerID AS INT = 30110;
DECLARE @fname AS NVARCHAR(20);
DECLARE @lname AS NVARCHAR(30);
DECLARE @maxReturns AS INT = 1;

WHILE @maxReturns <= 10
BEGIN
    BEGIN TRY
        SELECT @fname = FirstName, @lname = LastName FROM SalesLT.Customer
            WHERE CustomerID = @CustomerID;

        PRINT CAST(@customerID as NVARCHAR(20)) + N' ' + @fname + N' ' + @lname;
    END TRY
    BEGIN CATCH

    END CATCH;

    SET @maxReturns += 1;
    SET @CustomerID += 1;
END;
```

1. Warn the user that an error has occurred

```
DECLARE @customerID AS INT = 30110;
DECLARE @fname AS NVARCHAR(20);
DECLARE @lname AS NVARCHAR(30);
DECLARE @maxReturns AS INT = 1;

WHILE @maxReturns <= 10
BEGIN
    BEGIN TRY
        SELECT @fname = FirstName, @lname = LastName FROM SalesLT.Customer
            WHERE CustomerID = @CustomerID;

            PRINT CAST(@customerID as NVARCHAR(20)) + N' ' + @fname + N' ' + @lname;
    END TRY
    BEGIN CATCH
        PRINT 'Unable to run query'
    END CATCH;

    SET @maxReturns += 1;
    SET @CustomerID += 1;
END;
    ```

1. Only display valid customer records

```
DECLARE @customerID AS INT = 30110;
DECLARE @fname AS NVARCHAR(20);
DECLARE @lname AS NVARCHAR(30);
DECLARE @maxReturns AS INT = 1;

WHILE @maxReturns <= 10
BEGIN
    BEGIN TRY
        SELECT @fname = FirstName, @lname = LastName FROM SalesLT.Customer
            WHERE CustomerID = @CustomerID;

        IF @@ROWCOUNT > 0 
        BEGIN
            PRINT CAST(@customerID as NVARCHAR(20)) + N' ' + @fname + N' ' + @lname;
        END
    END TRY
    BEGIN CATCH
        PRINT 'Unable to run query'
    END CATCH

    SET @maxReturns += 1;
    SET @CustomerID += 1;
END;
```

### Challenge 2

1. Catch the error

```
DECLARE @num varchar(20) = 'Challenge 2';

BEGIN TRY
    PRINT 'Casting: ' + CAST(@num AS numeric(10,4));
END TRY
BEGIN CATCH

END CATCH;
```

1. Create a stored procedure

```
CREATE PROCEDURE dbo.DisplayErrorDetails AS
PRINT 'ERROR INFORMATION';
PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS varchar(10));
PRINT 'Error Message: ' + ERROR_MESSAGE();
PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS varchar(10));
```

1. Display the error information

```
DECLARE @num varchar(20) = 'Challenge 2';

BEGIN TRY
    PRINT 'Casting: ' + CAST(@num AS numeric(10,4));
END TRY
BEGIN CATCH
    EXECUTE dbo.DisplayErrorDetails;
END CATCH;
```
