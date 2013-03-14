function Write-BuildSummaryMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $name, 
        [Parameter(Mandatory=1)][string] $header, 
        [Parameter(Mandatory=1)][string] $message
    )

    $buildServerVersion = $powerdelivery.buildServer.BuildServerVersion
				
	if ($buildServerVersion -eq 'v3') {
        "WARNING: Write-BuildSummaryMessage does nothing on TFS 2010. Upgrade to 2012 to get summary messages (detected TFS $buildServerVersion)."
	}
	elseif ($buildServerVersion -eq 'v4') {
        $buildDetail = Get-CurrentBuildDetail

        $buildSummaryMessage = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddCustomSummaryInformation(`
            $buildDetail.Information, $message, $name, $header, 0)

        $buildSummaryMessage.Save()

        $buildDetail.Information.Save()
    }
}