<#
.Synopsis
Gets the URI the build when running on TFS.

.Description
Gets the URI the build when running on TFS. This URI is required to 
make some calls to the TFS API and should not be necessary for you 
to use for most operations.

.Outputs
The URI of the build when running on TFS.

.Example
$uri = Get-BuildUri
#>
function Get-BuildUri {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildUri
}