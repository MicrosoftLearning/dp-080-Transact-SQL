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
1. From the Servers pane, double-click the **AdventureWorks** connection. A green dot will appear when the connection is successful.
1. Right click the **AdventureWorks** connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
1. Enter the following T-SQL code into the query window:

```
INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());
```

1. Select **&#x23f5;Run** at the top of the query window, or press the <kbd>F5</kbd> key to run the code.
2. Note the results messages:

> (1 row affected)
>
> (1 row affected)
>
> Msg 2627, Level 14, State 1, Line 48Violation of UNIQUE KEY constraint 'AK_CustomerAddress_rowguid'. Cannot insert duplicate key in object 'SalesLT.CustomerAddress'. The duplicate key value is (16765338-dbe4-4421-b5e9-3836b9278e63).

Two rows are added, one to the Customer table and one to the Address table. However, the insert for the CustomerAddress table failed with a duplicate key error. The database is now inconsistent as there's no link between the new customer and their address.

To fix this, you'll need to delete the two rows that were inserted.

3. Right click the **AdventureWorks** connection and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
4. Enter the following T-SQL code into the new query window: and run it to delete the inconsistent data:

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
VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());

INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());

INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());

COMMIT TRANSACTION;
```

2. Run the code, and note that exactly the same thing happens. Two new rows are inserted and an error occurs for the third record.

3. Switch back to the query window containing the DELETE statements, and run it to delete the inconsistent data.

## Handle errors in a transaction

Using transactions on their own without handling errors won't solve the problem. Nowhere in the code are we using a ROLLBACK statement. We need to combine batch error handling and transactions to resolve our issue.

1. Switch back to the original query window, and modify the code to enclose the transaction in a TRY/CATCH block, and use the ROLLBACK TRANSACTION statement if an error occurs.

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

1. Run the code and review the results:

> Started executing query at Line 1
>
> (1 row affected)
>
> (1 row affected)
>
> (0 rows affected)


Now there isn't any error message so it looks like two rows were affected.

2. Open a new query window, and run the following query to view the most recently modified record in the **Customer** table.

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

## Challenge

Now it's time to try using what you've learned.

> **Tip**: Try to determine the appropriate solution for yourself. If you get stuck, sa suggested solution is provided at the end of this lab.

### Use a transaction to insert data into multiple tables

When a sales order header is inserted, it must have at least one corresponding sales order detail record. Currently, you use the following code to accomplish this

```
-- Get the highest order ID and add 1
DECLARE @OrderID INT;
SELECT @OrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

-- Insert the order header
INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderID, GETDATE() ,DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');

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
	VALUES (@OrderID, GETDATE() ,DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');
	
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

To test the transaction, you can try to insert an order detail with an invalid product ID, like this:

```
BEGIN TRY
BEGIN TRANSACTION;
    -- Get the highest order ID and add 1
	DECLARE @OrderID INT;
	SELECT @OrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

	-- Insert the order header
	INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
	VALUES (@OrderID, GETDATE() ,DATEADD(month, 1, GETDATE()), 1, 'CARGO TRANSPORT');
	
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
