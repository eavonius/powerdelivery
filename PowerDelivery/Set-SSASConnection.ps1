<#
.Synopsis
Sets a connection string on a deployed Microsoft SQL Server Analysis Services model.

.Description
Sets a connection string on a deployed Microsoft SQL Server Analysis Services model.

.Parameter computer
The computer on which the connection will be changed.

.Parameter tabularServer
The instance of the SSAS server to change the connection on.

.Parameter databaseName
The name of the SSAS database/model to change the connection on.

.Parameter datasourceID
The GUID of the connection to change.

.Parameter connectionName
The name of the connection to change.

.Parameter connectionString
The value to change the connection to.

.Example
Set-SSASConnection -computer "localhost" -tabularServer "localhost\TABULAR" -databaseName "MyModel" -datasourceID "{4CC0937D-61D3-421E-B607-B3E36D1D09B5}" -connectionString "Initial Catalog=MyDB;Server=localhost;Trusted Connection=yes"
#>
function Set-SSASConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $computer, 
        [Parameter(Mandatory=1)][string] $tabularServer, 
        [Parameter(Mandatory=1)][string] $databaseName, 
        [Parameter(Mandatory=1)][string] $datasourceID, 
        [Parameter(Mandatory=1)][string] $connectionName, 
        [Parameter(Mandatory=1)][string] $connectionString
    )

    $query = @"
    <Alter ObjectExpansion=""ObjectProperties"" xmlns=""http://schemas.microsoft.com/analysisservices/2003/engine"">
	    <Object>
		    <DatabaseID>$databaseName</DatabaseID>
		    <DataSourceID>$datasourceID</DataSourceID>
	    </Object>
	    <ObjectDefinition>
		    <DataSource xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" 
					    xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" 
					    xmlns:ddl2=""http://schemas.microsoft.com/analysisservices/2003/engine/2"" 
					    xmlns:ddl2_2=""http://schemas.microsoft.com/analysisservices/2003/engine/2/2"" 
					    xmlns:ddl100_100=""http://schemas.microsoft.com/analysisservices/2008/engine/100/100"" 
					    xmlns:ddl200=""http://schemas.microsoft.com/analysisservices/2010/engine/200"" 
					    xmlns:ddl200_200=""http://schemas.microsoft.com/analysisservices/2010/engine/200/200"" 
					    xmlns:ddl300=""http://schemas.microsoft.com/analysisservices/2011/engine/300"" 
					    xmlns:ddl300_300=""http://schemas.microsoft.com/analysisservices/2011/engine/300/300"" 
					    xsi:type=""RelationalDataSource"">
			    <Name>$connectionName</Name>
			    <ConnectionString>$connectionString</ConnectionString>
		    </DataSource>
	    </ObjectDefinition>
    </Alter>
"@

    $command = "Invoke-ASCMD -server $tabularServer -query ""$query"""
    Invoke-EnvironmentCommand -server $computer -command $command
}