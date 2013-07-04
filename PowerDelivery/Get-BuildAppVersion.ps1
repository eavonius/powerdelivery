<#
.Synopsis
Gets the application build version.

.Description
Returns the version of the application. Should be used to version assets so they match the build changeset.

.Outputs
The version of the application with the 4th segment being the TFS changeset number.

.Example
$appVersion = Get-BuildAppversion
#>
function Get-BuildAppVersion {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildAppVersion;
}