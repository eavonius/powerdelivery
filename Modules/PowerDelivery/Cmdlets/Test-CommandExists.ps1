function Test-CommandExists {
  param($command)

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