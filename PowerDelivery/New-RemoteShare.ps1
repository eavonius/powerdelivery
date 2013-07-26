$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

. (Join-Path $scriptPath NewShareWithPermissions-0.0.1.ps1)

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

.Example
New-RemoteShare REMOTE_COMPUTER MyShare "C:\MyShareDir"
#>
function New-RemoteShare {
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $shareName, 
        [Parameter(Position=2,Mandatory=1)][string] $shareDirectory
    )
	
	$buildAccountName = whoami

    if (!((net view "\\$computerName") -match "^$shareName")) {

        "Creating UNC share \\$computerName\$shareName for $shareDirectory..."

        $result = New-Share -FolderPath "$shareDirectory" -ShareName "$shareName" -ComputerName "$computerName"

        if ($result.ReturnCode -ne 0) {
            throw "Error creating share \\$computerName\$shareName, error code was $result.ReturnCode"
        }
    }
    else {
        "Share \\$computerName\$shareName already exists, skipping creation."
    }

    "Modifying share \\$computerName\$shareName to be available to $buildAccountName"

    Invoke-Command -ComputerName $computerName {

        $user = New-Object System.Security.Principal.NTAccount($using:buildAccountName)
        $strSID = $user.Translate([System.Security.Principal.SecurityIdentifier])
        $sid = New-Object System.Security.Principal.SecurityIdentifier($strSID) 
        [byte[]]$ba = ,0 * $sid.BinaryLength     
        [void]$sid.GetBinaryForm($ba,0) 
    
        $trustee = ([WMIClass] "Win32_Trustee").CreateInstance() 
        $trustee.SID = $ba
        
        $ace = ([WMIClass] "Win32_ace").CreateInstance() 
        $ace.AccessMask = 2032127
        $ace.AceFlags = 3
        $ace.AceType = 0
        $ace.Trustee = $trustee 

        $wPrivilege = gwmi Win32_LogicalShareSecuritySetting -filter "name=`"$using:shareName`"" 
        $wPrivilege.psbase.Scope.Options.EnablePrivileges = $true 
        $oldDACL = ($wPrivilege.GetSecurityDescriptor()).Descriptor.DACL 
        $sd = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance() 
        $sd.DACL = $oldDACL
        $sd.DACL += @($ace.psobject.baseobject)
        $sd.ControlFlags = "0x4"
        $wPrivilege.SetSecurityDescriptor($sd) | Out-Null
    }
}