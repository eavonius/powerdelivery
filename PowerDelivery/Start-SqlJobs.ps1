<#
.Synopsis
Starts SQL jobs on a Microsoft SQL database server

.Description
Starts SQL jobs on a Microsoft SQL database server. You can start a set of jobs that matches a wildcard.

.Parameter serverName
The SQL server instance on which the jobs will be started.

.Parameter jobs
The jobs to start. Can be a single job name, or a name with wildcards.

.Example
Start-SqlJobs -serverName localhost -jobs MyJobs*
#>
function Start-SqlJobs {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $serverName, 
        [Parameter(Position=1,Mandatory=1)][string] $jobs
    )

    $logPrefix = "Start-SqlJobs:"
	
	[Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

    "$logPrefix Starting SQL jobs with pattern $jobs on $serverName"

    try {
        Import-Snapin SqlServerCmdletSnapin100 
    }
    catch {
        Import-Snapin SqlServerCmdletSnapin110 
    }

    try {
        Import-Snapin SqlServerProviderSnapin100 
    }
    catch {
        Import-Snapin SqlServerProviderSnapin110 
    }

    $dataMartServer = New-Object Microsoft.SqlServer.Management.SMO.Server("$serverName")
    $dataMartJobs = $dataMartServer.jobserver.jobs | where-object {$_.name -like "$jobs"}
	
    foreach ($dataMartJob in $dataMartJobs)	{	
        $jobName = $dataMartJob.Name
		$dataMartJob.Start()
        "$logPrefix SQL Job '$jobName' started"

        $jobRunning = $true

        do {
            $startResult = invoke-sqlcmd -ServerInstance $serverName -database msdb -query "sp_help_jobactivity @job_id = NULL, @job_name = '$jobName'"

            if ($startResult.run_status -eq 3) {
                throw "SQL Job '$jobName' was canceled"
            }

            if ($startResult.run_status -eq 0) {
                throw "SQL Job '$jobName' failed"
            }

            if ($startResult.run_status -eq 1) {
                $jobRunning = $false
                "$logPrefix SQL Job '$jobName' completed successfully."
            }
            else {
                "$logPrefix Waiting for SQL job $jobName to finish..."
                sleep 15
            }
        }
        while ($jobRunning)
    }

    if ($dataMartJobs -eq $null -or $dataMartJobs.length -eq 0) {
        throw "$logPrefix Unable to find SQL Jobs to start matching pattern '$jobs'."
    }
}