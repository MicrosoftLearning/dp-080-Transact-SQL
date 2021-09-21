---
lab:
    title: 'Implement transactions with Transact SQL'
    module: 'Additional exercises'
---

# Implement transactions with Transact SQL

In this lab, you'll use T-SQL statements to see the impact of using transactions in the **AdventureWorks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the AdventureWorks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Insert data without transactions

Consider a website that needs to store customer information. As part of the customer registration, data about a customer and their address need to stored. A customer without an address will cause problems for the shipping when orders are made.

In this exercise you'll use a transaction to ensure that when a row is inserted into the **Customer** and **Address** tables, a row is also added to the **CustomerAddress** table. If one insert fails, then all will fail.

1. Start Azure Data Studio.
2. In the **Connections** pane, double-click the **AdventureWorks** server. A green dot will appear when the connection is successful.
3. Right click the **AdventureWorks** server and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
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

Two of the statements appear to have succeeded, but the third failed.

7. Right click the **AdventureWorks** server and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
8. Enter the following T-SQL code into the new query window:

```
SELECT * FROM SalesLT.Customer ORDER BY ModifiedDate DESC;
```

A row for *Norman Newcustomer* was inserted into the Customer table (and anotherw as in serted into the Address table). However, the insert for the CustomerAddress table failed with a duplicate key error. The database is now inconsistent as there's no link between the new customer and their address.

To fix this, you'll need to delete the two rows that were inserted.

9. Right click the **AdventureWorks** server and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
10. Enter the following T-SQL code into the new query window and run it to delete the inconsistent data:

```
DELETE SalesLT.Customer
WHERE CustomerID = IDENT_CURRENT('SalesLT.Customer');

DELETE SalesLT.Address
WHERE AddressID = IDENT_CURRENT('SalesLT.Address');
```

> **Note**: This code only works because you are the only user working in the database. In a real scenario, you would need to ascertain the IDs of the records that were inserted and specify them explicitly in case new customer and address records had been inserted since you ran your original code.

## Insert data as using a transaction

All of these statements need to run as a single atomic transaction. If any one of them fails, then all statements should fail. Let's group them together in a transaction.

1. Switch back to the original query window with the INSERT statements, and modify the code to enclose the original INSERT statements in a transaction, like this:

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

2. Run the code, and review the output message:


> (1 row affected)
>
> (1 row affected)
>
> Msg 241, Level 16, State 1, Line 9
> Conversion failed when converting date and/or time from character string.

Again, it looks like the first two statements succeeded and the third one failed.

3. Switch to the query containing the SELECT statement to check for a new customer record, and run it. This time, there should be no record for *Norman Newcustomer*. Using a transaction with these statements has triggered an automatic rollback. The level 16 conversion error is high enough to cause all statements to be rolled back.

## Handle errors and explicitly rollback transactions

Lower level errors can require that you explicitly handle the error and rollback any active transactions.

1. Switch back to the original INSERT query script, and modify the transaction as follows:

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

2. Run the modified code. The output message this time is:

> (1 row affected)
>
> (1 row affected)
>
> Msg 2627, Level 14, State 1, Line 9
> Violation of UNIQUE KEY constraint 'AK_CustomerAddress_rowguid'. Cannot insert duplicate key in object 'SalesLT.CustomerAddress'. The duplicate key value is (16765338-dbe4-4421-b5e9-3836b9278e63).

3. Switch back to the query window containing the SELECT customer statement and run the query to see if the *Norman Newcustomer* row was added.

    Even though an error occurred in the transaction, a new record has been added and the database is once again inconsistent.

4. Switch back to the query window containing the DELETE statements, and run it to delete the new inconsistent data.

    Enclosing the statements in a transaction isn't enough to deal with lower priority errors. You need to catch these errors and explicitly use a ROLLBACK statement. We need to combine batch error handling and transactions to resolve our data consistency issue.

5. Switch back to the original query window, and modify the code to enclose the transaction in a TRY/CATCH block, and use the ROLLBACK TRANSACTION statement if an error occurs.

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

6. Run the code and review the results:

> Started executing query at Line 1
>
> (1 row affected)
>
> (1 row affected)
>
> (0 rows affected)

Now there isn't any error message so it looks like two rows were affected.

7. Switch back to the query window containing the SELECT customer statement and run the query to see if the *Norman Newcustomer* row was added.

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

5. Switch back to the query window containing the SELECT customer statement and run the query to verify that the *Norman Newcustomer* row was added.

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

8. Switch back to the query window containing the SELECT customer statement and run the query to verify that a record for *Ann Othercustomer* has been inserted. The transaction succeeded and was not rolled back, even though an error subsequently occurred.

## Explore transaction concurrency

Isolation levels determine the visibility of data modifications made in transactions across multiple sessions with the database. On-premises SQL Server has a default isolation level of **READ_COMMITTED_SNAPSHOT_OFF**. This level of isolation will hold locks on rows while a transaction is acting on it. For example, inserting a customer into the customer table. If the update takes a long time to run, any queries on that table from other sessions will be blocked from running until the transaction is committed or rolled back.

1. In Azure Data Studio, close all open query panes.
2. In the **Connections** pane, ensure that the **AdventureWorks** server has a green icon indicating an active connection. Then, in the header for the **Servers** section, use the **new Connection** icon to create a new connection with the following properties:
    - **Connection type**: Microsoft SQL Server
    - **Server**: (local)\sqlexpress
    - **Authentication type**: Windows Authentication
    - **Database**: adventureworks
3. After the new connection has been made, verify that the **Connections** pane now includes two connections (which represent two different connections to the same database):
    - **AdventureWorks**
    - **(local)\sqlexpress**

4. Right-click the **AdventureWorks** and create a new query. Then enter the following code (but do <u>not</u> run it yet):

```
BEGIN TRANSACTION;

    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
    VALUES (0,  'Yeta','Nothercustomer','yeta0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=', NEWID(), GETDATE());

    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
    VALUES ('2067 Park Lane', 'Redmond','Washington','United States','98007', NEWID(), GETDATE());

    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', NEWID(), GETDATE());

COMMIT TRANSACTION;
```

5. Right-click the **(loval)\sqlexpress** connection and create a new query. Then enter the following code:

```
SELECT COUNT(*) FROM SalesLT.Customer
```

6. Run the SELECT COUNT(*) query and note the number of counted rows. Notice the query returns results quickly.

7. Return the transaction query for the **AdventureWorks** connection and highlight BEGIN TRANSACTION and INSERT statements (but <u>not</u> the COMMIT TRANSACTION; statement) Then use the **&#x23f5;Run** to run only thr highlighted code.

    As this is in a transaction that hasn't been committed, running the SELECT COUNT(*) query in the other window will be blocked.

8. In the other query pane, run the SELECT COUNT(*) query and note that the query doesn't finish.

9. To prove the query is blocked by the transaction, highlight and run the COMMIT TRANSACTION; statement in the other window.

10. Switch back to the SELECT COUNT(*)`query, and verify that it completes and returns the correct number of customers.

## Change how concurrency is handled on a database

Concurrency can be changed to allow database queries on tables while there are transactions inserting or updating them. To change this enable READ_COMMITTED_SNAPSHOT_ON.

1. Create a new query from the **AdventureWorks** connection, and run this Transact-SQL code in it.

```
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
GO
```

2. Switch to the transaction query pane that's connected to the **AdventureWorks** connection, and once again highlight the BEGIN TRANSACTION and INSERT statements (but <u>not</u> the COMMIT TRANSACTION; statement) and run the ighlighted code.
3. Switch to the query pane with the SELECT COUNT(*) query (connected to the **(local)\sqlexpress** connection) and run it. The query results reflect the current state of the database as the INSERT statement hasn't been committed yet.
4. In the transaction query pane, highlight the COMMIT TRANSACTION; statement and run it.
5. Re-run the SELECT COUNT(*) query and note that the total customers has increased by 1.

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
