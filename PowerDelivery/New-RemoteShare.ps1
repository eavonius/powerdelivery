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
        [Parameter(Position=0,Mandatory=1)] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $shareName, 
        [Parameter(Position=2,Mandatory=1)][string] $shareDirectory
    )
	
    # //************************************************************************************************************
    # // ***** Script Header *****
    # //
    # // Solution:  Coretech Share Functions
    # // File:      NewShareWithPermission.ps1
    # // Author:    Jakob Gottlieb Svendsen, Coretech A/S. http://blog.coretech.dk
    # // Purpose:   
    # // New-Share: Creates new Share on local or remote PC, with custom permissions.
    # // Required Parameters: FolderPath, ShareName
    # //
    # // New-ACE: Creates ACE Objects, for use when running New-Share.
    # // Required Parameters: Name, Domain
    # //
    # // New-SecurityDescriptor: used by New-Share to prepare the permissions.
    # // Required Parameters: ACEs
    #//
    # // Usage Examples:  
    # // New-Share -FolderPath "C:\Temp" -ShareName "Temp" -ACEs $ACE,$ACE2  -Description "Test Description" -Computer "localhost"
    # // Sharing of folder C:\Temp, with the Name "Temp". ACE's (Permissions) are sent via the -ACEs parameter.
    # // Create them with New-ACE and send one  or more, seperated by comma (or create and array and use that)
    # // 
    # // This is the first in a couple of share-administration scripts i am planning to make and release on the blog.
    # //
    # // Please comment the blog post, if you have any suggestions, questions or feedback.
    # // Contact me if you need us to make a custom script (or cause not for free ;-) ) 
    # //
    # // CORETECH A/S History:
    # // 0.0.1     JGS 30/06/2009  Created initial version.
    # //
    # // Customer History:
    # //
    # // ***** End Header *****
    # //**************************************************************************************************************
    #//----------------------------------------------------------------------------
    #//  Procedures
    #//----------------------------------------------------------------------------
    Function New-SecurityDescriptor (
        $ACEs = (throw "Missing one or more Trustees"), 
        [string] $ComputerName = ".")
    {
        #Create SeCDesc object
        $SecDesc = ([WMIClass] "\\$ComputerName\root\cimv2:Win32_SecurityDescriptor").CreateInstance()
        #Check if input is an array or not.
        if ($ACEs -is [System.Array])
        {
            #Add Each ACE from the ACE array
            foreach ($ACE in $ACEs )
            {
                $SecDesc.DACL += $ACE.psobject.baseobject
            }
        }
        else
        {
            #Add the ACE 
            $SecDesc.DACL =  $ACEs
        }
        #Return the security Descriptor
        return $SecDesc
    }
    Function New-ACE (
        [string] $Name = (throw "Please provide user/group name for trustee"),
        [string] $Domain = (throw "Please provide Domain name for trustee"), 
        [string] $Permission = "Read",
        [string] $ComputerName = ".",
        [switch] $Group = $false)
    {
        #Create the Trusteee Object
        $Trustee = ([WMIClass] "\\$ComputerName\root\cimv2:Win32_Trustee").CreateInstance()
        #Search for the user or group, depending on the -Group switch
        if (!$group)
        { $account = [WMI] "\\$ComputerName\root\cimv2:Win32_Account.Name='$Name',Domain='$Domain'" }
        else
        { $account = [WMI] "\\$ComputerName\root\cimv2:Win32_Group.Name='$Name',Domain='$Domain'" }
        #Get the SID for the found account.
        $accountSID = [WMI] "\\$ComputerName\root\cimv2:Win32_SID.SID='$($account.sid)'"
        #Setup Trusteee object
        $Trustee.Domain = $Domain
        $Trustee.Name = $Name
        $Trustee.SID = $accountSID.BinaryRepresentation
        #Create ACE (Access Control List) object.
        $ACE = ([WMIClass] "\\$ComputerName\root\cimv2:Win32_ACE").CreateInstance()
        #Select the AccessMask depending on the -Permission parameter
        switch ($Permission)
        {
            "Read"       { $ACE.AccessMask = 1179817 }
            "Change"  { $ACE.AccessMask = 1245631 }
            "Full"         { $ACE.AccessMask = 2032127 }
            default { throw "$Permission is not a supported permission value. Possible values are 'Read','Change','Full'" }
        }
        #Setup the rest of the ACE.
        $ACE.AceFlags = 3
        $ACE.AceType = 0
        $ACE.Trustee = $Trustee
        #Return the ACE
        return $ACE
    }
    Function New-Share (
        [string] $FolderPath = (throw "Please provide the share folder path (FolderPath)"),
        [string] $ShareName = (throw "Please provide the Share Name"), 
        $ACEs, 
        [string] $Description = "",
        [string] $ComputerName=".")
    {
        #Start the Text for the message.
        $text = "$ShareName ($FolderPath): "

        #Package the SecurityDescriptor via the New-SecurityDescriptor Function.
        $SecDesc = New-SecurityDescriptor $ACEs

        #Create the share via WMI, get the return code and create the return message.
        $Share = [WMICLASS] "\\$ComputerName\Root\Cimv2:Win32_Share"
        $result = $Share.Create("$FolderPath", "$ShareName", 0, 16777216, $Description, $null, $SecDesc)
        switch ($result.ReturnValue)
        {
            0 {$text += "has been success fully created" }
            2 {$text += "Error 2: Access Denied" }
            8 {$text += "Error 8: Unknown Failure" }
            9 {$text += "Error 9: Invalid Name"}
            10 {$text += "Error 10: Invalid Level" }
            21 {$text += "Error 21: Invalid Parameter" }
            22 {$text += "Error 22 : Duplicate Share"}
            23 {$text += "Error 23: Redirected Path" }
            24 {$text += "Error 24: Unknown Device or Directory" }
            25 {$text += "Error 25: Net Name Not Found" }
        }

        #Create Custom return object and Add results
        $return = New-Object System.Object
        $return | Add-Member -type NoteProperty -name ReturnCode -value $result.ReturnValue
        $return | Add-Member -type NoteProperty -name Message -value $text  

        #Return result object
        $return
    }
    #//----------------------------------------------------------------------------
    #//  End Script
    #//----------------------------------------------------------------------------

	Set-Location $powerdelivery.deployDir

    $logPrefix = "New-RemoteShare:"

    $buildAccountName = whoami

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        if (!((net view "\\$curComputerName") -match "^$shareName")) {

            Invoke-Command -ComputerName $curComputerName {
        
                if (!(Test-Path $using:shareDirectory)) {
                    "$using:logPrefix Creating directory $using:shareDirectory on $using:curComputerName..."
                    mkdir $using:shareDirectory -Force | Out-Null
                }
            }

            "$logPrefix Creating UNC share \\$curComputerName\$shareName for $shareDirectory..."

            $result = New-Share -FolderPath "$shareDirectory" -ShareName "$shareName" -ComputerName "$curComputerName"

            if ($result.ReturnCode -ne 0) {
                throw "Error creating share \\$curComputerName\$shareName, error code was $result.ReturnCode"
            }
        }

        Invoke-Command -ComputerName $curComputerName {

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
}