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
	
	[Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

	Write-Host
    "Starting SQL jobs with pattern $jobs on $serverName"
	Write-Host

    $dataMartServer = New-Object Microsoft.SqlServer.Management.SMO.Server("$serverName")
    $dataMartJobs = $dataMartServer.jobserver.jobs | where-object {$_.name -like "$jobs"}
	
    foreach ($dataMartJob in $dataMartJobs)	{	
        $jobName = $dataMartJob.Name
		$dataMartJob.Start()
        "Job '$jobName' started."
    }
}