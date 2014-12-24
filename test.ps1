$curDir = Get-Location

try {
    Set-Location .\Tests
    Import-Module Pester
    Invoke-Pester
}
finally {
    Set-Location $curDir
}