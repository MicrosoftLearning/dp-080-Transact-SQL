---
lab:
    title: 'Lab Environment Setup - Microsoft Fabric'
    module: 'Setup'
---

# Lab Environment Setup

You can complete the Transact-SQL exercises in a sample database in Microsoft Fabric. Use the instructions in this page to prepare a suitable Fabric Database environment.

> **Note**: You need access to [Microsoft Fabric](https://learn.microsoft.com/fabric/get-started/fabric-trial) with sufficient permissions to create a Fabric Database to complete this exercise.

## Create a workspace

Before working with data in Fabric, create a workspace.

1. Open the [Microsoft Fabric home page](https://app.fabric.microsoft.com/home?experience=fabric) at `https://app.fabric.microsoft.com/home?experience=fabric`, signing in with your credentials if prompted.
1. Create a new **Workspace** with a name of your choice, selecting a licensing mode in the **Advanced** section that includes Fabric capacity (*Trial*, *Premium*, or *Fabric*).
1. When your new workspace opens, it should be empty.

## Provision Fabric Database

Now, you need to provision an instance of Fabric Database with a sample database that you can query.

1. In your new empty workspace, create a new **SQL Database** item named `Adventureworks`.
1. When the new **Adventureworks** database has been created, select the **Sample data** option to import the sample database schema and data.

    Wait for the sample data to be imported. This may take a few minutes.

1. After the data has been imported, refresh the **Adventureworks** database node in the **Explorer** pane and then expand it to see the tables under the **SalesLT** schema.

> **Note**: If you're familiar with the standard **AdventureWorks** sample database for Microsoft SQL Server, you may notice that we are using a simplified, lightweight (*LT*) version with fewer tables.

## Open the query editor

The query editor is a browser-based interface that you can use to run Transact-SQL statements in your database.

1. In your **Adventureworks** Fabric database, create a new query.
1. In the **SQL query 1** pane, enter the following Transact-SQL code:

    ```sql
    SELECT * FROM SalesLT.Product;
    ```

1. Use the **&#9655; Run** button to run the query, and and after a few seconds, review the results, which includes all columns for all products.
1. Close the Query editor page.

Now that you've created the database and learned how to use the query editor to run Transact-SQL code, you can return to the query editor in your Fabric workspace at any time to complete the lab exercises.

> **Tip**: When you've finished with the database, delete the workspace you created to avoid unnecessary charges.
