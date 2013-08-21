<#
.Synopsis
Deploys a SQL Server analysis services model.

.Description
The Publish-SSAS cmdlet will deploy a SQL analysis services .asdatabase file to a server.

Before you call the cmdlet, copy the .asdatabase from the drop location of your build to a UNC share on the SSAS server.

.Parameter computer
The computer running SSAS.

.Parameter tabularServer
The server name of the SSAS instance.

.Parameter asDatabase
The .asdatabase file to deploy. Is a path local to the SSAS server.

.Parameter cubeName
Optional. The name to deploy the cube as. Can only be included if only one cube (model) is included in the asdatabase package.

.Parameter version
Optional. The version of SQL to use. Default is "11.0"

.Parameter deploymentUtilityPath
Optional. The full path to the Microsoft.AnalysisServices.DeploymentUtility.exe command-line tool.

.Example
Publish-SSAS -computer "MyServer" -tabularServer "MyServer\INSTANCE" -asDatabase "MyProject\bin\Debug\MyModel.asdatabase"
#>
function Publish-SSAS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $asDatabase, 
        [Parameter(Mandatory=1)][string] $computer, 
        [Parameter(Mandatory=1)][string] $tabularServer, 
        [Parameter(Mandatory=0)][string] $sqlVersion = '11.0',
		[Parameter(Mandatory=0)][string] $deploymentUtilityPath = "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe",
		[Parameter(Mandatory=0)][string] $cubeName
    )

    $logPrefix = "Publish-SSAS:"

    $asModelName = [System.IO.Path]::GetFileNameWithoutExtension($asDatabase)
    $asFilesDir = [System.IO.Path]::GetDirectoryName($asDatabase)
    $xmlaPath = Join-Path -Path $asFilesDir -ChildPath "$($asModelName).xmla"

    $remoteCommand = "& `"$deploymentUtilityPath`" `"$asDatabase`" `"/d`" `"/o:$xmlaPath`""

    "$logPrefix $remoteCommand"

	Invoke-Command -ComputerName $computer -ErrorAction Stop {
		iex $using:remoteCommand | Out-Host
	}
	
	#if ($lastexitcode -ne $null -and $lastexitcode -ne 0) {
#		throw "Failed to deploy SSAS cube $asModelName exit code from Microsoft.AnalysisServices.Deployment.exe was $lastexitcode"
	#}

	$newModelName = $asModelName

	if (![String]::IsNullOrWhiteSpace($cubeName)) {
		$newModelName = $cubeName
        Invoke-Command -Computer $computer -ArgumentList @($xmlaPath, $cubeName) -ScriptBlock {
            param(
                [Parameter(Mandatory=1,Position=0)][string] $xmlaPath,
                [Parameter(Mandatory=1,Position=1)][string] $cubeName
            )
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
    }

    $remoteCommand = "Invoke-ASCMD -server ""$tabularServer"" -inputFile ""$xmlaPath"""

    "$logPrefix $remoteCommand"

	Invoke-Command -ComputerName $computer -ErrorAction Stop {
		iex $using:remoteCommand | Out-Host
	}
	
	#if ($lastexitcode -ne $null -and $lastexitcode -ne 0) {
	#	throw "Failed to deploy SSAS cube $asModelName exit code from Invoke-ASCMD was $lastexitcode"
	#}
	
	Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "SSAS: $($asModelName).asdatabase -> $newModelName ($tabularServer)"
}