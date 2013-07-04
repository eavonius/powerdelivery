<#
.Synopsis
Gets the name of the TFS project the build is delivering assets for.

.Description
Gets the name of the TFS project the build is delivering assets for.

.Outputs
The name of the TFS project the build is delivering assets for.

.Example
$teamProject = Get-BuildTeamProject
#>
function Get-BuildTeamProject {
    [CmdletBinding()]
    param()
    return $powerdelivery.teamProject
}