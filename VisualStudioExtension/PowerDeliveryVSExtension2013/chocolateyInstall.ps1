$pkg = "powerdelivery-vsextension-2013"
$vsix = "PowerDeliveryVSExtension2013.vsix"
$vsVersion = 12
$vsProduct = 2013
$vsixId = "9c6c2f23-b97a-4797-86c1-08f94e0e4300"

try { 
    $powerdeliveryDir = Split-Path -parent $MyInvocation.MyCommand.Definition

    $installFile = Join-Path $powerdeliveryDir $vsix

    $version = (Get-ChildItem HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio -ErrorAction SilentlyContinue | ? { ($_.PSChildName.EndsWith("$($vsVersion).0")) } | ? {$_.property -contains "InstallDir"})

    if ($version) {
        $dir = (Get-ItemProperty $version.PSPath "InstallDir").InstallDir 
        $installer = Join-Path $dir "VsixInstaller.exe"

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $installer
        $psi.Arguments = "/q /u:$($vsixId)"
        $s = [System.Diagnostics.Process]::Start($psi)
        $s.WaitForExit()

        if ($s.ExitCode -gt 0 -and $s.ExitCode -ne 2003) {
            throw "Unable to uninstall $($vsix). The exit code returned was $($s.ExitCode)"
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $installer
        $psi.Arguments = "/q $installFile"
        $s = [System.Diagnostics.Process]::Start($psi)
        $s.WaitForExit()

        if ($s.ExitCode -gt 0 -and $s.ExitCode -ne 1001) {
            throw "Unable to install $($vsix). The exit code returned was $($s.ExitCode)"
        }

        Write-ChocolateySuccess $pkg
    }
    else {
        throw "Visual Studio $vsProduct could not be found on your computer."
    }
} 
catch {
    Write-ChocolateyFailure $pkg "$($_.Exception.Message)"
    throw 
}