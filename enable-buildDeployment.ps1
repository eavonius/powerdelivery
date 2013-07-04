<#
Enable-BuildDeployment.ps1

Sets up a computer to be remotely deployed to and managed 
by a TFS build agent for continuous delivery.
#>

param(
  [Parameter(Mandatory=1)][string] $buildAgentComputer,
  [Parameter(Mandatory=1)][string] $buildUserName,
  [Parameter(Mandatory=1)][string] $buildUserDomain
)

if ($(get-host).version.major -lt 3) {
  "Powershell 3.0 or greater is required."
  exit
}

$localComputer = gc env:computername

$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
if (!(New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
  "Please re-run the PowerShell console as Administrator before running this script."
  exit
}

$localAdminGroup = [ADSI]"WinNT://$localComputer/Administrators,group" 
$localAdminSet = [ADSI]"WinNT://$localComputer/Administrators"
$localAdminGroupMembers = @($localAdminSet.psbase.Invoke("Members"))

$isMemberOfAdminGroup = $false

"Checking if $buildUserDomain\$buildUserName is a member of the local Administrators group..."

$localAdminGroupMembers | foreach {
    if ($_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) -eq "$buildUserDomain\$buildUserName") {
        $isMemberOfAdminGroup = $true
    }
}

if ($isMemberOfAdminGroup -eq $false) {
    "Adding $buildUserDomain\$buildUserName to the local Administrators group..."
    $localAdminGroup.psbase.Invoke("Add",([ADSI]"WinNT://$buildUserDomain/$buildUserName").path)
}

"Performing WinRM quick configuration..."

winrm quickconfig -Force

"Enabling PowerShell Remoting..."

Enable-PSRemoting -force

"Permitting $buildAgentComputer to issue commands to $localComputer..."

$winRmConfigParams = '@{TrustedHosts="buildAgentComputer"}' -Replace "buildAgentComputer", "$buildAgentComputer"

winrm set winrm/config/client $winRmConfigParams
