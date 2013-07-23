<#
.Synopsis
Adds an existing Windows user account on a computer to a specific Windows security group.

.Description
Adds an existing Windows user account on a computer to a specific Windows security group.

.Parameter userName
The username of the account to add to the group.

.Parameter groupName
The name of the group to add the user to.

.Parameter computerName
Optional. The computer to be modified.

.Example
Add-WindowsUserToGroup -userName 'DOMAIN\MyUser' `
					   -groupName 'Performance Monitor Users' `
					   -computerName MYCOMPUTER
#>
function Add-WindowsUserToGroup {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)] $userName,
		[Parameter(Position=1,Mandatory=1)] $groupName,
		[Parameter(Position=2,Mandatory=0)] $computerName
	)

	$commandArgs = @{'ScriptBlock' = {

		$group = [ADSI]"WinNT://$using:computerName/$using:groupName,group"
		$usersSet = [ADSI]"WinNT://$using:computerName/$using:groupName"
		$users = @($usersSet.psbase.Invoke("Members")) 

		$foundAccount = $false

		$users | foreach {
			if ($_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) -eq $using:userName) {
				$foundAccount = $true
			}
		}

		if (!$foundAccount) {
			Write-Host "Adding $using:userName user to $using:groupName group..."

			$group.psbase.Invoke("Add", ([ADSI]"WinNT://$using:userName").path)

			"User $using:userName on $($using:computerName) added to $using:groupName group successfully."
		}
		else {
			"User $using:userName on $($using:computerName) already a member of $using:groupName group, skipping addition."
		}
	}}
	
	if (![String]::IsNullOrWhiteSpace($computerName)) {
		$commandArgs.Add('ComputerName', $computerName);
	}
	
	Invoke-Command @commandArgs
}