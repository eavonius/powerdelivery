<#
.Synopsis
Gets the name of the currently executing build.

.Description
Gets the name of the currently executing build. This value will 
match the name of the build as viewed in TFS and must be used to 
call some TFS APIs.

.Outputs
The name of the currently executing build.

.Example
$name = Get-BuildName
#>
function Get-BuildName {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildName
}