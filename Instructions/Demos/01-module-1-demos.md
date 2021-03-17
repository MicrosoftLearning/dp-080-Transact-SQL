---
demo:
    title: 'Module 1 Demonstrations'
    module: 'Module 1: Getting Started with Transact-SQL'
---

# Module 1 Demonstrations

This file contains guidance for demonstrations you can use to help students understand key concepts taught in the module.

## Explore the lab environment

Throughout the course, students use a hosted environment that includes **Azure Data Studio** and a local instance of SQL Server Express containing a simplified version of the **adventureworks** sample database.

1. Start the hosted lab environment, and log in if necessary.
2. Start Azure Data Studio, and in the **Connections** tab, select the **AdventureWorks** connection. This will connect to the SQL Server instance and show the objects in the **adventureworks** database.
3. Expand the **Tables** folder to see the tables that are defined in the database. Note that there are a few tables in the **dbo** schema, but most of the tables are defined in a schema named **SalesLT**.
4. Expand the **SalesLT.Product** table and then expand its **Columns** folder to see the columns in this table. Each column has a name, a data type, an indication of whether it can contain *null* values, and in some cases an indication that the columns is used as a primary key (PK) or foreign key (FK).
5. Right-click the **SalesLT.Product** table and use the **Select Top 1000** option to create and run a new query script that retrieves the first 1000 rows from the table.
6. Review the query results, which consist of 1000 rows - each row representing a product that is sold by the fictitious *Adventure Works Cycles* company.
7. Close the **SQLQuery_1** pane that contains the query and its results.
8. Explore the other tables in the database, which contain information about product details, customers, and sales orders.
9. In Azure Data Studio, create a new query (you can do this from the **File** menu or on the *welcome* page).
10. In the new **SQLQuery_...** pane, use the **Connect** button to connect the query to the **AdventureWorks** saved connection (do this even if the query was already connected by clicking **Disconnect** first - it's useful for students to see how to connect to the saved connection!).
11. In the query editor, enter the following code:

    ```
    SELECT * FROM SalesLT.Product;
    ```

12. Use the **&#x23f5;Run** button to run the query, and and after a few seconds, review the results, which includes all fields for all products.

## Run basic SELECT queries

Use these example queries at appropriate points during the module presentation.

1. In Azure Data Studio, open the file at https://raw.githubusercontent.com/MicrosoftLearning/dp-080-Transact-SQL/master/Scripts/module01-demos.sql
2. Connect the script to the saved **AdventureWorks** connection.
3. Select and run each query when relevant (when text is selected in the script editor, the **&#x23f5;Run** button runs only the selected text).