function Refresh-Explorer {
	
	if (-not ("PowerDeliveryClient.UninstallFunctions" -as [Type])) {
		Add-Type -Namespace PowerDeliveryClient -Name UninstallFunctions -MemberDefinition @"

			[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true)] 
			public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
			 
			[System.Runtime.InteropServices.DllImport("shell32.dll")] 
			public static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
"@
	}

	$HWND_BROADCAST = [intptr]0xffff 
	$WM_SETTINGCHANGE = [int]0x1a 
	$SMTO_ABORTIFHUNG = [int]0x0002
	$SHCNE_ALLEVENTS =  [int]0x7FFFFFFF
	$SHCNF_FLUSH = [int]0x1000
	$intZero = [IntPtr]::Zero
	$uintZero = [UIntPtr]::Zero
	$result = [UIntPtr]::Zero

	[PowerDeliveryClient.UninstallFunctions]::SHChangeNotify($SHCNE_ALLEVENTS, $SHCNF_FLUSH, $intZero, $intZero) | Out-Null
	[PowerDeliveryClient.UninstallFunctions]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, $uintZero, $intZero, $SMTO_ABORTIFHUNG, 100, [ref] $result) | Out-Null
}

try { 
	$clientPath = Split-Path -parent $MyInvocation.MyCommand.Definition

	$targetFilePath = Join-Path $clientPath "PowerDelivery.exe"
	
	$desktopDir = [Environment]::GetFolderPath("Desktop")
	$desktopShortcut = Join-Path $desktopDir "PowerDelivery.exe.lnk"
	if (Test-Path $desktopShortcut -PathType Leaf) {
		"Removing shortcut from the desktop."
		rm $desktopShortcut | Out-Null
	}

	$shortcutName = "PowerDelivery.lnk"

	$taskBarPath = Join-Path ([Environment]::GetFolderPath("ApplicationData")) "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
	$shortcutPath = Join-Path $taskBarPath $shortcutName
	
	if (Test-Path $shortcutPath) {
		$shell = new-object -com "Shell.Application"
		$folder = $shell.Namespace($taskBarPath)
    	$item = $folder.Parsename($shortcutName) 

    	$verb = "Unpin from Taskbar"
    	$itemVerb = $item.Verbs() | ? {$_.Name.Replace("&","") -eq $verb} 

    	if ($itemVerb -eq $null) { 
        	Write-Host "PowerDelivery.exe appears to no longer be pinned to the taskbar, skipping shortcut removal."
        }
    	else { 
        	"Unpinning shortcut from the taskbar."
        	$itemVerb.DoIt() 
    	}
	}

	Refresh-Explorer
}
catch {
    Write-ChocolateyFailure "powerdelivery-client" "$($_.Exception.Message)"
    throw 
}