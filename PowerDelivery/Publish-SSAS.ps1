<#
.Synopsis
Publishes a SQL Server Analysis Services (SSAS) cube.

.Description
The Publish-SSAS cmdlet will deploy a SQL analysis services .asdatabase file to a server.

Before you call the cmdlet, copy the .asdatabase from the drop location of your build to a UNC share on the SSAS server.

.Parameter asDatabase
The .asdatabase file to deploy. Is a path local to machine specified by the computer parameter.

.Parameter computer
The computer(s) to deploy to.

.Parameter sqlVersion
Optional. The version of SQL to use. Default is "11.0"

.Parameter deploymentUtilityPath
Optional. The full path to the Microsoft.AnalysisServices.DeploymentUtility.exe command-line tool.

.Parameter cubeName
Optional. The name to deploy the cube as. Can only be omitted if only one cube (model) is included in the asdatabase package.

.Parameter connections
Optional. Hash of values that match the parameters of the Set-SSASConnection cmdlet.

.Example
Publish-SSAS -computer "MyServer" -tabularServer "MyServer\INSTANCE" -asDatabase "MyProject\bin\Debug\MyModel.asdatabase"
#>
function Publish-SSAS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $asDatabase, 
        [Parameter(Mandatory=1)][string] $computer, 
        [Parameter(Mandatory=0)][string] $sqlVersion = '11.0',
		[Parameter(Mandatory=0)][string] $deploymentUtilityPath = "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe",
		[Parameter(Mandatory=0)][string] $cubeName,
        [Parameter(Mandatory=0)] $connections
    )
	
	Set-Location $powerdelivery.deployDir

    $logPrefix = "Publish-SSAS:"

    $asModelName = [System.IO.Path]::GetFileNameWithoutExtension($asDatabase)
    $asFilesDir = [System.IO.Path]::GetDirectoryName($asDatabase)
    $xmlaPath = Join-Path -Path $asFilesDir -ChildPath "$($asModelName).xmla"

    $asDatabase = Join-Path -Path (Get-Location) -ChildPath $asDatabase

    $deployCommand = "& ""$deploymentUtilityPath"" ""$asDatabase"" ""/d"" ""/o:$xmlaPath"""

    "$logPrefix $deployCommand"

    Invoke-Expression $deployCommand

    Start-Sleep -Seconds 15

    $xmlaPath = Join-Path -Path (Get-Location) -ChildPath $xmlaPath

    $computerNames = $computer -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {
    	
    	$newModelName = $asModelName

    	if (![String]::IsNullOrWhiteSpace($cubeName)) {

    		$newModelName = $cubeName
		    [xml]$xmlaDoc = Get-Content $xmlaPath

            $ns = new-object Xml.XmlNamespaceManager $xmlaDoc.NameTable
            $ns.AddNamespace('xmla', 'http://schemas.microsoft.com/analysisservices/2003/engine')

            $objectNode = $xmlaDoc.SelectSingleNode("//xmla:Batch/xmla:Alter/xmla:Object", $ns)
            $objectNode.DatabaseID = $cubeName

		    $databaseNode = $xmlaDoc.SelectSingleNode("//xmla:Batch/xmla:Alter/xmla:ObjectDefinition/xmla:Database", $ns)
			$databaseNode.ID = $cubeName
			$databaseNode.Name = $cubeName
		    
            $objectToProcessNode = $xmlaDoc.SelectSingleNode("//xmla:Batch/xmla:Parallel/xmla:Process/xmla:Object", $ns)
            $objectToProcessNode.DatabaseID = $cubeName

		    $xmlaDoc.Save($xmlaPath)
        }

        Invoke-ASCMD -server "$curComputerName" -inputFile "$xmlaPath"

    	Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "SSAS: $($asModelName).asdatabase -> $newModelName ($curComputerName)"

        if ($connections -ne $null) {
        
            $connections.Keys | % {
    			$connection = $connections[$_]
    			Set-SSASConnection -computer $curComputerName `
    						       -databaseName $cubeName `
    						       -connectionName $connection.ConnectionName `
    						       -datasourceID $connection.DataSourceID `
    						       -connectionString $connection.ConnectionString
    		}
        }
    }
}