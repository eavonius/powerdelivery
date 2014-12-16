<#
.Synopsis
Publishes a SQL Server Analysis Services (SSAS) cube.

.Description
The Publish-SSAS cmdlet will deploy a SQL analysis services .asdatabase file to a server. It creates a .XMLA 
file and replaces any connection strings with updated values before copying it to a remote share on the target 
SSAS server. After execution, a log file is available in the same directory.

.Parameter asDatabase
The .asdatabase file to deploy. Is a path local to machine specified by the computer parameter.

.Parameter computername
The computer(s) to deploy to.

.Parameter sqlVersion
Optional. The version of SQL to use. Default is "11.0"

.Parameter deploymentUtilityPath
Optional. The full path to the Microsoft.AnalysisServices.DeploymentUtility.exe command-line tool.

.Parameter cubeName
Optional. The name to deploy the cube as. Can only be omitted if only one cube (model) is included in the asdatabase package.

.Parameter connections
Optional. Hash of values that match the parameters of the Set-SSASConnection cmdlet.

.Parameter driveLetter
Optional. The drive letter on the target computer to deploy to.

.Example
Publish-SSAS -computer "MyServer" -tabularServer "MyServer\INSTANCE" -asDatabase "MyProject\bin\Debug\MyModel.asdatabase"
#>
function Publish-SSAS {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=1)][string] $asDatabase, 
    [Parameter(Mandatory=1)][string] $computerName, 
    [Parameter(Mandatory=0)][string] $sqlVersion = '11.0',
    [Parameter(Mandatory=0)][string] $deploymentUtilityPath,
    [Parameter(Mandatory=0)][string] $cubeName,
    [Parameter(Mandatory=0)] $connections,
    [Parameter(Mandatory=0)][string] $driveLetter = $powerdelivery.deployDriveLetter
  )
    
  Set-Location $powerdelivery.deployDir

  $sqlVersion = $sqlVersion -replace '\.', ''

  $logPrefix = "Publish-SSAS:"

  if ([String]::IsNullOrWhiteSpace($deploymentUtilityPath)) {
    $deploymentUtilityPath = "C:\Program Files (x86)\Microsoft SQL Server\$($sqlVersion)\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe"
  }

  $asModelName = [System.IO.Path]::GetFileNameWithoutExtension($asDatabase)
  $asFilesDir = [System.IO.Path]::GetDirectoryName($asDatabase)
  $xmlaPath = Join-Path -Path $asFilesDir -ChildPath "$($asModelName).xmla"

  $asDatabase = Join-Path -Path (Get-Location) -ChildPath $asDatabase

  $deployCommand = "& ""$deploymentUtilityPath"" ""$asDatabase"" ""/d"" ""/o:$xmlaPath"""

  "$logPrefix $deployCommand"

  Invoke-Expression $deployCommand

  Start-Sleep -Seconds 15

  $xmlaFullPath = Join-Path -Path (Get-Location) -ChildPath $xmlaPath

  [xml]$xmlaDoc = Get-Content $xmlaFullPath

  $ns = new-object Xml.XmlNamespaceManager $xmlaDoc.NameTable
  $ns.AddNamespace('xmla', 'http://schemas.microsoft.com/analysisservices/2003/engine')

  $batchNode = $xmlaDoc.SelectSingleNode("//xmla:Batch", $ns)
  $parallelNode = $batchNode.SelectSingleNode("xmla:Parallel", $ns)
  $batchNode.RemoveChild($parallelNode)

  $computerNames = $computerName -split "," | % { $_.Trim() }

  foreach ($curComputerName in $computerNames) {

    $newModelName = $asModelName

    if (![String]::IsNullOrWhiteSpace($cubeName)) {

      $newModelName = $cubeName

      $objectNode = $xmlaDoc.SelectSingleNode("//xmla:Batch/xmla:Alter/xmla:Object", $ns)
      $objectNode.DatabaseID = $cubeName

      $databaseNode = $xmlaDoc.SelectSingleNode("//xmla:Batch/xmla:Alter/xmla:ObjectDefinition/xmla:Database", $ns)
      $databaseNode.ID = $cubeName
      $databaseNode.Name = $cubeName

      if ($connections -ne $null) {
        $connections.Keys | % {
          $connection = $connections[$_]
          $connectionStringNode = $databaseNode.SelectSingleNode("xmla:DataSources/xmla:DataSource[xmla:Name='$($connection.ConnectionName)']/xmla:ConnectionString", $ns)

            if ($connectionStringNode -eq $null) {
                throw "Unable to find connection named '$($connection.ConnectionName)' connection to update."
            }
            $connectionStringNode.'#text' = $connection.ConnectionString
        }
      }

      $xmlaDoc.Save($xmlaFullPath)
    }

      Deploy-BuildAssets -computerName $curComputerName -path $asFilesDir -destination $asFilesDir -DriveLetter $driveLetter

      $localDeployPath = Get-ComputerLocalDeployPath $curComputerName -DriveLetter $driveLetter
      $remoteDeployPath = Get-ComputerRemoteDeployPath $curComputerName -DriveLetter $driveLetter

      $xmlaLocalDeployPath = [System.IO.Path]::Combine($localDeployPath, $xmlaPath)
      $outLocalDeployPath = $xmlaLocalDeployPath -replace ".xmla", "ExecutionLog.xml"

      $invokeArgs = @{
          "ComputerName" = $curComputerName;
          "ArgumentList" = @($curComputerName, $xmlaLocalDeployPath, $outLocalDeployPath);
          "ScriptBlock" = {
            param($curComputerName, $xmlaLocalDeployPath, $outLocalDeployPath)
            Invoke-ASCMD -server "$curComputerName" -inputFile "$xmlaLocalDeployPath" | Out-File "$outLocalDeployPath"
          };
          ErrorAction = "Stop"
      }

      if ($curComputerName -eq 'localhost') {
        $invokeArgs.Remove("ComputerName")
      }

      Invoke-Command @invokeArgs

      $outRemoteDeployPath = Join-Path $remoteDeployPath ($xmlaPath -replace ".xmla", "ExecutionLog.xml")

        [xml]$outDoc = Get-Content $outRemoteDeployPath

        $nsOut = new-object Xml.XmlNamespaceManager $outDoc.NameTable
        $nsOut.AddNamespace('xa', 'urn:schemas-microsoft-com:xml-analysis')
        $nsOut.AddNamespace('xae', 'urn:schemas-microsoft-com:xml-analysis:empty')
        $nsOut.AddNamespace('xex', 'urn:schemas-microsoft-com:xml-analysis:exception')

        $warningNodes = $outDoc.SelectNodes("//xa:return/xae:root/xex:Messages/xex:Warning", $nsOut)

        $deploySuccess = $true

        if ($warningNodes -ne $null) {
            foreach ($warningNode in $warningNodes) {
                
                $warningDesc = $warningNode.Description
                
                "SSAS Deployment Error: $warningDesc"

                $deploySuccess = $false
            }
        }

        if ($deploySuccess) {
            Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "SSAS: $($asModelName).asdatabase -> $newModelName ($curComputerName)"
        }
        else {
            throw "One or more errors occurred deploying an SSAS cube. See the build log for details."
        }
    }
}