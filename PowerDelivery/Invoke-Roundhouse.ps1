function Invoke-Roundhouse {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $database, 
        [Parameter(Position=1,Mandatory=1)][string] $server, 
        [Parameter(Position=2,Mandatory=1)][string] $scriptsDir, 
        [Parameter(Position=3,Mandatory=0)][string] $restorePath, 
        [Parameter(Position=4,Mandatory=0)][string] $restoreOptions
    )

    $environment = Get-BuildEnvironment

	"Running database migrations on $server\$database"

    $command = "rh --silent /vf=""sql"" /s=$server /d=$database /f=""$scriptsDir"" /env=$environment /o=Databases\$database\output /simple"
    
    if ($environment -ne 'Production' -and ![String]::IsNullOrWhitespace($restorePath)) {
        $command += " --restore --restorefrompath=""$restorePath"""
        if (![String]::IsNullOrWhiteSpace($restoreOptions)) {
            $command += " --restorecustomoptions=""$restoreOptions"""
        }
    }

	Exec -ErrorAction Stop { 
	    Invoke-Expression -Command $command	
	}
}