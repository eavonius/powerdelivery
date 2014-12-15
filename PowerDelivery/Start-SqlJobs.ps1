<#
.Synopsis
Starts SQL jobs on a Microsoft SQL database server

.Description
Starts SQL jobs on a Microsoft SQL database server. You can start a set of jobs that matches a wildcard.

.Parameter serverName
The SQL server instance on which the jobs will be started.

.Parameter jobs
The jobs to start. Can be a single job name, or a name with wildcards.

.Parameter noWait
Whether to skip waiting for the job to finish. Defaults to false.

.Example
Start-SqlJobs -serverName localhost -jobs MyJobs*
#>
function Start-SqlJobs {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $serverName, 
        [Parameter(Position=1,Mandatory=1)][string] $jobs,
        [Parameter(Position=2,Mandatory=0)][switch] $noWait
    )

    $logPrefix = "Start-SqlJobs:"
    
    [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

    Write-Host "$logPrefix Starting SQL jobs with pattern $jobs on $serverName"

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
    
    foreach ($dataMartJob in $dataMartJobs) {   
        $jobName = $dataMartJob.Name
        $dataMartJob.Start()
        Write-Host "$logPrefix SQL Job '$jobName' started"

        $jobRunning = $true

        do {
            $startResult = invoke-sqlcmd -ServerInstance $serverName -database msdb -query "sp_help_jobactivity @job_id = NULL, @job_name = '$jobName'"

            if ($startResult.run_status -eq 3) {
                throw "$logPrefix SQL Job '$jobName' was canceled"
            }

            if ($startResult.run_status -eq 0) {
                throw "$logPrefix SQL Job '$jobName' failed"
            }

            if ($startResult.run_status -eq 1) {
                $jobRunning = $false
                Write-Host "$logPrefix SQL Job '$jobName' completed successfully."
            }
            elseif ($noWait -eq $false) {
                Write-Host "$logPrefix Waiting for SQL job $jobName to finish..."
                sleep 15
            }
            else {
                Write-Host "$logPrefix SQL Job '$jobName' started, not waiting for it to complete."
                $jobRunning = $false
            }
        }
        while ($jobRunning)
    }

    if ($dataMartJobs -eq $null -or $dataMartJobs.length -eq 0) {
        throw "$logPrefix Unable to find SQL Jobs to start matching pattern '$jobs'."
    }

    Write-BuildSummaryMessage -name "Service" -header "Services" -message "Microsoft SQL Job: $jobs ($serverName)"
}