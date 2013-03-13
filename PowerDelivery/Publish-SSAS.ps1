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