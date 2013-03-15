<#
.Synopsis
Runs an SSIS package using dtexec.exe.

.Description
The Invoke-SSIS cmdlet is used to execute a Microsoft SQL Server Integration Services (SSIS) package. This cmdlet runs dtexec.exe on a remote computer.

Copy your .dtsx packages to a UNC share within the Deploy block of your script onto each computer you wish to run packages on.

.Parameter package
A path local to the remote server the package is being executed on. If you had a UNC share on that server "\\MyServer\MyShare" and it was mapped to "D:\Somepath", use "D:\Somepath" here.

.Parameter server
The computer name onto which to execute the package. This computer must have PowerShell 3.0 with WinRM installed, and allow execution of commands from the TFS build server and the account under which the build agent service is running.

.Parameter packageArgs
Optional. A PowerShell hash containing name/value pairs to set as package arguments to dtexec.

.Parameter version
Optional. The version of dtexec to run ("90", "100", "110" etc.). The default is "110" (SQL Server 2012).

.Example
Invoke-SSIS -package MyPackage.dtsx -server MyServer -packageArgs @{MyCustomArg = SomeValue}
#>
function Invoke-SSISPackage {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $package, 
        [Parameter(Position=0,Mandatory=1)][string] $server, 
        [Parameter(Position=0,Mandatory=0)][string] $version = "110", 
        [Parameter(Position=0,Mandatory=0)][string] $packageArgs
    )

	$getSqlInstallDir = "Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\110 -Name VerSpecificRootDir"
	$sqlInstallDir = Invoke-EnvironmentCommand -server $server -command $getSqlInstallDir

	if ([string]::IsNullOrWhiteSpace($sqlInstallDir)) {
        throw "SQL $version does not appear to be installed on $server."
    }
	
	$dtExecPath = Join-Path -Path $sqlInstallDir -ChildPath "DTS\Binn\Dtexec.exe"
	
	$packageExecStatement = "& ""$dtExecPath"" /File '$package'"
	
	if ($packageArgs) {
		$packageExecStatment += " $packageArgs"
	}
	
	Invoke-EnvironmentCommand -server $server -command $packageExecStatement
}