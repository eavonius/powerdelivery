$pkg = "powerdelivery-vsextension-2012"
$vsix = "PowerDeliveryVSExtension.2012.vsix"
$vsVersion = 11
$vsProduct = 2012
$vsixId = "8d0861c8-1688-40be-bdcd-cffa25e18d40"

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

        if ($s.ExitCode -gt 0 -and $s.ExitCode -ne 1001) {
            throw "Unable to uninstall $($vsix). The exit code returned was $($s.ExitCode)"
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