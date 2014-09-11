<#
.Synopsis
Runs an SSIS package using dtexec.exe.

.Description
The Invoke-SSIS cmdlet is used to execute a Microsoft SQL Server Integration Services (SSIS) package. This cmdlet runs dtexec.exe on a remote computer.

Copy your .dtsx packages to a UNC share within the Deploy block of your script onto each computer you wish to run packages on.

.Parameter package
A path local to the remote server the package is being executed on. If you had a UNC share on that server "\\MyServer\MyShare" and it was mapped to "D:\Somepath", use "D:\Somepath" here.

.Parameter computerName
The computer name(s) onto which to execute the package. If not "localhost", this computer must have PowerShell 3.0 with WinRM installed, allow execution of commands from the TFS build server and the account under which the build agent service is running.

.Parameter dtExecPath
The path to dtexec.exe on the server to run the command.

.Parameter credentialUserName
The username of the credentials to use for running dtexec. These credentials should have already been added to the build using the Export-BuildCredentials cmdlet. If you don't pass this the credentials of the currently logged in user will be loaded.

.Parameter packageArgs
Optional. A PowerShell hash containing name/value pairs to set as package arguments to dtexec.

.Example
Invoke-SSIS -package MyPackage.dtsx -ComputerName MyServer -packageArgs @{MyCustomArg = SomeValue}
#>
function Invoke-SSISPackage {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $package, 
        [Parameter(Position=1,Mandatory=1)][string] $computerName, 
        [Parameter(Position=2,Mandatory=1)][string] $dtExecPath, 
        [Parameter(Position=3,Mandatory=0)][string] $credentialUserName,
        [Parameter(Position=4,Mandatory=0)][string] $packageArgs
    )
    
    Set-Location $powerdelivery.deployDir
    
    $logPrefix = "Invoke-SSISPackage:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    $dropLocation = Get-BuildDropLocation

    $logFileName = [System.IO.Path]::GetFileNameWithoutExtension("$package") + ".log"

    $dropLogPath = [System.IO.Path]::GetDirectoryName("$package")
    if (!(Test-Path "$dropLogPath")) {
        New-Item -ItemType Directory -Path $dropLogPath | Out-Null
    }

    foreach ($curComputerName in $computerNames) {

        # Allow credentials to travel from remote computer to TFS server
        #
        $dropUri = New-Object -TypeName System.Uri -ArgumentList $dropLocation
        if ($dropUri.IsUnc) {
            $dropHost = $dropUri.Host            
            $remoteComputer = [System.Net.Dns]::GetHostByName("$dropHost").HostName
            Add-RemoteCredSSPTrustedHost $curComputerName $remoteComputer
        }
        
        $remoteLogFile = Join-Path (New-RemoteTempPath $curComputerName $package) $logFileName

        $invokeArgs = @{
            "ArgumentList" = @($logPrefix, $package, $dtExecPath, $packageArgs, $dropLogPath, $remoteLogFile);
            "ScriptBlock" = {
                param($logPrefix, $package, $dtExecPath, $packageArgs, $dropLogPath, $remoteLogFile)

                # Delete the prior temporary log file if one exists
                #
                if (Test-Path -Path "$remoteLogFile") {
                    Remove-Item -Path "$remoteLogFile" -Force | Out-Null
                }

                $innerPackage = $package
                $innerDTExecPath = $dtExecPath
                $innerPackageArgs = $packageArgs

                $packageExecStatement = """$innerDTExecPath"" /File '$innerPackage'"
            
                if ($innerPackageArgs) {
                    $packageExecStatment += " $innerPackageArgs"
                }

                $packageExecStatement +=  " | Out-File ""$remoteLogFile"""

                Write-Host "$varLogPrefix $packageExecStatement"
                Invoke-Expression "& $packageExecStatement"

                # Copy the SSIS log file from the temporary directory to the build drop location.
                #
                if (Test-Path $remoteLogFile) {
                    if ([System.IO.Path]::GetDirectoryName("$remoteLogFile") -ne $dropLogPath) {
                        Write-Host "$varLogPrefix $remoteLogFile -> $dropLogPath"
                        Copy-Item "$remoteLogFile" "$dropLogPath"
                    }
                }
            };
            "ErrorAction" = "Stop"
        }

        Add-CommandCredSSP $curComputerName $invokeArgs $credentialUserName

        Invoke-Command @invokeArgs

        Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "SSIS: $package ($curComputerName)"
    }
}