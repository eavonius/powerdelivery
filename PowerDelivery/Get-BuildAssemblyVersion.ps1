<#
.Synopsis
Gets the assembly build version.

.Description
Returns the version of the application. Should be used to version assemblies so they match the build version.

.Outputs
The version of the application as specified when declaring the Pipeline at the top of your delivery pipeline script.

.Example
$assemblyVersion = Get-BuildAssemblyVersion
#>
function Get-BuildAssemblyVersion {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildAssemblyVersion;
}