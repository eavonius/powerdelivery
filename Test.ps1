<# Test.ps1
Tests powerdelivery with Pester https://github.com/pester/Pester.
You must install Pester first. With chocolatey: cinst pester
#>
$startDir = Get-Location

Set-Location .\Tests

try {
  Invoke-Pester
}
finally {
  Set-Location $startDir
}
