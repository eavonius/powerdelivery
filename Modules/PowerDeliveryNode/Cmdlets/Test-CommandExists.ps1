<#
.Synopsis
Tests whether a command is present in the PowerShell path.

.Description
Tests whether a command is present in the PowerShell path. Useful for checking for dependencies.

.Example
Test-Command choco

.Parameter CommandName
The name of the command to test for.
#>
function Test-CommandExists {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][string] $CommandName
  )

  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'stop'

  try {
    if (Get-Command $CommandName) {
      $true
    }
  }
  catch {
    $false
  }
  finally {
    $ErrorActionPreference = $oldPreference
  }
}

Export-ModuleMember -Function Test-CommandExists
