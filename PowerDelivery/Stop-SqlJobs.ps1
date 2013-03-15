<#
.Synopsis
Stops SQL jobs on a Microsoft SQL database server

.Description
Stops SQL jobs on a Microsoft SQL database server. You can start a set of jobs that matches a wildcard. 
If any of the jobs matching a wildcard fail to stop, the previously stopped jobs that match the same 
wildcard will be restarted and an error will occur. This is to make sure all the jobs stop successfully 
together.

.Parameter serverName
The SQL server instance on which the jobs will be stopped.

.Parameter jobs
The jobs to stop. Can be a single job name, or a name with wildcards.

.Example
Stop-SqlJobs -serverName localhost -jobs MyJobs*
#>
function Stop-SqlJobs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $serverName, 
        [Parameter(Mandatory=1)][string] $jobs
    )

	[Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

	Write-Host
    "Disabling SQL jobs with pattern $($jobs)* on $serverName"
	Write-Host

    $dataMartServer = New-Object Microsoft.SqlServer.Management.SMO.Server("$serverName")
    $dataMartJobs = $dataMartServer.jobserver.jobs | where-object {$_.Isenabled -eq $true -and  $_.name -like "$($jobs)*"}

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