try { 
  $powerdeliveryDir = Split-Path -parent $MyInvocation.MyCommand.Definition
  
  Write-Host "Adding $powerdeliveryDir to PSModulePath"

  $psModulePath = $env:PSModulePath
  
  if (!$psModulePath.Contains($powerdeliveryDir)) {
    [Environment]::SetEnvironmentVariable("PSModulePath", "$psModulePath;$powerdeliveryDir", "Machine")
  }

  "Powerdelivery is now ready."
  
  Write-ChocolateySuccess 'powerdelivery'
} 
catch {
  Write-ChocolateyFailure 'powerdelivery' "$($_.Exception.Message)"
  throw 
}