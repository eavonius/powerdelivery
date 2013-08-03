try { 
    $clientPath = Split-Path -parent $MyInvocation.MyCommand.Definition

	$targetFilePath = Join-Path $clientPath "PowerDelivery.exe"
	
	Install-ChocolateyDesktopLink $targetFilePath
	Install-ChocolateyPinnedTaskBarItem $targetFilePath
}
catch {
    Write-ChocolateyFailure "powerdelivery-client" "$($_.Exception.Message)"
    throw 
}