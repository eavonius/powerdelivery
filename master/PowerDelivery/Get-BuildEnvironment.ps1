<#
.Synopsis
Gets the environment the currently executing build is targeting for deployment.

.Description
Gets the environment the currently executing build is targeting. Should be 
"Local", "Commit", "Test", "CapacityTest", or "Production".

.Outputs
The environment the currently executing build is targeting for deployment.

.Example
$environment = Get-BuildEnvironment
#>
function Get-BuildEnvironment {
    [CmdletBinding()]
    param()
    return $powerdelivery.environment
}