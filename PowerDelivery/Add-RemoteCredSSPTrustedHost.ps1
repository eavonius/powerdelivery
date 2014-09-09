function Add-RemoteCredSSPTrustedHost {
    param(
        [Parameter(Position=0,Mandatory=1)] [string] $clientComputerName,
        [Parameter(Position=1,Mandatory=1)] [string] $serverComputerName
    )

    $logPrefix = "Add-RemoteCredSSPTrustedHost"

    Invoke-Command -ComputerName $serverComputerName -ArgumentList @($logPrefix) -ScriptBlock {
        param($varLogPrefix)
        Write-Host "$varLogPrefix Enabling $($env:COMPUTERNAME) to receive remote CredSSP credentials"
        Enable-WSManCredSSP -Role Server -Force | Out-Null
    }

    Invoke-Command -ComputerName $clientComputerName `
        -ArgumentList @($serverComputerName, $logPrefix) `
        -ScriptBlock { 
            param($varServerComputerName, $varLogPrefix)

            $credSSP = Get-WSManCredSSP

            $computerExists = $false

            if ($credSSP -ne $null) {
                if ($credSSP.length -gt 0) {
                    $trustedClients = $credSSP[0].Substring($credSSP[0].IndexOf(":") + 2)
                    $trustedClientsList = $trustedClients -split "," | % { $_.Trim() }
            
                    if ($trustedClientsList.Contains("wsman/$varServerComputerName")) {
                        $computerExists = $true
                    }
                }
            }

            if (!$computerExists) {
                Write-Host "$varLogPrefix Enabling CredSSP credentials to travel from $($env:COMPUTERNAME) to $varServerComputerName"
                Enable-WSManCredSSP -Role Client -DelegateComputer "$varServerComputerName" -Force | Out-Null
            }
        }
}