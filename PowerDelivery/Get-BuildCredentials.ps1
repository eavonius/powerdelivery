function Get-BuildCredentials {
    param(
        [Parameter(Position=0,Mandatory=0)] $userName
    )

    $credentialUserName = $userName

    if ([String]::IsNullOrWhiteSpace("$credentialUserName")) {
        $credentialUserName = whoami
    }

    if (!$powerdelivery.buildCredentials.ContainsKey($credentialUserName)) {

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
                try {
                    [System.IO.Stream]$stream = [System.IO.File]::OpenRead($credentialsKeyPath)
                    try {
                        $keyBytes = New-Object byte[] $stream.length
                        [void] $stream.Read($keyBytes, 0, $stream.Length)
                    }
                    finally {
                        $stream.Close() | Out-Null
                    }
                } 
                catch {
                    throw "Error reading file $credentialsKeyPath - $_"
                }
            }

            $userNameFile = $credentialUserName -replace "\\", "#"
            $userNamePath = Join-Path $credentialsPath "$($userNameFile).txt"

            if (!(Test-Path $userNamePath)) {
                throw "File $userNamePath does not exist. Did you run Export-BuildCredentials to store them first?"
            }

            $password = Get-Content $userNamePath | ConvertTo-SecureString -Key $keyBytes

            $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $credentialUserName, $password
        }
        else {
            $credentials = Get-Credential -UserName $credentialUserName
        }

        $powerdelivery.buildCredentials.Add($credentialUserName, $credentials)
        $credentials
    }
    else {
        $powerdelivery.buildCredentials[$credentialUserName]
    }
}