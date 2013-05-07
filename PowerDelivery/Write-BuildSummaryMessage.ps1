<#
.Synopsis
Writes a message to a section in the TFS build summary page.

.Description
Writes a message to a section in the TFS build summary page. Specify as the "name" parameter 
the name of a block from your delivery script. For example, pass "Compile" to have your message 
appear under that section of the build summary.

NOTE: This function will output a warning and not do anything on TFS versions prior to 2012.

.Parameter name
The name of the section to write the message to.

.Parameter header
The text of the section to display (ignored if any other message was already written to this section).

.Parmater message
The message to add to the section specified.

.Example
Write-BuildSummaryMessage "Compile" "Compilations" "My Message"
#>
function Write-BuildSummaryMessage {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $name, 
        [Parameter(Position=1,Mandatory=1)][string] $header, 
        [Parameter(Position=2,Mandatory=1)][string] $message
    )

    $buildServerVersion = $powerdelivery.buildServer.BuildServerVersion
				
	if ($buildServerVersion -eq 'v3') {
        Write-Debug "WARNING: Write-BuildSummaryMessage does nothing on TFS 2010. Upgrade to 2012 to get summary messages (detected TFS $buildServerVersion)."
	}
	elseif ($buildServerVersion -eq 'v4') {
        $buildDetail = Get-CurrentBuildDetail

        $buildSummaryMessage = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddCustomSummaryInformation(`
            $buildDetail.Information, $message, $name, $header, 0)

        $buildSummaryMessage.Save()

        $buildDetail.Information.Save()
    }
}