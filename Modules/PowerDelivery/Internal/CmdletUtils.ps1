<#
CmdletUtils.ps1

Utility functions used internally by powerdelivery.
#>

function TestAdministrator
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}