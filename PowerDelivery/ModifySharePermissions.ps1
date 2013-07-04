function Create-WMIShare{
     param(
    [string]$name,
    [string]$path,
    [string]$description = "",
    [string]$account,
    [string]$rights,
    [string]$maxallowed = $null
    )
    $share = [wmiclass]"Win32_Share"
    $share.Create( $path, $name, 0, $maxallowed,$description )
    $wPrivilege = gwmi Win32_LogicalShareSecuritySetting -filter "name=`"$name`"" 
    $wPrivilege.psbase.Scope.Options.EnablePrivileges = $true 
    $oldDACL = ($wPrivilege.GetSecurityDescriptor()).Descriptor.DACL 
    $sd = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance() 
    $sd.DACL = $oldDACL #copy
    $sd.DACL += @($ace.psobject.baseobject) # append
    $sd.ControlFlags="0x4" # set SE_DACL_PRESENT flag 
    $wPrivilege.SetSecurityDescriptor($sd)
}


function Create-WMITrustee([string]$NTAccount){

    $user = New-Object System.Security.Principal.NTAccount($NTAccount)
    $strSID = $user.Translate([System.Security.Principal.SecurityIdentifier])
    $sid = New-Object security.principal.securityidentifier($strSID) 
    [byte[]]$ba = ,0 * $sid.BinaryLength     
    [void]$sid.GetBinaryForm($ba,0) 
    
    $Trustee = ([WMIClass] "Win32_Trustee").CreateInstance() 
    $Trustee.SID = $ba
    $Trustee
    
}


function Create-WMIAce{
     param(
          [string]$account,
          [string]$rights="Read"
     )
    $trustee = Create-WMITrustee $account
    $ace = ([WMIClass] "Win32_ace").CreateInstance() 
    $ace.AccessMask = [System.Security.AccessControl.FileSystemRights]$rights 
    Write-Host $ace.AccessMask
    $ace.AceFlags = 0 # set inheritances and propagation flags
    $ace.AceType = 0 # set SystemAudit 
    $ace.Trustee = $trustee 
    $ace
}
function Modify-WMIShareACL{
     [CmdLetBinding()]
     param(
          [string]$sharename,
          [string]$accountname,
          [string]$rights='Read',
          [string]$computername
     )
     begin{}
     process{
          $ace=Create-WMIAce $accountname $rights
          $wPrivilege = gwmi Win32_LogicalShareSecuritySetting -filter "name=`"$accountname`"" 
          $wPrivilege.psbase.Scope.Options.EnablePrivileges = $true 
          $oldDACL = ($wPrivilege.GetSecurityDescriptor()).Descriptor.DACL 
          $sd = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance() 
          $sd.DACL = $oldDACL #copy
          $sd.DACL += @($ace.psobject.baseobject) # append
          $sd.ControlFlags="0x4" # set SE_DACL_PRESENT flag 
          $wPrivilege.SetSecurityDescriptor($sd)
      }
      end{}
}