Function Main()
{
    BEGIN
    {
        Clear-Host
        $SQLServerInstance = "EMCTEMPDEV01\SQLEXPRESS"
        $SQLQueryPath = "\\UGMFDEV1\Snapshots\Bundle2_SQL_Server\0_ATTACH_DETACH_SQL\"
        $RemoteDBFilesPath = "\\UGMFDEV1\Snapshots\Bundle2_SQL_Server\B2S1\"
        $LocalDBFilesPath = "C:\EMC_SQL_XDF\"
    }
    
    PROCESS
    {
        Import-Module sqlps –DisableNameChecking #Importing SQLPS Module to use SQL Server
        
        # Deleting the databases
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\DELETE_DBs.sql" -ServerInstance $SQLServerInstance
        
        # Copying mdf/ldf files to local VM
        Set-Location $LocalDBFilesPath
        Copy-Item "${RemoteDBFilesPath}AccountsPayable.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}AccountsPayable_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}AccountsReceivable.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}AccountsReceivable_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}ACNielson.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}ACNielson_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Autowrite.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Autowrite_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}BuyAndHold.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}BuyAndHold_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CisCustomer_Data.ndf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CisCustomer_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CisCustomer_Primary.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CISItem_Data.ndf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CISItem_Index.ndf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CISItem_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CISItem_Primary.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CostAndSell.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}CostAndSell_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Inventory.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Inventory_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Invoice.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Invoice_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}LayeredInventory.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}LayeredInventory_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Marwood.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Marwood_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}OrderEntry.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}OrderEntry_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Promotions_IF.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Promotions_IF_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}PurchaseOrder.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}PurchaseOrder_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Retail.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Retail_log.ldf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Shipment.mdf" -Verbose
        Copy-Item "${RemoteDBFilesPath}Shipment_log.ldf" -Verbose
        
        # Executing SQLs to attache database, create sysnonyms database and create views
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\AttachDatabases.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\AttachCISITEM.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\AttachCISCUSTOMER.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\AttachPromotionsIF.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\CISLegacy.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\EMC_SYNONYMS.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_BIR_BUS_ITEM_RPT_CODE_XREF.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_BUI_BUSINESS_ITEM_LIST.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_FAU_FACILITY_UITEM.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_ITR_ITEM_REPORT_CODE_XREF.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_ITX_ITEM_CROSS_REF_B.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_OEVITC_ITEM_CONVERT.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_RED_REPORT_CODE_DESC.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\VIEW_WAI_WAREHOUSE_ITEM_LIST.sql" -ServerInstance $SQLServerInstance
        Invoke-Sqlcmd -InputFile "$SQLQueryPath\DEPLOY_UCASE_DATA_FIX_03-23-2016.sql" -ServerInstance $SQLServerInstance
                 
    }
    
    END
    {
        Write-Host "Database restore completed..."
    }
}

. Main