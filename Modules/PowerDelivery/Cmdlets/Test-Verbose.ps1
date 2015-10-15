function Test-Verbose {
[CmdletBinding()]
param()
    [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
}