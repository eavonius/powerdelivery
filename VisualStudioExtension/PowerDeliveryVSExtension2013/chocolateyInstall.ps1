$ErrorActionPreference = "Stop"

$scriptPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$sharedScript = Join-Path $scriptPath "installExtension.ps1"

. $sharedScript

# Installs the Visual Studio 2010 Extension for PowerDelivery
#
Install-Extension -scriptPath $scriptPath -ExtensionVersion 2013 -VSVersion 12 -vsixId "9c6c2f23-b97a-4797-86c1-08f94e0e4300"