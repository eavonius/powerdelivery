function Test-CommandExists {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][string] $command
  )

  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'stop'

  try {
    if (Get-Command $command) {
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