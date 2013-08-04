function Get-BuildCredentials {
    param(
        [Parameter(Position=0,Mandatory=1)] $userName
    )

    $currentDirectory = Get-Location
    $credentialsPath = Join-Path $currentDirectory Credentials

    if (!(Test-Path $credentialsPath)) {
        throw "Path $credentialsPath containing build credentials does not exist."
    }

    $keyBytes = @()

    $credentialsKeyPath = Join-Path $credentialsPath "Credentials.key"
    if (!(Test-Path $credentialsKeyPath)) {
        throw "Credentials keyfile is missing."
    }
    else {
        $keyBytes = Get-Content $credentialsKeyPath
    }

    $userNameFile = $userName -replace "\\", "#"
    $userNamePath = Join-Path $credentialsPath "$($userNameFile).txt"

    if (!(Test-Path $userNamePath)) {
        throw "File $userNamePath does not exist. Did you run Export-BuildCredentials to store them first?"
    }

    $password = Get-Content $userNamePath | ConvertTo-SecureString -Key $keyBytes

    new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $password
}