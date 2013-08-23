<#
.Synopsis
Disables SQL jobs on a Microsoft SQL database server

.Description
Disables SQL jobs on a Microsoft SQL database server. You can disable a set of jobs that matches a wildcard. 
If any of the jobs matching a wildcard are already running, the previously disabled jobs that match the same 
wildcard will be restarted and an error will occur. This is to make sure all the jobs disable successfully 
together.

.Parameter serverName
The SQL server instance on which the jobs will be disabled.

.Parameter jobs
The jobs to disable. Can be a single job name, or a name with wildcards.

.Example
Disable-SqlJobs -serverName localhost -jobs MyJobs*
#>
function Disable-SqlJobs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $serverName, 
        [Parameter(Mandatory=1)][string] $jobs
    )

    $logPrefix = "Disable-SqlJobs:"

	[Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

    "$logPrefix Disabling SQL jobs with pattern $jobs on $serverName"

    $dataMartServer = New-Object Microsoft.SqlServer.Management.SMO.Server("$serverName")
    $dataMartJobs = $dataMartServer.jobserver.jobs | where-object {$_.Isenabled -eq $true -and  $_.name -like "$jobs"}

    $jobRunning = $false
    $jobName = ''

    foreach ($dataMartJob in $dataMartJobs)	{	
        $jobName = $dataMartJob.Name
        if ($dataMartJob.CurrentRunStatus.ToString() -ne 'Idle') {
            $jobRunning = $true
            break
        }	
        else {	
            $dataMartJob.IsEnabled = $false
            $dataMartJob.Alter()
            "Job '$jobName' successfully disabled."
        }
    }

    if ($jobRunning) {
        foreach ($dataMartJob in $dataMartJobs)	{	
            $dataMartJob.IsEnabled = $true
            $dataMartJob.Alter()
        }
        throw "Job '$jobName' is still running, stopping build."
    }
}