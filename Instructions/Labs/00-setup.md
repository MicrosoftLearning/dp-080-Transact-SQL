---
lab:
    title: 'Lab Environment Setup - Local SQL Server'
    module: 'Setup'
---

# Lab Environment Setup

> **Note**: The following information provides a guide for what you need to install if you want to try the labs using SQL Server on your own computer. However, please note that these guidelines are provided as-is with no warranty. Due to the variability of operating system configuration and additionally installed software, Microsoft cannot provide support for your own lab environment.

## Base Operating System

The setup for these labs has been tested on Microsoft Windows 11 with the latest updates applied as of April 8th 2024.

The required software for the labs can also be installed on Linux and Apple Mac computers, but this configuration has not been tested.

## Microsoft SQL Server Express 2022

1. Download Microsoft SQL Server Express 2022 from [the Microsoft download center](https://www.microsoft.com/en-us/download/details.aspx?id=104781).
2. Run the downloaded installer and select the **Basic** installation option.

## Microsoft Azure Data Studio

1. Download and install Azure Data Studio from the [Azure Data Studio documentation](https://docs.microsoft.com/sql/azure-data-studio/download-azure-data-studio), following the appropriate instructions for your operating system.

## AdventureWorks LT Database

The labs use a lightweight version of the AdventureWorks sample database. Note that this is <u>not</u> the same as the official sample database, so use the following instructions to create it.

1. Download the **[adventureworkslt.sql](../../Scripts/adventureworkslt.sql)** script, and save it on your local computer.
2. Start Azure Data Studio, and open the **adventureworkslt.sql** script file you downloaded.
3. In the script pane, connect to your SQL Server Express server server using the following information:
    - **Connection type**: SQL Server
    - **Server**: localhost\SQLExpress
    - **Authentication Type**: Windows Authentication
    - **Database**: master
    - **Server group**: &lt;Default&gt;
    - **Name**: *leave blank*
4. Ensure the **master** database is selected, and then run the script to create the **adventureworks** database. This will take a few minutes.
5. After the database has been created, on the **Connections** pane, in the **Servers** section, create a new connection with the following settings:
    - **Connection type**: SQL Server
    - **Server**: localhost\SQLExpress
    - **Authentication Type**: Windows Authentication
    - **Database**: adventureworks
    - **Server group**: &lt;Default&gt;
    - **Name**: AdventureWorks

## Explore the *AdventureWorks* database

We'll use the **AdventureWorks** database in this lab, so let's start by exploring it in Azure Data Studio.

1. Start Azure Data Studio if it's not already started, and in the **Connections** tab, select the **AdventureWorks** connection by clicking on the arrow just to the left of the name. This will connect to the SQL Server instance and show the objects in the **AdventureWorks** database.
2. Expand the **Tables** folder to see the tables that are defined in the database. Note that there are a few tables in the **dbo** schema, but most of the tables are defined in a schema named **SalesLT**.
3. Expand the **SalesLT.Product** table and then expand its **Columns** folder to see the columns in this table. Each column has a name, a data type, an indication of whether it can contain *null* values, and in some cases an indication that the columns is used as a primary key (PK) or foreign key (FK).
4. Right-click the **SalesLT.Product** table and use the **SELECT TOP (1000)** option to create and run a new query script that retrieves the first 1000 rows from the table.
5. Review the query results, which consist of 1000 rows - each row representing a product that is sold by the fictitious *Adventure Works Cycles* company.
6. Close the **SQLQuery_1** pane that contains the query and its results.
7. Explore the other tables in the database, which contain information about product details, customers, and sales orders. The tables are related through primary and foreign keys, as shown here (you may need to resize the pane to see them clearly):

    ![An entity relationship diagram of the AdventureWorks database](./images/adventureworks-erd.png)

> **Note**: If you're familiar with the standard **AdventureWorks** sample database, you may notice that in this lab we are using a simplified version that makes it easier to focus on learning Transact-SQL syntax.