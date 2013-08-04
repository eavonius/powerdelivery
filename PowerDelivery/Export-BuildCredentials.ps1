function Export-BuildCredentials {

    $currentDirectory = Get-Location
    $credentialsPath = Join-Path $currentDirectory Credentials

    if (!(Test-Path $credentialsPath)) {
        mkdir -Force $credentialsPath | Out-Null
    }

    $keyBytes = @()

    $credentialsKeyPath = Join-Path $credentialsPath "Credentials.key"
    if (!(Test-Path $credentialsKeyPath)) {
        $keyBytes = (1..32 | % { [byte](Get-Random -Minimum 0 -Maximum 255) })
        $keyBytes | Out-File $credentialsKeyPath
    }
    else {
        $keyBytes = Get-Content $credentialsKeyPath
    }

    "Enter the username of an account to export credentials of:"
    $userName = Read-Host

    $userNameFile = $userName -replace "\\", "#"

    $userNamePath = Join-Path $credentialsPath "$($userNameFile).txt"

    "Enter the password of the account:"
    $password = Read-Host -AsSecureString | ConvertFrom-SecureString -Key $keyBytes | Out-File $userNamePath -Force

    "Credentials exported at $userNamePath"
}