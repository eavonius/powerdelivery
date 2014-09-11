function Set-EnvironmentVariable {
    param(
        [Parameter(Position=0,Mandatory=1)] $computerName,
        [Parameter(Position=1,Mandatory=1)] $name,
        [Parameter(Position=2,Mandatory=1)] $value
    )
    
    $logPrefix = "Set-EnvironmentVariable:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        "$logPrefix setting $name on $computerName to $value"

        $invokeArgs = @{
            "ArgumentList" = @($name, $value);
            "ScriptBlock" = {
                param($varName, $varValue)

                if (-not ("win32.nativemethods" -as [type])) {
                    # import sendmessagetimeout from win32
                    add-type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr SendMessageTimeout(
            IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
            uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
                }

                $HWND_BROADCAST = [intptr]0xffff
                $WM_SETTINGCHANGE = 0x1a
                $result = [uintptr]::zero

                [Environment]::SetEnvironmentVariable($varName, $varValue, [EnvironmentVariableTarget]::Machine)

                Invoke-Expression "`$Env:$varName = `"$varValue`""
            
                # notify all windows of environment block change
                [win32.nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE,
                    [uintptr]::Zero, "Environment", 2, 5000, [ref]$result);
            };
            "ErrorAction" = "Stop"
        }

        if (!$curComputerName.StartsWith("localhost")) {
            $invokeArgs.Add("ComputerName", $curComputerName)
        }

        Invoke-Command @invokeArgs

        Write-BuildSummaryMessage -name "Configuration" -header "Configurations" -message "Environment Variable: $name -> $value ($computerName)"
    }
}