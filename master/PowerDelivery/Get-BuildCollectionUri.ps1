<#
.Synopsis
Gets the Uri of the TFS project collection containing the project being built.

.Description
Gets the Uri of the TFS project collection containing the project being built.

.Outputs
The Uri of the TFS project collection containing the project being built.

.Example
$collectionUri = Get-BuildCollectionUri
#>
function Get-BuildCollectionUri {
    [CmdletBinding()]
    param()
    return $powerdelivery.collectionUri
}