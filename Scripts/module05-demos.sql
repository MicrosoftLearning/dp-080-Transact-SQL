-- This script contains demo code for Module 6 of the Transact-SQL course



-- CREATE A TABLE FOR THE DEMOS

CREATE TABLE SalesLT.Promotion
    (
        PromotionID int IDENTITY PRIMARY KEY NOT NULL,
        PromotionName varchar(20),
        StartDate datetime NOT NULL DEFAULT GETDATE(),
        ProductModelID int NOT NULL REFERENCES SalesLT.ProductModel(ProductModelID),
        Discount decimal(4,2) NOT NULL,
        Notes nvarchar(max) NULL
    );

-- Show it's empty
SELECT * FROM SalesLT.Promotion;



-- INSERT

-- Basic insert with all columns by position
INSERT INTO SalesLT.Promotion
VALUES
('Clearance Sale', '01/01/2021', 23, 0.1, '10% discount')

SELECT * FROM SalesLT.Promotion;


-- Use defaults and NULLs
INSERT INTO SalesLT.Promotion
VALUES
('Pull your socks up', DEFAULT, 24, 0.25, NULL)

SELECT * FROM SalesLT.Promotion;


-- Explicit columns
INSERT INTO SalesLT.Promotion (PromotionName, ProductModelID, Discount)
VALUES
('Caps Locked', 2, 0.2)

SELECT * FROM SalesLT.Promotion;

-- Multiple rows
INSERT INTO SalesLT.Promotion
VALUES
('The gloves are off!', DEFAULT, 3, 0.25, NULL),
('The gloves are off!', DEFAULT, 4, 0.25, NULL)

SELECT * FROM SalesLT.Promotion;


-- Insert from query
INSERT INTO SalesLT.Promotion (PromotionName, ProductModelID, Discount, Notes)
SELECT DISTINCT 'Get Framed', m.ProductModelID, 0.1, '10% off ' + m.Name
FROM SalesLT.Product AS p
JOIN SalesLT.ProductModel AS m
    ON p.ProductModelID = m.ProductModelID
WHERE m.Name LIKE '%frame%';

SELECT * FROM SalesLT.Promotion;


-- SELECT...INTO
SELECT SalesOrderID, CustomerID, OrderDate, PurchaseOrderNumber, TotalDue
INTO SalesLT.Invoice
FROM SalesLT.SalesOrderHeader;

SELECT * FROM SalesLT.Invoice;


-- Retrieve inserted identity value
INSERT INTO SalesLT.Promotion (PromotionName, ProductModelID, Discount)
VALUES
('A short sale',13, 0.3);

SELECT SCOPE_IDENTITY() AS LatestIdentityInDB;

SELECT IDENT_CURRENT('SalesLT.Promotion') AS LatestPromotionID;

SELECT * FROM SalesLT.Promotion;

-- Override Identity
SET IDENTITY_INSERT SalesLT.Promotion ON;

INSERT INTO SalesLT.Promotion (PromotionID, PromotionName, ProductModelID, Discount)
VALUES
(10, 'Another short sale',37, 0.3);

SET IDENTITY_INSERT SalesLT.Promotion OFF;

SELECT * FROM SalesLT.Promotion;


-- Sequences

-- Create sequence
CREATE SEQUENCE SalesLT.InvoiceNumbers AS INT
START WITH 72000 INCREMENT BY 1;

-- Get next value
SELECT NEXT VALUE FOR SalesLT.InvoiceNumbers;

-- Get next value again (automatically increments on each retrieval)
SELECT NEXT VALUE FOR SalesLT.InvoiceNumbers;

-- Insert using next sequence value
INSERT INTO SalesLT.Invoice
VALUES
(NEXT VALUE FOR SalesLT.InvoiceNumbers, 2, GETDATE(), 'PO12345', 107.99);

SELECT * FROM SalesLT.Invoice;




-- UPDATE

-- Update a single field
UPDATE SalesLT.Promotion
SET Notes = '25% off socks'
WHERE PromotionID = 2;

SELECT * FROM SalesLT.Promotion;


-- Update multiple fields
UPDATE SalesLT.Promotion
SET Discount = 0.2, Notes = REPLACE(Notes, '10%', '20%')
WHERE PromotionName = 'Get Framed'

SELECT * FROM SalesLT.Promotion;

-- Update from query
UPDATE SalesLT.Promotion
SET Notes = FORMAT(Discount, 'P') + ' off ' + m.Name
FROM SalesLT.ProductModel AS m
WHERE Notes IS NULL
    AND SalesLT.Promotion.ProductModelID = m.ProductModelID;

SELECT * FROM SalesLT.Promotion;


-- Delete data
DELETE FROM SalesLT.Promotion
WHERE StartDate < DATEADD(dd, -7, GETDATE());

SELECT * FROM SalesLT.Promotion;

-- Truncate to remove all rows
TRUNCATE TABLE SalesLT.Promotion;

SELECT * FROM SalesLT.Promotion;