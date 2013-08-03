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
The computer to be modified.

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
		[Parameter(Position=2,Mandatory=1)] $computerName
	)

    $logPrefix = "Add-WindowsUserToGroup:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

	    Invoke-Command $curComputerName {

		    $group = [ADSI]"WinNT://$using:curComputerName/$using:groupName,group"
		    $usersSet = [ADSI]"WinNT://$using:curComputerName/$using:groupName"
		    $users = @($usersSet.psbase.Invoke("Members")) 

		    $foundAccount = $false

		    $users | foreach {
			    if ($_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) -eq $using:userName) {
				    $foundAccount = $true
			    }
		    }

		    if (!$foundAccount) {
			    "$using:logPrefix Adding $using:userName user to $using:groupName group on $($using:curComputerName)..."

			    $group.psbase.Invoke("Add", ([ADSI]"WinNT://$using:userName").path)

			    "$using:logPrefix User $using:userName added to $using:groupName group on $($using:curComputerName) successfully."
		    }
	    }
    }
}