function Copy-FilesWithLongPath {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $path,
	    [Parameter(Position=1,Mandatory=1)][string] $destination,
	    [Parameter(Position=2,Mandatory=0)][string] $filter	= "*.*"
    )

    $logPrefix = "Copy-FilesWithLongPath:"

    mkdir -Force -ErrorAction SilentlyContinue $destination | Out-Null

    $command = "robocopy `"$path`" `"$destination`" $filter /E /NP /ETA /NJH /NJS /NFL /NDL /XN"
    "$logPrefix $command"
    Invoke-Expression $command
            
    if ($LASTEXITCODE -ge 8) {
        throw "Robocopy failed to copy one or more files."
    }
}