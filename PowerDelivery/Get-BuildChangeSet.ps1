<#
.Synopsis
Gets the TFS changeset of the source code being built.

.Description
Returns the changeset of the build.

.Outputs
The changeset of the TFS checkin being built (for example, C45 for changeset 46).

.Example
$changeSet = Get-BuildChangeSet
#>
function Get-BuildChangeSet {
    [CmdletBinding()]
    param()
    return $powerdelivery.changeSet
}