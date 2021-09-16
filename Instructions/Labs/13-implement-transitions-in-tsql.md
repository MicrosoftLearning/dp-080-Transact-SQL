---
lab:
    title: 'Implement transactions with Transact SQL'
    module: 'Additional exercises'
---

In this lab, you'll use T-SQL statements to see the impact of using transactions in the **AdventureWorks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Insert data without transactions

Consider a website that needs to store customer information. As part of the customer registration, data about a customer and their address need to stored. A customer without an address will cause problems for the shipping when orders are made.

In this exercise you will use a transaction to ensure that when a row is inserted into the **Customer** and **Address** tables, a row is also added to the **CustomerAddress** table. If one insert fails, then all will fail.

1. Start Azure Data Studio.
1. From the Servers pane, double-click the **AdventureWorks connection**. A green dot will appear when the connection is successful.
1. Right click on the **AdventureWorks** database and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
1. Copy the following T-SQL code into the query window:

    ```
    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
    VALUES (0,  'Caroline','Vicknair','caroline0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());
    ```

1. Select **&#x23f5;Run** at the top of the query window, or press the <kbd>F5</kbd> key.
1. Note the results messages:

    ```
    (1 row affected)
    (1 row affected)
    Msg 2627, Level 14, State 1, Line 48Violation of UNIQUE KEY constraint 'AK_CustomerAddress_rowguid'. Cannot insert duplicate key in object 'SalesLT.CustomerAddress'. The duplicate key value is (16765338-dbe4-4421-b5e9-3836b9278e63).
    ```

    Two rows are added, one to the Customer table and one to the Address table. However, the insert for the CustomerAddress table failed with a duplicate key error. The database is now corrupted as there's no link between the new customer and their address.

## Insert data as using a transaction

All of these statements need to run as a single atomic transaction. If any one of them fails, then all statements should fail. Let's group them together in a transaction.

1. In the query window add a `BEGIN TRANSACTION` statement before all the other T-SQL. Then at the end of all the transactions add a `COMMIT TRANSACTION`.

    ```
    BEGIN TRANSACTION;

    ... SQL statements

    COMMIT TRANSACTION;
    ```

1. Select **&#x23f5;Run** at the top of the query window, or press the <kbd>F5</kbd> key.

    Note that exactly the same thing happens. Two new rows are inserted and an error happens.

## Handle errors in a transaction

Using transactions on their own without handling errors won't solve the problem. Nowhere in the code are we using a `ROLLBACK` statement. We need to combine batch error handling and transactions to resolve our issue.

1. Replace the contents of the query window with this T-SQL.

    ```
    BEGIN TRY
    BEGIN TRANSACTION;

        INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
        VALUES (0,  'Caroline','Vicknair','caroline0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());
    
        INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
        VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());
    
        INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
        VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
    END CATCH;    
    ```

1. Select **&#x23f5;Run** at the top of the query window, or press the <kbd>F5</kbd> key.

    ```
    Started executing query at Line 1
    (1 row affected)
    (1 row affected)
    (0 rows affected)
    ```

    Now there isn't any error message so it looks like two rows were affected.

1. Open a new query window from the file menu.
1. Check the contents of the **Customer** table with this query.

    ```
    SELECT TOP (20) * 
    FROM SalesLT.Customer 
    ORDER BY CustomerID DESC;    
    ```
    
    Note that there are several duplicate rows for **Caroline Vicknair**. Make a note of how many duplicate rows there are.
1. Select the query window with the `INSERT` statements and select **&#x23f5;Run** at the top of the query window, or press the <kbd>F5</kbd> key.

1. Re-run the select query. See that there's no new row added.

## Challenge

Now it's time to try using what you've learned.

> **Tip**: Try to determine the appropriate solutions for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Use transaction and error handling

Looking at the database diagram can you see any other table relationships that have the same issue as the **Customer** and **CustomerAddress** tables? Write `INSERT` statements inside a transaction and rollback if there are any errors.

1. Identify the tables to use in the statement.
    - Tables with parent/child relationships are good candidates.
1. Write the `TRY` and `CATCH` blocks.
1. Write the `INSERT` statements for the tables.
    - You'll need to find a way to cause an error in one of the statements, if the table has a `rowguid` you could re-use one from an existing row in the same table.

### Challenge 2: Only rollback when there are errors and uncommittable transactions

The example T-SQL so far doesn't give any indication that an error has happened. Enhance the T-SQL statements you wrote in Challenge 1 to display the error details in the results.

Also use the `XACT_STATE` to check the state of the transactions before you roll them back.

1. Where should that statement be added?
    - You only need to run it if there's been an error.
1. You can use the `ERROR_NUMBER()` and `ERROR_MESSAGE()` functions to get details of the last error.
1. Add a condition to check the value of `XACT_STATE` before rolling back.
    - The return value to check for is **1**.

## Challenge solutions

### Challenge 1

Good candidates, where a similar issue could happen, are the **SalesOrderHeader** and **SalesOrderDetail** tables.

1. Open a new query window from the **File** menu.
1. Write the transaction T-SQL statements to insert rows into the **SalesOrderHeader** and **SalesOrderDetail** tables.

    ```
    BEGIN TRY
    BEGIN TRANSACTION;
        INSERT INTO SalesLT.SalesOrderHeader (RevisionNumber,OrderDate,DueDate,Status,OnlineOrderFlag,CustomerID,SubTotal,ShipMethod,TaxAmt,Freight,rowguid,ModifiedDate) 
        VALUES (2,GETDATE(),GETDATE(),5,0,29485, 3182.8264, 'CARGO TRANSPORT',994.6333,994.6333,NEWID(),GETDATE());

        INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID,OrderQty,ProductID,UnitPrice,UnitPriceDiscount,rowguid,ModifiedDate) VALUES (1,1,712,9.99,0,(SELECT TOP 1 rowguid FROM SalesLT.SalesOrderDetail),GETDATE());
      COMMIT TRANSACTION;
      PRINT 'Transaction committed.';
    END TRY
    BEGIN CATCH
      ROLLBACK TRANSACTION;
      PRINT 'Transaction rolled back.';
    END CATCH
    ```

### Challenge 2

1. Change the T-SQL you created in the first challenge to print out the error details and check the `XACT_STATE`.

    ```
    BEGIN TRY
    BEGIN TRANSACTION;
        INSERT INTO SalesLT.SalesOrderHeader (RevisionNumber,OrderDate,DueDate,Status,OnlineOrderFlag,CustomerID,SubTotal,ShipMethod,TaxAmt,Freight,rowguid,ModifiedDate) 
        VALUES (2,GETDATE(),GETDATE(),5,0,29485, 3182.8264, 'CARGO TRANSPORT',994.6333,994.6333,NEWID(),GETDATE());

        INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID,OrderQty,ProductID,UnitPrice,UnitPriceDiscount,rowguid,ModifiedDate) VALUES (1,1,712,9.99,0,(SELECT TOP 1 rowguid FROM SalesLT.SalesOrderDetail),GETDATE());
      COMMIT TRANSACTION;
      PRINT 'Transaction committed.';
    END TRY
    BEGIN CATCH
      PRINT CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE());
      IF (XACT_STATE()) = 1
      BEGIN
          ROLLBACK TRANSACTION;
          PRINT 'Transaction rolled back.';
      END;
    END CATCH
    ```

