<#
.Synopsis
Gets the name of the TFS source control workspace name used to get a copy of the source code to compile.

.Description
Gets the name of the TFS source control workspace name used to get a copy of the source code to compile.

.Outputs
The name of the TFS source control workspace name used to get a copy of the source code to compile.

.Example
$workspaceName = Get-BuildWorkspaceName
#>
function Get-BuildWorkspaceName {
    [CmdletBinding()]
    param()
    return $powerdelivery.workspaceName
}