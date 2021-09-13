---
lab:
    title: 'Use pivoting and grouping sets'
    module: 'Additional exercises'
---

# Use pivoting and grouping sets

In this lab, you'll use pivoting and grouping sets to query the **adventureworks** database. For your reference, the following diagram shows the tables in the database (you may need to resize the pane to see them clearly).

![An entity relationship diagram of the adventureworks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.

## Pivot data using the PIVOT operator

1. Start Azure Data Studio, and create a new query (you can do this from the **File** menu or on the *welcome* page).

1. In the new **SQLQuery_...** pane, use the **Connect** button to connect the query to the **AdventureWorks** saved connection.

1. Once you've connected to your database, you can use it. First, let's create a view that the contains the information we want to pivot. Write the following code in the query pane:

    ```
    CREATE VIEW SalesLT.vCustGroups AS
    SELECT AddressID, CHOOSE(AddressID % 3 + 1, N'A', N'B', N'C') AS custgroup, CountryRegion
    FROM SalesLT.Address;
    ```

1. Select **&#x23f5;Run** to run your query.

1. The code creates a custom view named **SalesLT.CustGroups** from the **SalesLT.Address** table that groups customers based on their address ID. You can query this view to retrieve results from it. Replace the previous code with the code below:

    ```
    SELECT AddressID, custgroup, CountryRegion
    FROM SalesLT.vCustGroups;
    ```

1. Select **&#x23f5;Run**.

1. The query returns a list of records from the view that shows each customer's address ID, their assigned customer group based on their address ID, and their country. Let's pivot the data using the **PIVOT** operator. Replace the code with the code below:

    ```
    SELECT CountryRegion, p.A, p.B, p.C
    FROM SalesLT.vCustGroups PIVOT (
            COUNT(AddressID) FOR custgroup IN (A, B, C)
    ) AS p;
    ```

1. Select **&#x23f5;Run** to run your query.

1. Review the results. The result set shows the total number of customers in each customer group for each country. Notice that the result set has changed its orientation.  Each customer group (A, B, and C) has a dedicated column, alongside the **CountryRegion** column. With this new orientation, it's easier to understand how many customers are in each group, across all countries.

## Group data using a grouping subclause

Use subclauses like **GROUPING SETS**, **ROLLUP**, and **CUBE** to group data in different ways. Each subclause allows you to group data in a unique way. For instance, **ROLLUP** allows you to dictate a hierarchy and provides a grand total for your groupings. Alternatively, you can use **CUBE** to get all possible combinations for groupings.

For example, let's see how you can use **ROLLUP** to group a set of data.

1. Create a view that captures sales information based on details from the **SalesLT.Customer** and **SalesLT.SalesOrderHeader** tables. To do this, replace the previous code with the code below, then select **&#x23f5;Run**:

    ```
    CREATE VIEW SalesLT.vCustomerSales AS 
    SELECT Customer.CustomerID, Customer.CompanyName, Customer.SalesPerson, SalesOrderHeader.TotalDue 
    FROM SalesLT.Customer 
    INNER JOIN SalesLT.SalesOrderHeader 
        ON Customer.CustomerID = SalesOrderHeader.CustomerID;
    ```

1. Your view (**SalesLT.vCustomerSales**) cross-references information from two different tables, to display the **TotalDue** amount for customer companies who have made orders, along with their assigned sales representative. Have a look at the view by replacing the previous code with the code below:

    ```
    SELECT * FROM SalesLT.vCustomerSales;
    ```

1. Select **&#x23f5;Run**.

1. Let's use **ROLLUP** to group this data. Replace your previous code with the code below:

    ```
    SELECT SalesPerson, CompanyName, SUM(TotalDue) AS TotalSales
    FROM SalesLT.vCustomerSales
        GROUP BY ROLLUP (SalesPerson, CompanyName);
    ```

1. Select **&#x23f5;Run**.

1. Review the results. You were able you to retrieve customer sales data, and the use of **ROLLUP** enabled you to group the data in a way that allowed you to get the subtotal for historical sales for each sales person, and a final grand total for all sales at the bottom of the result set.

## Challenges

Now it's your turn to pivot and group data.

> **Tip**: Try to determine the appropriate code for yourself. If you get stuck, suggested answers are provided at the end of this lab.

### Challenge 1: Pivot product data

The Adventure Works marketing team wants to conduct research into the relationship between colors and products.
To give them a starting point, you've been asked to provide information on how many products are available across the different color types.

1. For each product category, count how many products are available across all the color types.
   - Use the **SalesLT.Product** and **SalesLT.ProductCategory** tables to get a list of products, their colors, and product categories.
   - Pivot your data so that the color types become columns.

### Challenge 2: Group sales data

The sales team at Adventure Works wants to write a report on sales data. To help them, your manager has asked if you can group historical sales data for them using all possible combinations of groupings based on the **CompanyName** and **SalesPerson** columns.

To help, you're going to write a query to:

1. Retrieve customer sales data, and group the data.
   - In your query, fetch all data from the **Sales.vCustomerSales** view.
   - Group the data using **CompanyName** and **SalesPerson**.
   - Use the appropriate subclause that allows you to creates groupings for all possible combinations of your columns.

## Challenge Solutions

This section contains suggested solutions for the challenge queries.

### Challenge 1

1. For each product category, count how many products are available across the different color types. Pivot the data so the color types become columns.

    ```
    SELECT * 
    FROM 
    (
        SELECT P.ProductID, PC.Name, ISNULL(P.Color, 'Uncolored') AS Color 
        FROM Saleslt.ProductCategory AS PC 
        JOIN SalesLT.Product AS P 
            ON PC.ProductCategoryID = P.ProductCategoryID
    ) AS PPC PIVOT(
        COUNT(ProductID) FOR Color IN(
            [Red], [Blue], [Black], [Silver], [Yellow], 
            [Grey], [Multi], [Uncolored]
        )
    ) AS pvt 
        ORDER BY Name;
    ```

### Challenge 2

1. Retrieve customer sales data, and group the data.

    ```
    SELECT CompanyName, SalesPerson, SUM(TotalDue) AS TotalSales
    FROM SalesLT.vCustomerSales
        GROUP BY CUBE (CompanyName, SalesPerson);
    ```
