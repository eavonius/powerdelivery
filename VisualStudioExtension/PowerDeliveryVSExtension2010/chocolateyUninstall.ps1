$ErrorActionPreference = "Stop"

$scriptPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$sharedScript = Join-Path $scriptPath "uninstallExtension.ps1"

. $sharedScript

# Uninstalls the Visual Studio 2010 Extension for PowerDelivery
#
Uninstall-Extension -scriptPath $scriptPath -ExtensionVersion 2010 -VSVersion 10 -vsixId "E4D8E826-0144-4775-B7BA-1FA37BE8EB74"