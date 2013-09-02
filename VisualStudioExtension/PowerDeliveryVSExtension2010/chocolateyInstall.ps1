$pkg = "powerdelivery-vsextension-2010"
$vsix = "PowerDeliveryVSExtension.2010.vsix"
$vsVersion = 10
$vsProduct = 2010
$vsixId = "E4D8E826-0144-4775-B7BA-1FA37BE8EB74"

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