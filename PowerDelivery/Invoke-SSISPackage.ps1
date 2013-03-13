function Invoke-SSISPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $package, 
        [Parameter(Mandatory=1)][string] $server, 
        [Parameter(Mandatory=0)][string] $version = "110", 
        [Parameter(Mandatory=0)][string] $packageArgs
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