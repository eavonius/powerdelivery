function Get-BuildCredentials {
    param(
        [Parameter(Position=0,Mandatory=1)] $userName
    )

    if (!$powerdelivery.buildCredentials.ContainsKey($userName)) {

        $credentials = $null

        if ($powerdelivery.environment -ne 'Local') {

            $currentDirectory = Get-Location
            $credentialsPath = Join-Path $currentDirectory Credentials

            if (!(Test-Path $credentialsPath)) {
                throw "Path $credentialsPath containing build credentials does not exist."
            }

            [byte[]]$keyBytes = New-Object byte[] 0

            $credentialsKeyPath = Join-Path $credentialsPath "Credentials.key"
            if (!(Test-Path $credentialsKeyPath)) {
                throw "Credentials keyfile is missing."
            }
            else {
                try {                    [System.IO.Stream]$stream = [System.IO.File]::OpenRead($credentialsKeyPath)                    try {                        $keyBytes = New-Object byte[] $stream.length                        [void] $stream.Read($keyBytes, 0, $stream.Length)                    }                    finally {                        $stream.Close() | Out-Null                    }                }                 catch {                    throw "Error reading file $credentialsKeyPath - $_"                }
            }

            $userNameFile = $userName -replace "\\", "#"
            $userNamePath = Join-Path $credentialsPath "$($userNameFile).txt"

            if (!(Test-Path $userNamePath)) {
                throw "File $userNamePath does not exist. Did you run Export-BuildCredentials to store them first?"
            }

            $password = Get-Content $userNamePath | ConvertTo-SecureString -Key $keyBytes

            $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $password
        }
        else {
            $credentials = Get-Credential -UserName $userName
        }

        $powerdelivery.buildCredentials.Add($userName, $credentials)
        $credentials
    }
    else {
        $powerdelivery.buildCredentials[$userName]
    }
}