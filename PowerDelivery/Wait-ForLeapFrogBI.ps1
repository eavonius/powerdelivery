function Wait-ForLeapFrogBI {
    param(
        [Parameter(Position=0,Mandatory=1)] $dataMartConnectionString,
        [Parameter(Position=0,Mandatory=1)] $timeoutMinutes
    )

    $logPrefix = "Wait-ForLeapFrogBI:"

    # Poll for completion of LeapFrog processing with a timeout
	#
	$timedOut = $true
	$timeout = New-TimeSpan -Minutes $timeoutMinutes
	$stopWatch = [Diagnostics.StopWatch]::StartNew()
	
	"$logPrefix Polling Precedence table to wait $timeoutMinutes minutes for LeapFrogBI packages to process..."
	
	while ($stopWatch.Elapsed -lt $timeout){
	    
		$sqlConnection = New-Object System.Data.OleDb.OleDbConnection
		$sqlConnection.ConnectionString = $dataMartConnectionString
		
		$sqlConnection.Open()
		
		$precedenceRowsExistCmd = New-Object System.Data.OleDb.OleDbCommand("SELECT * FROM [dbo].[Precedence]", $sqlConnection)
		$precedenceRowsExistReader = $precedenceRowsExistCmd.ExecuteReader()
		
		if ($precedenceRowsExistReader.HasRows) {
		
			$failedPackageCmd = New-Object System.Data.OleDb.OleDbCommand("SELECT * FROM [dbo].[Precedence] WHERE Disable <> 1 AND JobStatus = -1 AND JobTryCount = 4", $sqlConnection)
			$failedPackageReader = $failedPackageCmd.ExecuteReader()
			
			if ($failedPackageReader.HasRows) {
				$sqlConnection.Close()
				throw "At least one LeapFrogBI package failed processing."
			}
			else {
				$runningPackageCmd = New-Object System.Data.OleDb.OleDbCommand("SELECT * FROM [dbo].[Precedence] WHERE Disable <> 1 AND JobStatus <> 3", $sqlConnection)
				$runningPackageReader = $runningPackageCmd.ExecuteReader()
			
				if ($runningPackageReader.HasRows -eq $false) {
					"$logPrefix LeapFrogBI processing is complete."
					$sqlConnection.Close()
					$timedOut = $false
					break
				}
				else {
					"$logPrefix LeapFrogBI packages are still running, checking again in 30 seconds..."
				}
			}
		}
		
		$sqlConnection.Close()
	
	    Start-Sleep -Seconds 30
	}
	
	if ($timedOut) {
		throw "Timed out polling for LeapFrogBI packages to complete. Increase the value of the timeoutMinutes parameter."
	}
}