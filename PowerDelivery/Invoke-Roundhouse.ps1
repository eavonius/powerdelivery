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

.Parameter scriptsDir
Path to the directory containing Roundhouse migration scripts to run. Should be a subdirectory of your build's drop location.

.Parameter database
The name of the database to run scripts against.

.Parameter server
Optional. The name of the SQL server to run scripts against. Use this or the connectionString parameter.

.Parameter connectionString
Optional. The connection string to the database. Use this or the server parameter.

.Parameter restorePath
Optional. Path to a .mdf file (backup) of a database file to restore. Until you have a database in production don't specify this property in your build. Once you have a database in production, if you specify the path to your latest production backup file, this be restored prior to running migration scripts. This allows you to test the changes exactly as they would be applied were the current build released to production.

.Parameter restoreOptions
Optional. A string of options to pass to the RESTORE T-SQL statement performed. Use this to specify for instance the .sql and .log file paths that should be used instead of the ones contained within the backup file.

.Parameter commandTimeout
Optional. Default is 60. The number of seconds after which the deployment will timeout.

.Parameter databaseType
Optional. Default is 'sqlserver'. The type of database being deployed to.

.Parameter versionFile
Optional. Default is '_BuildInfo.xml'. This file is only needed if using an XML file to manage versions.

.Parameter doNotCreateDatabase
Optional. Default is false. Whether the database should not be created if it doesn't exist.

.Parameter disableOutput
Optional. Default is false. Whether output should not be displayed in the console.

.Parameter withTransaction
Optional. Default is false. Whether deployment should occur within a transaction.

.Parameter recoveryMode
Optional. Default is 'NoChange'. The mode of recovery used if deployment fails.
#>
function Invoke-Roundhouse {
    [CmdletBinding()]
    param(
      [Parameter(Position=0,Mandatory=1)][string] $scriptsDir, 
   	  [Parameter(Position=1,Mandatory=0)][string] $database, 
	  [Parameter(Position=2,Mandatory=0)][string] $server, 
      [Parameter(Position=3,Mandatory=0)][string] $connectionString,
      [Parameter(Position=4,Mandatory=0)][string] $restorePath, 
      [Parameter(Position=5,Mandatory=0)][string] $restoreOptions,
	  [Parameter(Position=6,Mandatory=0)][int] $commandTimeout = 60,
	  [Parameter(Position=7,Mandatory=0)][string] $databaseType = 'sqlserver',
	  [Parameter(Position=8,Mandatory=0)][string] $versionFile = '_BuildInfo.xml',
	  [Parameter(Position=10,Mandatory=0)][switch] $doNotCreateDatabase = $false,
	  [Parameter(Position=11,Mandatory=0)][switch] $disableOutput = $false,
	  [Parameter(Position=10,Mandatory=0)][switch] $withTransaction = $false,
	  [Parameter(Position=10,Mandatory=0)][string] $recoveryMode = 'NoChange'
    )

	Set-Location $powerdelivery.deployDir

    $logPrefix = "Invoke-Roundhouse:"

    $environment = Get-BuildEnvironment
    $dropLocation = Get-BuildDropLocation
    
    $dropScriptsDir = Join-Path $dropLocation $scriptsDir
    $localScriptsDir = Join-Path (gl) $scriptsDir
    $localOutDir = Join-Path $localScriptsDir output
    $dropOutDir = Join-Path $dropScriptsDir output

    $command = "rh --silent --commandtimeout=$commandTimeout --databasetype=`"$databaseType`" --versionfile=`"$versionFile`" --recoverymode=`"$recoveryMode`""
	
	if ($doNotCreateDatabase -eq $true) {
		$command += " --dc"
	}
	
	if ($disableOutput -eq $true) {
		$command += " --disableoutput"
	}
	
	if ($withTransaction -eq $true) {
		$command += " --withtransaction"
	}
	
	if ($debug -eq $true) {
		$command += " --debug"
	}
	
	if (![String]::IsNullOrWhiteSpace($server) -and ![String]::IsNullOrWhiteSpace($database)) {
		$command += " /s=$server /d=`"$database`""
	}
	elseif (![String]::IsNullOrWhiteSpace($connectionString)) {
		$command += " /c=`"$connectionString`""
	}
	else {
		throw "You must specify the server and database, or connectionString parameter."
	}
	
	$command += " /f=""$localScriptsDir"" /env=$environment /o=""$localScriptsDir\output"""
	
    if ($environment -ne 'Production' -and ![String]::IsNullOrWhitespace($restorePath)) {
        $command += " --restore --restorefrompath=`"$restorePath`""
        if (![String]::IsNullOrWhiteSpace($restoreOptions)) {
            $command += " --restorecustomoptions=`"$restoreOptions`""
        }
    }
	
    Write-Host "$logPrefix $command"

	  Exec -ErrorAction Stop { 
	      Invoke-Expression -Command $command	    
	  }

    Copy-Robust $localOutDir $dropOutDir -recurse
		
	if ([String]::IsNullOrWhiteSpace($connectionString)) {
		Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "Roundhouse: $scriptsDir -> $database ($server)"
	}
	else {
		Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "Roundhouse: $scriptsDir -> `"$connectionString`""
	}
}