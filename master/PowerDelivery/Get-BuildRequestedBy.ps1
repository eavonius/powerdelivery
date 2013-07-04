<#
.Synopsis
Gets the account name of the user who requested the build.

.Description
Gets the account name of the user who requested the build.

.Outputs
The account name of the user who requested the build.

.Example
$requestedBy = Get-BuildRequestedBy
#>
function Get-BuildRequestedBy {
    [CmdletBinding()]
    param()
    return $powerdelivery.requestedBy
}