<#
.Synopsis
Gets the number of the currently executing build.

.Description
Gets the number of the currently executing build. This value 
must be used to call some TFS APIs.

.Outputs
The number of the currently executing build.

.Example
$number = Get-BuildNumber
#>
function Get-BuildNumber {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildNumber
}