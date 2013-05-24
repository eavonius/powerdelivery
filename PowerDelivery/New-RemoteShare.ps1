.\NewShareWithPermissions-0.0.1.ps1

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

    Invoke-Command -ComputerName $computerName -ScriptBlock { 
        param(
            $computerName,
            $shareName,
            $shareDirectory,
            $buildAccountName
        )

        if (!(Test-Path -Path $shareDirectory)) {
            New-Item $shareDirectory -ItemType Directory
        }
        if (!(Get-PSDrive -PSProvider FileSystem -Name $shareName)) {

            $domainName = $buildAccountName.Split("\")[0]
            $accountName = $buildAccountName.Split("\")[1]

            $aces = New-ACE -Name $accountName -Domain $domainName -Permission "Full"

            New-Share -FolderPath $shareDirectory -ShareName $shareName -ComputerName $computerName -ACEs $aces
        }
    }
}