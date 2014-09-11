function New-RemoteTempPath {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $path
    )

    $logPrefix = "New-RemoteTempPath:"

    $invokeArgs = @{
        "ComputerName" = $computerName;
        "ArgumentList" = @($logPrefix, $path);
        "ScriptBlock" = {
            param($logPrefix, $path)

            $newTempDir = $path
            $newTempDirUri = New-Object -TypeName System.Uri -ArgumentList $newTempDir

            if ($newTempDirUri.IsUnc) {
                throw "$newTempDir is a UNC path and cannot be created as a temporary directory on a remote computer."
            }

            if (![System.IO.Path]::IsPathRooted("$path")) {
                $tempOutputDirectory = Join-Path $env:TEMP "PowerDelivery"
                $tempPath = [System.IO.Path]::GetDirectoryName("$path")
                if ($tempPath) {
                    $newTempDir = Join-Path "$tempOutputDirectory" "$tempPath"
                }
            }
            else {
                $newTempDir = [System.IO.Path]::GetDirectoryName("$path")
            }

            if (!(Test-Path $newTempDir)) {
                Write-Host "$logPrefix Creating $newTempDir on $($env:COMPUTERNAME)"
                New-Item -ItemType Directory -Path $newTempDir | Out-Null
            }
                
            return $newTempDir
        };
        "ErrorAction" = "Stop"
    }

    return Invoke-Command @invokeArgs
}