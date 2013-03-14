<#
.Synopsis
Runs unit tests using mstest.exe.

.Description
The Invoke-MSTest cmdlet is used to run unit or acceptance tests using mstest.exe. You should always use this cmdlet instead of a direct call to mstest.exe or existing cmdlets you may have found online when working with powerdelivery.

This cmdlet provides the following essential continuous delivery features:

Automatically targets a test configuration matching the environment name ("Commit", "Test", or "Production"). Create build configurations named "Commit", "Test", and "Production" with appropriate settings in your projects and compile them using the Invoke-MSBuild cmdlet for this to work.

Reports the results of the test run back to TFS to be viewed in the build summary.

IMPORTANT: You most only call Invoke-MSTest in the TestUnits or TestAcceptance block.

.Example
Invoke-MSTest -list MyTestList -results AcceptanceTests\MyTests.Results.trx -vsmdi AcceptanceTests\MyTests.vsmdi -settings AcceptanceTests\TraceAndTestImpact.testsettings

.Parameter list
The name of a test list in the file specified by the vsmdi parameter. Tests in this list will be run.

.Parameter results
A path relative to the drop location (retrieved via Get-BuildDropLocation) of a test run results file (.trx) to store results in.

.Parameter vsmdi
A path relative to the drop location of the tests metadata (.vsmdi) file to use.

.Parameter settings
A path relative to the drop location of the test settings (.testsettings) file to use.

.Parameter platform
Optional. The platform configuration (x86, x64 etc.) of the project compiled using Invoke-MSBuild containing the tests that were run. The default is "AnyCPU".
#>
function Invoke-MSTest {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $list, 
        [Parameter(Position=1,Mandatory=1)][string] $results, 
		[Parameter(Position=2,Mandatory=1)][string] $vsmdi, 
        [Parameter(Position=3,Mandatory=1)][string] $settings, 
        [Parameter(Position=4,Mandatory=0)][string] $platform = 'AnyCPU'
    )

    $currentDirectory = Get-Location
	$environment = Get-BuildEnvironment
	$dropLocation = Get-BuildDropLocation

	$localResults = "$currentDirectory\$results"
	$dropResults = "$dropLocation\$results"

	try {
        # Run acceptance tests out of local directory
        Exec -errorMessage "Error running tests in list $list using $vsmdi" {
            mstest /testmetadata:"$currentDirectory\$vsmdi" `
                   /testlist:"$list" `
                   /testsettings:"$currentDirectory\$settings" `
                   /resultsfile:"$localResults" `
                   /usestderr /nologo
        }
    }
    finally {
        if ((Test-Path $localResults -PathType Leaf) -and $powerdelivery.onServer) {

            copy $localResults $dropResults

            # Publish acceptance test results for this build to the TFS server
            Exec -errorMessage "Error publishing test results for $dropResults" {
                mstest /publish:"$(Get-CollectionUri)" `
                       /teamproject:"$(Get-BuildTeamProject)" `
                       /publishbuild:"$(Get-BuildName)" `
                       /publishresultsfile:"$dropResults" `
                       /flavor:$environment `
                       /platform:$platform `
					   /nologo
            }
        }
    }
}