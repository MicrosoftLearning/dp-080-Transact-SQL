---
lab:
    title: 'Implement transactions with Transact SQL'
    module: 'Additional exercises'
---

In this lab, you'll use T-SQL statements to see the impact of using transactions in the **AdventureWorks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the AdventureWorks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Insert data without transactions

Consider a website that needs to store customer information. As part of the customer registration, data about a customer and their address need to stored. A customer without an address will cause problems for the shipping when orders are made.

In this exercise you'll use a transaction to ensure that when a row is inserted into the **Customer** and **Address** tables, a row is also added to the **CustomerAddress** table. If one insert fails, then all will fail.

1. Start Azure Data Studio.
2. From the Servers pane, double-click the **AdventureWorks** connection. A green dot will appear when the connection is successful.
3. Right click the **AdventureWorks** connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
4. Enter the following T-SQL code into the query window:

```
INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', NEWID(), '12-1-20212'); 
```

5. Select **&#x23f5;Run** at the top of the query window, or press the <kbd>F5</kbd> key to run the code.
6. Note the output messages, which should look like this:

> (1 row affected)
>
> (1 row affected)
>
> Conversion failed when converting date and/or time from character string.

Two rows are added, one to the Customer table and one to the Address table. However, the insert for the CustomerAddress table failed with a duplicate key error. The database is now inconsistent as there's no link between the new customer and their address.

To fix this, you'll need to delete the two rows that were inserted.

7. Right click the **AdventureWorks** connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
8. Enter the following T-SQL code into the new query window and run it to delete the inconsistent data:

```
DELETE SalesLT.Customer
WHERE CustomerID = IDENT_CURRENT('SalesLT.Customer');

DELETE SalesLT.Address
WHERE AddressID = IDENT_CURRENT('SalesLT.Address');
```

> **Note**: This code only works because you are the only user working in the database. In a real scenario, you would need to ascertain the IDs of the records that were inserted and specify them explicitly in case new customer and address records had been inserted since you ran your original code.

## Insert data as using a transaction

All of these statements need to run as a single atomic transaction. If any one of them fails, then all statements should fail. Let's group them together in a transaction.

1. Switch back to the original query window, and modify the code to enclose the original INSERT statements in a transaction, like this:

```
BEGIN TRANSACTION;

INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=', NEWID(), GETDATE());

INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6', NEWID(), GETDATE());

INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', NEWID(), '12-1-20212');

COMMIT TRANSACTION;
```

2. Run the code, and note that it looks like exactly the same thing happens. The output message being:


> (1 row affected)
>
> (1 row affected)
>
> Msg 241, Level 16, State 1, Line 9
> Conversion failed when converting date and/or time from character string.

Check to see if the customer row was inserted with this query.

3. Right click the **AdventureWorks** connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
4. Enter the following T-SQL code into the new query window:

```
SELECT * FROM SalesLT.Customer WHERE FirstName = 'Norman' AND LastName = 'Newcustomer';
```

Using a transaction with these statements has triggered an automatic rollback. The level 16 conversion error is high enough to cause all statements to be rolled back. However, lower level errors need you to explicitly handle errors and the rollback.

5. Right click the **AdventureWorks** connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
6. Enter the following T-SQL code into the new query window and run it to try and insert the new customer:

```
BEGIN TRANSACTION;

INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=', NEWID(), GETDATE());

INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6', NEWID(), GETDATE());

INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

COMMIT TRANSACTION;
``` 

The output message this time is:

> (1 row affected)
>
> (1 row affected)
>
> Msg 2627, Level 14, State 1, Line 9
> Violation of UNIQUE KEY constraint 'AK_CustomerAddress_rowguid'. Cannot insert duplicate key in object 'SalesLT.CustomerAddress'. The duplicate key value is (16765338-dbe4-4421-b5e9-3836b9278e63).

7. Switch back to the query window containing the SELECT customer statements and run the query to see if the row was added.

8. Switch back to the query window containing the DELETE statements, and run it to delete the new inconsistent data.

## Handle errors in a transaction

Using transactions on their own without handling lower level errors won't solve the problem. You need to catch these errors and explicitly use a `ROLLBACK` statement. We need to combine batch error handling and transactions to resolve our data consistency issue.

1. Switch back to the original query window, and modify the code to enclose the transaction in a `TRY/CATCH` block, and use the `ROLLBACK TRANSACTION` statement if an error occurs.

```
BEGIN TRY
BEGIN TRANSACTION;

  INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
  VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back.';
END CATCH;    
```

2. Run the code and review the results:

> Started executing query at Line 1
>
> (1 row affected)
>
> (1 row affected)
>
> (0 rows affected)

Now there isn't any error message so it looks like two rows were affected.

3. Open a new query window, and run the following query to view the most recently modified record in the **Customer** table.

```
SELECT TOP (1) * FROM SalesLT.Customer
ORDER BY ModifiedDate DESC;   
```

Note that the most recently modified customer record is <u>not</u> for *Norman Newcustomer* - the INSERT statement that succeeded has been rolled back to ensure the database remains consistent.

## Check the transaction state before rolling back

The CATCH block will handle errors that occur anywhere in the TRY block, so if an error were to occur outside of the BEGIN TRANSACTION...COMMIT TRANSACTION block, there would be no active transaction to roll back. To avoid this issue, you can check the current transaction state with XACT_STATE(), which returns one of the following values:

- **-1**: There is an active transaction in process that cannot be committed.
- **0**: There are no transactions in process.
- **1**: There is an active transaction in process that can be committed or rolled back.

1. Back in the original query window, surround the ROLLBACK statements with an IF statement checking the value, so your code looks like this.

```
BEGIN TRY
BEGIN TRANSACTION;

  INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt, rowguid, ModifiedDate) 
  VALUES (0, 'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,  ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
      ROLLBACK TRANSACTION;
      PRINT 'Transaction rolled back.';
  END;
END CATCH
```

2. Run the modified code, and review the output - noting that an in-process transaction was detected and rolled back.

3. Modify the code as follows to avoid specifying an explicit **rowid** (which was caused the duplicate key error)

```
BEGIN TRY
BEGIN TRANSACTION;

  INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt, rowguid, ModifiedDate) 
  VALUES (0, 'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,  ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';
END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
      ROLLBACK TRANSACTION;
      PRINT 'Transaction rolled back.';
  END;
END CATCH
```

4. Run the code, and note that this time, all three INSERT statement succeed.

5. Switch to the query window that contains code to select the most recently modified customer and run it to verify that a record for *Norman Newcustomer* has been inserted.

6. Back in the original query window, modify the code to insert another customer - this time throwing an error within the TRY block after the transaction has been committed:

```
BEGIN TRY
BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt, rowguid, ModifiedDate)     VALUES (0, 'Ann','Othercustomr','ann0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());;

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,  ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', GETDATE());

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

THROW 51000, 'Some kind of error', 1;

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
      ROLLBACK TRANSACTION;
      PRINT 'Transaction rolled back.';
  END;
END CATCH
```

7. Run the code and review the output. All three INSERT statements should succeed, but an error is caught by the CATCH block.

8. Switch to the query window that contains code to select the most recently modified customer and run it to verify that a record for *Ann Othercustomer* has been inserted. The transaction succeeded and was not rolled back, even though an error subsequently occurred.

## Explore transaction concurrency

On-premises SQL Server has a default isolation level of **READ_COMMITTED_SNAPSHOT_OFF**. This level of isolation will hold locks on rows while a transaction is acting on it. For example, inserting a customer into the customer table. If the update takes a long time to run, any queries on that table will be blocked from running until the transaction is committed or rolled back.

1. Start a new instance of Azure Data Studio by right-clicking in the task bar on Azure Data Studio  and then select **Azure Data Studio**.
2. There should be two instances running, rearrange the Azure Data Studio windows so that both windows can be seen on the same screen.

![A screenshot showing two instances of Azure Data Studio side by side.](./images/side-by-side.png)

3. Highlight the `BEGIN TRANSACTION` and first `INSERT` statements in the first window but do **not** execute them.

4. In the second window enter this query.

```
SELECT COUNT(*) FROM SalesLT.Customer
```

5. Run the `SELECT COUNT(*)` query and note the number of counted rows. Notice the query returns results quickly.

6. Run the selected `BEGIN TRANSACTION` statements you selected in the first window. The message is:

> (1 row affected)
>
> Total execution time: 00:00:01.921

As this is in a transaction that hasn't been committed, running the `SELECT COUNT(*)` query in the other window will be blocked.

7. Run the `SELECT COUNT(*)` query and note that the query doesn't finish.

8. To prove the query is blocked by the transaction, highlight and run the `COMMIT TRANSACTION` statement in the other window.

9. The `SELECT COUNT(*)` query will complete as soon as the transaction is committed. With the correct number of customers.

## Change how concurrency is handled on a database

Concurrency can be changed to allow database queries on tables while there are transactions inserting or updating them. To change this enable `READ_COMMITTED_SNAPSHOT_ON`.

1. In the window with the transaction statements, add this T-SQL statement to the bottom of the query window.

```
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
GO
```

2. Run this command to change the **AdventureWorks** database concurrency model.
3. Re-run the above steps from **step 3**, highlight the `BEGIN TRANSACTION` and `INSERT` statements.
4. The step running the SQL query in the second window will return a result instantly, however the count will be the same as the last time the query was run.
5. The query is working against the current state of the database as the `INSERT` statement hasn't been committed yet.
6. Highlight the `COMMIT TRANSACTION` statement and run it.
7. Re-run the SQL query and note that the total customers has increased by 1.

Be careful when selecting what isolation levels to use in a database. In some scenarios returning the current state of data before a transaction has been committed is worse than a query being blocked and waiting for all the data to be in the correct state.

## Challenge

Now it's time to try using what you've learned.

> **Tip**: Try to determine the appropriate solution for yourself. If you get stuck, a suggested solution is provided at the end of this lab.

### Use a transaction to insert data into multiple tables

When a sales order header is inserted, it must have at least one corresponding sales order detail record. Currently, you use the following code to accomplish this:

```
-- Get the highest order ID and add 1
DECLARE @OrderID INT;
SELECT @OrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

-- Insert the order header
INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderID, GETDATE(), DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');

-- Insert one or more order details
INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice)
VALUES (@OrderID, 1, 712, 8.99);
```

You need to encapsulate this code in a transaction so that all inserts succeed or fail as an atomic unit or work.

## Challenge solution

### Use a transaction to insert data into multiple tables

The following code encloses the logic to insert a new order and order detail in a transaction, rolling back the transaction if an error occurs.

```
BEGIN TRY
BEGIN TRANSACTION;
    -- Get the highest order ID and add 1
  DECLARE @OrderID INT;
  SELECT @OrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

  -- Insert the order header
  INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
  VALUES (@OrderID, GETDATE(), DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');
  
  -- Insert one or more order details
  INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice)
  VALUES (@OrderID, 1, 712, 8.99);

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back.'; 
  END;
END CATCH
```

To test the transaction, try to insert an order detail with an invalid product ID, like this:

```
BEGIN TRY
BEGIN TRANSACTION;
    -- Get the highest order ID and add 1
  DECLARE @OrderID INT;
  SELECT @OrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

  -- Insert the order header
  INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
  VALUES (@OrderID, GETDATE(), DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');
  
  -- Insert one or more order details
  INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice)
  VALUES (@OrderID, 1, 'Invalid product', 8.99);

COMMIT TRANSACTION;
PRINT 'Transaction committed.';

END TRY
BEGIN CATCH
  PRINT 'An error occurred.'
  IF (XACT_STATE()) <> 0
  BEGIN
      PRINT 'Transaction in process.'
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back.'; 
  END;
END CATCH
```
