---
lab:
    title: 'Lab Environment Setup - Azure SQL Database'
    module: 'Setup'
---

# Lab Environment Setup

You can complete the Transact-SQL exercises in a sample database in Microsoft Azure SQL Database. Use the instructions in this page to prepare a suitable Azure SQL Database environment.

> **Note**: You will need a [Microsoft Azure subscription](https://azure.microsoft.com/free) in which you have sufficient permissions to create and configure the required resources.

## Provision Azure SQL Database

First, you need to provision an instance of Azure SQL Database with a sample database that you can query.

1. In a web browser, navigate to the [Azure portal](https://portal.azure.com) at `https://portal.azure.com` and sign in using the credentials associated with your Azure subscription.
1. On the **Home** page, create a **SQL Database** resource with the following settings (be sure to select the **sample** database option on the **Additional settings** tab!):
    - **Basics**:
        - **Subscription**: *Select your Azure subscription*
        - **Resource group**: *Create or select a resource group where you want to create the SQL Database resource*
        - **Database name**: `Adventureworks`
        - **Server**: Create a new server with the following settings:
            - **Server name**: *A unique name*
            - **Location**: *Select any available region*
            - **Authentication method**: Use Microsoft Entra-only authentication
            - **Select Microsoft Entra admin**: *Select your own user account*
        - **Want to use SQL elastic pool?**: No
        - **Workload environment**: Development
        - **Compute + storage**: General purpose - serverless *(with the default configuration)*
        - **Backup storage redundancy**: Locally-redundant backup storage
    - **Networking**:
        - **Connectivity method**: Public endpoint
        - **Firewall rules**:
            - **Allow Azure services and resources to access this server**: Yes
            - **Add current client IP address**: Yes
        - **Connection policy**: Default
        - **Minimum TLS version**: TLS 1.2
    - **Security**:
        - **Enable Microsoft Defender for SQL**: Not now
        - **Ledger**: Not configured
        - **Server identity**: Not configured
        - **Transparent data encryption key management**:
            - **Server level key**: Service-managed key selected
            - **Database level key**: Not configured
        - **Enable secure enclaves**: Off
    - **Additional settings**:
        - **Use existing data**: Sample *(Confirm that **AdventureWorksLT** database will be created)*
    - **Tags**:
        - None
1. Wait for deployment to complete. Then go to the **Adventureworks** SQL Database resource you deployed.

## Open the query editor

The query editor is a browser-based interface that you can use to run Transact-SQL statements in your database.

1. In the Azure portal, on the page for your **Adventureworks** SQL Database, in the pane on the left, select **Query editor**.
1. On the welcome page, sign into your database using Entra authentication (if necessary, allow access from your client IP address first).
1. In the query editor, expand the **Tables** folder to view the tables in the database.

    > **Note**: If you're familiar with the standard **AdventureWorks** sample database for Microsoft SQL Server, you may notice that we are using a simplified, lightweight (*LT*) version with fewer tables.

1. In the **Query 1** pane, enter the following Transact-SQL code:

    ```sql
    SELECT * FROM SalesLT.Product;
    ```

1. Use the **&#9655; Run** button to run the query, and and after a few seconds, review the results, which includes all columns for all products.
1. Close the Query editor page, discarding your changes if prompted.

Now that you've created the database and learned how to use the query editor to run Transact-SQL code, you can return to the query editor in the Azure Portal at any time to complete the lab exercises.

> **Tip**: When you've finished with the database, delete the resources you created in your Azure subscription to avoid unnecessary charges.
