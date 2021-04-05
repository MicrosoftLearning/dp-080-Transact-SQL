---
lab:
    title: 'Lab Environment Setup'
    module: 'Setup'
---

# Lab Environment Setup

The labs in this repo are designed to be performed in a hosted environment, provided on Microsoft Learn or in official course deliveries by Microsoft and partners.

> **Note**: The following information is provided to help you understand what's installed in the hosted environment, and to provide a guide for what you need to install if you want to try the labs on your own computer. However, please note that these guidelines are provided as-is with no warranty. Microsoft cannot provide support for your own lab environment.

## Base Operating System

The hosted lab environment provided for this course is based on Microsoft Windows 10 with the latest updates applied as of March 12th 2021.

The required software for the labs can also be installed on Linux and Apple Mac computers, but this configuration has not been tested.

## Microsoft SQL Server Express 2019

1. Download Microsoft SQL Server Express 2019 from [the Microsoft download center](https://www.microsoft.com/Download/details.aspx?id=101064).
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

