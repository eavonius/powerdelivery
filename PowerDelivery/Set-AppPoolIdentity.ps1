<#
.Synopsis
Sets the identity of an IIS web application pool to a specific user account.

.Description
Sets the identity of an IIS web application pool to a specific user account. 
Use the New-WindowsUserAccount cmdlet to create this user beforehand if 
necessary.

.Parameter appPoolName
The name of the application pool to modify.

.Parameter userName
The username of the account to use for the identity.

.Parameter password
The password of the account to use for the identity.

.Parameter computerName
Optional. The computer running the IIS website to be modified.

.Example
Set-AppPoolIdentity -appPoolName MySite `
                    -userName 'DOMAIN\MyUser' `
					-password 's@m3p@ss' `
					-computerName MYCOMPUTER
#>
function Set-AppPoolIdentity {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)] $appPoolName,
		[Parameter(Position=1,Mandatory=1)] $userName,
		[Parameter(Position=2,Mandatory=1)] $password,
		[Parameter(Position=3,Mandatory=0)] $computerName
	)
			
	$commandArgs = @{'ScriptBlock' = {

		Import-Module WebAdministration

		Set-ItemProperty -Path "IIS:\AppPools\$using:appPoolName" -Name ProcessModel.IdentityType -Value 3
		Set-ItemProperty -Path "IIS:\AppPools\$using:appPoolName" -Name ProcessModel.UserName -Value $using:userName
		Set-ItemProperty -Path "IIS:\AppPools\$using:appPoolName" -Name ProcessModel.Password -Value $using:password
	}}
	
	if (![String]::IsNullOrWhiteSpace($computerName)) {
		$commandArgs.Add('ComputerName', $computerName);
	}
	
	Invoke-Command @commandArgs
}