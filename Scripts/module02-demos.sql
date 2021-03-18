-- This script contains demo code for Module 2 of the Transact-SQL course


-- ALL and DISTINCT

-- Implicit all
SELECT City
FROM SalesLT.Address;

-- Explicit all
SELECT ALL City
FROM SalesLT.Address;

-- Distinct
SELECT DISTINCT City
FROM SalesLT.Address;

-- Distinct combination
SELECT DISTINCT City, PostalCode
FROM SalesLT.Address;



-- ORDER BY

-- Sort by column
SELECT AddressLine1, City, PostalCode, CountryRegion
FROM SalesLT.Address
ORDER BY CountryRegion;

-- Sort and subsort
SELECT AddressLine1, City, PostalCode, CountryRegion
FROM SalesLT.Address
ORDER BY CountryRegion, City;

-- Descending
SELECT AddressLine1, City, PostalCode, CountryRegion
FROM SalesLT.Address
ORDER BY CountryRegion DESC, City ASC;



-- TOP

-- Top records
SELECT TOP 10 AddressLine1, ModifiedDate
FROM SalesLT.Address
ORDER BY ModifiedDate DESC;

-- Top with ties
SELECT TOP 10 WITH TIES AddressLine1, ModifiedDate
FROM SalesLT.Address
ORDER BY ModifiedDate DESC;

-- Top percent
SELECT TOP 10 PERCENT AddressLine1, ModifiedDate
FROM SalesLT.Address
ORDER BY ModifiedDate DESC;



-- OFFSET and FETCH

-- First 10 rows
SELECT AddressLine1, ModifiedDate
FROM SalesLT.Address
ORDER BY ModifiedDate DESC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Next page
SELECT AddressLine1, ModifiedDate
FROM SalesLT.Address
ORDER BY ModifiedDate DESC OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;



-- WHERE CLAUSE

-- Simple filter
SELECT AddressLine1, City, PostalCode
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
ORDER BY City, PostalCode;

-- Multiple criteria (and)
SELECT AddressLine1, City, PostalCode
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
    AND City = 'London'
ORDER BY PostalCode;

-- Multiple criteria (or)
SELECT AddressLine1, City, PostalCode, CountryRegion
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
    OR CountryRegion = 'Canada'
ORDER BY CountryRegion, PostalCode;

-- Nested conditions
SELECT AddressLine1, City, PostalCode
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
    AND (City = 'London' OR City = 'Oxford')
ORDER BY City, PostalCode;

-- Not equal to
SELECT AddressLine1, City, PostalCode
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
    AND City <> 'London'
ORDER BY City, PostalCode;

-- Greater than
SELECT AddressLine1, City, PostalCode
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
    AND City = 'London'
    AND PostalCode > 'S'
ORDER BY PostalCode;

-- Like with wildcard
SELECT AddressLine1, City, PostalCode
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
    AND City = 'London'
    AND PostalCode LIKE 'SW%'
ORDER BY PostalCode;

-- Like with regex pattern
SELECT AddressLine1, City, PostalCode
FROM SalesLT.Address
WHERE CountryRegion = 'United Kingdom'
    AND City = 'London'
    AND PostalCode LIKE 'SW[0-9] [0-9]__'
ORDER BY PostalCode;

-- check for null
SELECT AddressLine1, AddressLine2, City, PostalCode
FROM SalesLT.Address
WHERE AddressLine2 IS NOT NULL
ORDER BY City, PostalCode;

-- within a range
SELECT AddressLine1, ModifiedDate
FROM SalesLT.Address
WHERE ModifiedDate BETWEEN '01/01/2005' AND '12/31/2005'
ORDER BY ModifiedDate;

-- In a list
SELECT AddressLine1, City, CountryRegion
FROM SalesLT.Address
WHERE CountryRegion IN ('Canada', 'United States')
ORDER BY City;