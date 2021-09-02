---
lab:
    title: 'Implement transactions with Transact SQL'
    module: 'Module 4: Implement transactions with Transact SQL'
---

In this lab, you'll use T-SQL statements to implement transitions in the **adventureworks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Control transactions with BEGIN TRANSACTION and COMMIT TRANSACTION

In this exercise you will use a transaction to ensure that when a row is inserted into the OrderHeader table, a row is also added to the OrderDetails table. If one insert fails, then both fail.

1. Start Azure Data Studio.
1. From the Servers pane, double click the **AdventureWorks** connection. A green dot will appear when the connection is successful. 
1. Right click on the **AdventureWorks** database and select **New Query**. A new query window is displayed with a connection to the AdventureWorks database.
1. Copy the following T-SQL code into the query window:

    ```
    CREATE TABLE dbo.OrderHeader
    (OrderID int NOT NULL PRIMARY KEY,
    	OrderDate date NOT NULL,
    	CustomerName nvarchar(50) NOT NULL);
    CREATE TABLE dbo.OrderDetail
    (OrderID int NOT NULL,
    	OrderDetailID int NOT NULL,
    	ProductID int NOT NULL,
    	Quantity smallint NOT NULL,
    	UnitPrice decimal(6, 2) NOT NULL,
    	CONSTRAINT PK_dbo_OrderDetail PRIMARY KEY(OrderID, OrderDetailID),
    	CONSTRAINT FK_dbo_OrderDetail_OrderHeader FOREIGN KEY (OrderID) REFERENCES dbo.OrderHeader (OrderID));
    GO
    -- Insert using transactions
    BEGIN TRANSACTION;
        INSERT INTO dbo.OrderHeader (OrderID, OrderDate, CustomerName)
    		VALUES (1001, '2021-08-25', N'Henry Ross');
    	INSERT INTO dbo.OrderDetail (OrderID, OrderDetailID, ProductID, Quantity, UnitPrice)
    		VALUES (1001, 1, 14, 2, 2.50);
    	COMMIT TRANSACTION;
    ```

1. Highlight the T-SQL code and click **&#x23f5;Run**. You have now inserted two rows into two tables within a single transaction.

## Challenge

### Challenge 1

Add structured error handling to the transaction. Amend the code by adding TRY/CATCH code in the correct place to handle any errors that might occur. Use the PRINT command to show whether the Transaction committed or whether the Transaction rolled back.

### Challenge 2

Highlight the T-SQL code and click **&#x23f5;Run**. When you run the code do you expect an error to occur? (Hint: OrderID and OrderHeaderID have primary key contstraints.) What message is output?

## Challenge solutions

### Challenge 1

View the following code for where to place the TRY / CATCH statements. Note how the PRINT statements allow you to view whether your statements are in the right place.

```
BEGIN TRY
BEGIN TRANSACTION;
	INSERT INTO dbo.OrderHeader (OrderID, OrderDate, CustomerName)
		VALUES (1001, '2021-08-25', N'Henry Ross');
	INSERT INTO dbo.OrderDetail (OrderID, OrderDetailID, ProductID, Quantity, UnitPrice)
		VALUES (1001, 1, 14, 2, 2.50);
	COMMIT TRANSACTION;
	PRINT 'Transaction committed.';
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Transaction rolled back.';
END CATCH
```

### Challenge 2

When you run the code for a second time an error will occur due to the primary keys. The message "Transaction rolled back" will appear.
