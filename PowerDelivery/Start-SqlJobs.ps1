function Start-SqlJobs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $serverName, 
        [Parameter(Mandatory=1)][string] $jobs
    )
	
	[Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

	Write-Host
    "Enabling SQL jobs with pattern $($jobs)* on $serverName"
	Write-Host

    $dataMartServer = New-Object Microsoft.SqlServer.Management.SMO.Server("$serverName")
    $dataMartJobs = $dataMartServer.jobserver.jobs | where-object {$_.name -like "$($jobs)*"}
    foreach ($dataMartJob in $dataMartJobs)	{	
        $jobName = $dataMartJob.Name
        $dataMartJob.IsEnabled = $true
        $dataMartJob.Alter()
        "Job '$jobName' successfully enabled."
    }
}