---
lab:
    title: 'Implement transactions with Transact SQL'
    module: 'Additional exercises'
---

# Implement transactions with Transact SQL

In this exercise, you'll use transactions to enforce data integrity in the **AdventureWorks** database.

> **Note**: This exercise assumes you have created the **Adventureworks** database.

## Insert data without transactions

Consider a website that needs to store customer information. As part of the customer registration, data about a customer and their address need to be stored. A customer without an address will cause problems for the shipping when orders are made.

In this exercise you'll use a transaction to ensure that when a row is inserted into the **Customer** and **Address** tables, a row is also added to the **CustomerAddress** table to create a link between the customer record and the address record. If one insert fails, then all should fail.

1. Open a query editor for your **Adventureworks** database, and create a new query.
1. In the query pane, type the following code:

    ```sql
    INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
    VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());
    
    INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
    VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6',NEWID(), GETDATE());
    
    INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
    VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', NEWID(), '12-1-20212'); 
    ```

1. Run the query, and review the output messages, which should include the following error message:

    *Conversion failed when converting date and/or time from character string.*

1. Create a new query and enter the following code into the new query window: 

    ```sql
    SELECT TOP 1 c.CustomerID, c.FirstName, c.LastName, ca.AddressID, a.City, c.ModifiedDate
    FROM SalesLT.Customer AS c
    LEFT JOIN SalesLT.CustomerAddress AS ca
        ON c.CustomerID = ca.CustomerID
    LEFT JOIN SalesLT.Address AS a
        ON ca.AddressID = a.AddressID
    ORDER BY c.CustomerID DESC;
    ```

    A new row for *Norman Newcustomer* was inserted into the Customer table (and another was inserted into the Address table). However, the insert for the CustomerAddress table failed. The database is now inconsistent as there's no link between the new customer and their address.

    To fix this, you'll need to delete the two rows that were inserted.

1. Create a new query with the following code and run it to delete the inconsistent data:

    ```sql
    DELETE SalesLT.Customer
    WHERE CustomerID = IDENT_CURRENT('SalesLT.Customer');
    
    DELETE SalesLT.Address
    WHERE AddressID = IDENT_CURRENT('SalesLT.Address');
    ```

    > **Note**: This code only works because you are the only user working in the database. In a real scenario, you would need to ascertain the IDs of the records that were inserted and specify them explicitly in case new customer and address records had been inserted after you ran your original code.

## Insert data using a transaction

All of these statements need to run as a single atomic transaction. If any one of them fails, then all statements should fail. Let's group them together in a transaction.

1. Switch back to the original query window with the INSERT statements, and modify the code to enclose the original INSERT statements in a transaction, like this:

    ```sql
    BEGIN TRANSACTION;
    
        INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
        VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=', NEWID(), GETDATE());
    
        INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
        VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6', NEWID(), GETDATE());
    
        INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
        VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', NEWID(), '12-1-20212');
    
    COMMIT TRANSACTION;
    ```

1. Run the code, and review the output message. Again, it looks like the first two statements succeeded and the third one failed.

1. Switch to the query containing the SELECT statement to retrieve the address city for the latest customer record, and run it. This time, there should be no record for *Norman Newcustomer*. Using a transaction with these statements has triggered an automatic rollback. The level 16 conversion error is high enough to cause all statements to be rolled back.

## Handle errors and explicitly rollback transactions

Lower level errors can require that you explicitly handle the error and rollback any active transactions.

1. Switch back to the original INSERT query script, and modify the transaction as follows:

    ```sql
    BEGIN TRANSACTION;
    
        INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt,    rowguid, ModifiedDate) 
        VALUES (0,  'Norman','Newcustomer','norman0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=', NEWID(), GETDATE());
    
        INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode, rowguid,    ModifiedDate) 
        VALUES ('6388 Lake City Way', 'Burnaby','British Columbia','Canada','V5A 3A6', NEWID(), GETDATE());
    
        INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType, rowguid, ModifiedDate)
        VALUES (IDENT_CURRENT('SalesLT.Customer'), IDENT_CURRENT('SalesLT.Address'), 'Home', '16765338-dbe4-4421-b5e9-3836b9278e63', GETDATE());
    
    COMMIT TRANSACTION;
    ``` 

1. Run the modified code. This time, a different error (with a lower severity level) occurs:

    *Violation of UNIQUE KEY constraint 'AK_CustomerAddress_rowguid'. Cannot insert duplicate key in object 'SalesLT.CustomerAddress'. The duplicate key value is (16765338-dbe4-4421-b5e9-3836b9278e63).*

1. Switch back to the query containing the SELECT customer statement and run the query to see if the *Norman Newcustomer* row was added.

    Even though an error occurred in the transaction, a new record has been added and the database is once again inconsistent.

1. Switch back to the query containing the DELETE statements, and run it to delete the new inconsistent data.

    Enclosing the statements in a transaction isn't enough to deal with lower priority errors. You need to catch these errors and explicitly use a ROLLBACK statement. We need to combine batch error handling and transactions to resolve our data consistency issue.

1. Switch back to the query containing the transaction to insert a new customer, and modify the code to enclose the transaction in a TRY/CATCH block, and use the ROLLBACK TRANSACTION statement if an error occurs.

    ```sql
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

1. Run the code and review the results and messages.
1. Switch back to the query containing the SELECT customer statement and run the query to see if the *Norman Newcustomer* row was added.

    Note that the most recently modified customer record is <u>not</u> for *Norman Newcustomer* - the INSERT statement that succeeded has been rolled back to ensure the database remains consistent.

## Check the transaction state before rolling back

The CATCH block will handle errors that occur anywhere in the TRY block, so if an error were to occur outside of the BEGIN TRANSACTION...COMMIT TRANSACTION block, there would be no active transaction to roll back. To avoid this issue, you can check the current transaction state with XACT_STATE(), which returns one of the following values:

- **-1**: There is an active transaction in process that cannot be committed.
- **0**: There are no transactions in process.
- **1**: There is an active transaction in process that can be committed or rolled back.

1. Back in the original query to insert a new customer, surround the ROLLBACK statements with an IF statement checking the value, so your code looks like this.

    ```sql
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

1. Run the modified code, and review the output messages - noting that an in-process transaction was detected and rolled back.

1. Modify the code as follows to avoid specifying an explicit **rowid** (which was caused the duplicate key error)

    ```sql
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

1. Run the code, and note that this time, all three INSERT statement succeed.
1. Switch back to the query containing the SELECT customer statement and run the query to verify that the *Norman Newcustomer* row was inserted into the **Customer** table along with the related records in the **Address** and **CustomerAddress** tables.
1. Back in the original INSERT query, modify the code to insert another customer - this time throwing an error within the TRY block after the transaction has been committed:

    ```sql
    BEGIN TRY
        BEGIN TRANSACTION;
        
            INSERT INTO SalesLT.Customer (NameStyle, FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt, rowguid, ModifiedDate)
            VALUES (0, 'Ann','Othercustomr','ann0@adventure-works.com','U1/CrPqSzwLTtwgBehfpIl7f1LHSFpZw1qnG1sMzFjo=','QhHP+y8=',NEWID(), GETDATE());;
        
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

1. Run the code and review the output. All three INSERT statements should succeed, but an error is caught by the CATCH block.

1. Switch back to the query containing the SELECT customer statement and run the query to verify that a record for *Ann Othercustomer* has been inserted along with the related address records. The transaction succeeded and was not rolled back, even though an error subsequently occurred.

## Challenge

Now it's time to try using what you've learned.

> **Tip**: Try to determine the appropriate solution for yourself. If you get stuck, a suggested solution is provided at the end of this lab.

### Use a transaction to insert data into multiple tables

When a sales order header is inserted, it must have at least one corresponding sales order detail record. Currently, you use the following code to accomplish this:

```sql
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

```sql
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

```sql
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
