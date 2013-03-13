function Write-BuildSummaryMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $name, 
        [Parameter(Mandatory=1)][string] $header, 
        [Parameter(Mandatory=1)][string] $message
    )
    
    # TODO: Check for TFS 2012 and allow
    if ($false) {
        $buildDetail = Get-CurrentBuildDetail

        $buildSummaryMessage = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddCustomSummaryInformation(`
            $buildDetail.Information, $message, $name, $header, 0)

        $buildSummaryMessage.Save()

        $buildDetail.Information.Save()
    }
}