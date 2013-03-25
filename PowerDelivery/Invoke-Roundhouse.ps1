<#
.Synopsis
Migrates a database using roundhouse.exe.

.Description
The Invoke-Roundhouse cmdlet will run migration scripts on a database using the RoundhousE database migration tool.

In the Compile function of your build, you should copy the directory containing your roundhouse scripts to a subdirectory of the drop location named "Databases". For example, if you had a database named "MyDatabase" you'd have the following directory in TFS with your scripts:

$/MyProject/Databases/MyDatabase

You should copy them in Compile to here:

\DropLocation\Databases\MyDatabase

where DropLocation above is the result of the Get-BuildDropLocation function.

IMPORTANT: Call Invoke-Roundhouse only in the Deploy block.

.Example
Init {
  $script:dbServer = Get-BuildSetting DatabaseServer
  $script:dbName   = Get-BuildSetting DatabaseName

  $script:dbDir     = Join-Path $currentDirectory Databases
  $script:dbDropDir = Join-Path $dropLocation Databases

  $script:productionBackup = D:\Backups\MyDatabase_Latest.mdf
  $script:dataDir = "C:\Program Files\Microsoft SQL Server10\MSAS11.MSSQLSERVER\MSSQL\Data"
}

Compile {
  copy -Recurse -Filter *.* $dbDir $dropLocation
}

Deploy {
  Invoke-Roundhouse -server $dbServer `
                    -database $dbName `
                    -scriptsDir "$dbDropDir\MyDatabase" `
                    -restorePath $productionBackup `
                    -restoreOptions "MOVE 'MyDatabase' TO '$($dataDir)\$($dbName).mdf', MOVE 'MyDatabase_log' TO '$($dataDir)\$($dbName).ldf', REPLACE, RECOVERY"
}

.Parameter server
The name of the SQL server to run scripts against.

.Parameter database
The name of the database to run scripts against.

.Parameter scriptsDir
Path to the directory containing Roundhouse migration scripts to run. Should be a subdirectory of your build's drop location.

.Parameter restorePath
Optional. Path to a .mdf file (backup) of a database file to restore. Until you have a database in production don't specify this property in your build. Once you have a database in production, if you specify the path to your latest production backup file, this be restored prior to running migration scripts. This allows you to test the changes exactly as they would be applied were the current build released to production.

.Parameter restoreOptions
Optional. A string of options to pass to the RESTORE T-SQL statement performed. Use this to specify for instance the .sql and .log file paths that should be used instead of the ones contained within the backup file.
#>
function Invoke-Roundhouse {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $server, 
        [Parameter(Position=1,Mandatory=1)][string] $database, 
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
		
		Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "Roundhouse: $scriptsDir -> $database ($server)"
	}
}