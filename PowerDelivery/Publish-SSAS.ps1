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

.Parameter version
Optional. The version of SQL to use. Default is "11.0"

.Example
Publish-SSAS -computer "MyServer" -tabularServer "MyServer\INSTANCE" -asDatabase "MyProject\bin\Debug\MyModel.asdatabase"
#>
function Publish-SSAS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $asDatabase, 
        [Parameter(Mandatory=1)][string] $computer, 
        [Parameter(Mandatory=1)][string] $tabularServer, 
        [Parameter(Mandatory=0)][string] $sqlVersion = '11.0'
    )

    #$utilityInstallDir = Invoke-EnvironmentCommand -server $server -credential $credential `
        #-command "Get-ItemProperty -Path ""Registry::HKEY_CURRENT_USER\Software\Microsoft\SQL Server Management Studio\$($sqlVersion)_Config"" -Name InstallDir"

    $asUtilityPath = "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe"

    $asModelName = [System.IO.Path]::GetFileNameWithoutExtension($asDatabase)
    $asFilesDir = [System.IO.Path]::GetDirectoryName($asDatabase)
    $xmlaPath = Join-Path -Path $asFilesDir -ChildPath "$($asModelName).xmla"

    $remoteCommand = "& ""$asUtilityPath"" ""$asDatabase"" ""/d"" ""/o:$xmlaPath"" | Out-Null"

    Invoke-EnvironmentCommand -server $computer -command $remoteCommand

    $remoteCommand = "Invoke-ASCMD -server ""$tabularServer"" -inputFile ""$xmlaPath"""

    Invoke-EnvironmentCommand -server $computer -command $remoteCommand
}