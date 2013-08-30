function Copy-Robust {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $path,
	    [Parameter(Position=1,Mandatory=1)][string] $destination,
	    [Parameter(Position=2,Mandatory=0)][string] $filter	= "*.*",
        [Parameter(Position=3,Mandatory=0)][switch] $recurse = $false,
        [Parameter(Position=4,Mandatory=0)][switch] $excludeNewer = $false,
        [Parameter(Position=5,Mandatory=0)][switch] $excludeOlder = $true
    )

    $logPrefix = "Copy-Robust:"

    mkdir -Force -ErrorAction SilentlyContinue $destination | Out-Null

    $command = "robocopy `"$path`" `"$destination`" $filter /E /NP /ETA /NJH /NJS /NFL /NDL"

    if ($excludeNewer) {
        $command += " /XN"
    }

    if ($excludeOlder) {
        $command += " /XO"
    }

    if ($recurse -eq $false) {
        $command += " /LEV:1"
    }

    "$logPrefix $command"
    Invoke-Expression $command
            
    if ($LASTEXITCODE -ge 8) {
        throw "Robocopy failed to copy one or more files."
    }
}