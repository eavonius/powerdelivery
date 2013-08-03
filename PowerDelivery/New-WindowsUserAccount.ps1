<#
.Synopsis
Creates a local Windows user account on a computer.

.Description
Creates a local Windows user account on a computer.

.Parameter userName
The username of the account to create.

.Parameter password
The password of the account to create.

.Parameter computerName
Optional. The computer to be modified.

.Example
Add-WindowsUserToGroup -userName 'DOMAIN\MyUser' `
					   -password 's@m3p@ss' `
					   -computerName MYCOMPUTER
#>
function New-WindowsUserAccount {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)] $userName,
		[Parameter(Position=1,Mandatory=1)] $password,
		[Parameter(Position=2,Mandatory=0)] $computerName
	)

    $logPrefix = "New-WindowsUserAccount:"

    Invoke-Command -ComputerName $computerName {

		$localUsersSet = [ADSI]"WinNT://$using:computerName/Users"
		$localUsers = @($localUsersSet.psbase.Invoke("Members")) 

		$foundAccount = $false

		$localUsers | foreach {
			if ($_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) -eq $using:userName) {
				$foundAccount = $true
			}
		}

		if (!$foundAccount) {
			Write-Host "$using:logPrefix Adding $using:userName user to $($using:computerName)..."

			$addUserArgs = @(
				"user",
				$using:userName,
				$using:password,
				"/add",
				"/active:YES",
				"/expires:NEVER",
				"/FullName:`"$using:userName`""
			)

			$addUserProcess = Start-Process -FilePath "C:\Windows\System32\net.exe" -ArgumentList $addUserArgs -PassThru -Wait
			$addUserProcess.WaitForExit()

			"$using:logPrefix User $using:userName created successfully."
		}
	}
}