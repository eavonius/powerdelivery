$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

."$scriptPath\NewShareWithPermissions-0.0.1.ps1"
."$scriptPath\ModifySharePermissions.ps1"

<#
.Synopsis
Creates a remote UNC share.

.Description
The New-RemoteShare cmdlet will create a UNC share on the remote computer if it does not exist.

.Parameter computerName
The computer to create the share on.

.Parameter shareName
The name to give the new share.

.Parameter shareDirectory
The local path on the remote computer to share.

.Parameter buildAccountName
The account name to give full access to the share. This will allow files to be deployed by the build. 

For example "MYDOMAIN\MyUser"

.Example
New-RemoteShare REMOTE_COMPUTER MyShare "C:\MyShareDir" "MYDOMAIN\MyUser"
#>
function New-RemoteShare {
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $shareName, 
        [Parameter(Position=2,Mandatory=1)][string] $shareDirectory, 
        [Parameter(Position=3,Mandatory=1)][string] $buildAccountName
    )

    if (!((net view "\\$computerName") -match "^$shareName")) {

        Invoke-Command -ComputerName $computerName -ScriptBlock { 
            param(
                [Parameter(Position=2,Mandatory=1)]$shareDirectory
            )

            if (!(Test-Path -Path $shareDirectory)) {
                New-Item $shareDirectory -ItemType Directory | Out-Null
            }
        
        } -ArgumentList @("$shareDirectory")

        $accountSplit = $buildAccountName.Split("\")

        $domainName = $accountSplit[0]
        $accountName = $accountSplit[1]

        "Creating share \\$computerName\$shareName for $shareDirectory"

        #$aces = @(New-ACE -Name $accountName -Domain $domainName -Permission "Full")

        $result = New-Share -FolderPath "$shareDirectory" -ShareName "$shareName" -ComputerName "$computerName" #-ACEs $aces

        if ($result.ReturnCode -ne 0) 
        {
            throw "Error creating share, error code was $result.ReturnCode"
        }

        "Modifying share \\$computerName\$shareName to be available to $domainName\$accountName"

        Modify-WMIShareACL -sharename "$shareName" -accountname "$buildAccountName" -rights "Read,Write" -computer "$computerName"
    }
}