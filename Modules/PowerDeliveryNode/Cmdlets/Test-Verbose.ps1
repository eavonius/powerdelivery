<#
.Synopsis
Tests whether PowerShell is being run in verbose mode.

.Description
Tests whether PowerShell is being run in verbose mode. Useful for logging additional details only when requested.

.Example
if (Test-Verbose) {
  Write-Host "Detailed log entry"
}
#>
function Test-Verbose {
  [CmdletBinding()]
  param()
  [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
}

Export-ModuleMember -Function Test-Verbose
