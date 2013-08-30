<#
.Synopsis
Runs unit tests using mstest.exe.

.Description
The Invoke-MSTest cmdlet is used to run unit or acceptance tests using mstest.exe. You should always use this cmdlet instead of a direct call to mstest.exe or existing cmdlets you may have found online when working with powerdelivery.

This cmdlet reports the results of the test run back to TFS to be viewed in the build summary.

IMPORTANT: You most only call Invoke-MSTest in the TestUnits or TestAcceptance blocks.

.Example
Invoke-MSTest -file MyTests.dll -results MyTestResults.trx -category AllTests

.Parameter file
string - The path to a file containing MSTest unit tests

.Parameter results
string - A path relative to the drop location (retrieved via Get-BuildDropLocation) of a test run results file (.trx) to store results in.

.Parameter category
string - Runs tests found in the file referenced by the file parameter on any classes found with the [TestCategory] attribute present set to this value.

.Parameter computerName
string - Optional. A remote computer on which to run the tests.

.Parameter platform
string - Optional. The platform configuration (x86, x64 etc.) of the project compiled using Invoke-MSBuild containing the tests that were run. The default is "AnyCPU".

.Parameter buildConfiguration
string - Optional. The default is to use the Release configuration.
#>
function Invoke-MSTest {
    [CmdletBinding()]
    param(
		[Parameter(Position=0,Mandatory=1)][string] $file,
		[Parameter(Position=1,Mandatory=1)][string] $results,
		[Parameter(Position=2,Mandatory=1)][string] $category,
        [Parameter(Position=5,Mandatory=0)][string] $testSettings,
        [Parameter(Position=5,Mandatory=0)][string] $platform = 'AnyCPU',
		[Parameter(Position=6,Mandatory=0)][string] $buildConfiguration
    )
	
	Set-Location $powerdelivery.deployDir

    $logPrefix = "Invoke-MSTest:"
	
	$environment = Get-BuildEnvironment
	$dropLocation = Get-BuildDropLocation
	$currentDirectory = Get-Location

    $localResults = Join-Path $currentDirectory $results
	
	$fileName = [System.IO.Path]::GetFileName($file)
	$testsDir = [System.IO.Path]::GetDirectoryName($file)

	if ([String]::IsNullOrWhiteSpace($buildConfiguration)) {
		if ($environment -eq 'Local') {
			$buildConfiguration = 'Debug'
		}
		else {
			$buildConfiguration = 'Release'
		}
	}

    $localTestsDir = Join-Path $currentDirectory $testsDir
    $dropTestsDir = "$($dropLocation)$testsDir"

	$dropResults = "$dropLocation\$results"

    try {
        $localTestSettings = $null
        if (![String]::IsNullOrWhiteSpace($testSettings)) {
            $dropTestSettings = Join-Path $dropLocation $testSettings
            if (!(Test-Path $dropTestSettings -PathType Leaf)) {
                throw "Couldn't find test settings file $testSettings"
            }

            $localTestSettings = Join-Path $currentDirectory $testSettings
            copy -Force $dropTestSettings $localTestSettings | Out-Null
        }
            
		$filePath = $file

		$localResults = Join-Path $currentDirectory $results

		rm -ErrorAction SilentlyContinue -Force $localResults | Out-Null
	
		Exec -errorMessage "Error running tests in $filePath" {
            $command = "mstest /testcontainer:`"$filePath`" /category:`"$category`" /resultsfile:`"$localResults`" /usestderr /nologo"
            if ($localTestSettings -ne $null) {
                $command += " /testsettings:`"$($testSettings)`""
            }

            Write-Host "$logPrefix $command"
            Invoke-Expression $command
            Write-Host
		}
	}
	finally {
		
        if ($powerdelivery.onServer) {
	
		    if (Test-Path $localResults -PathType Leaf) {

                copy $localResults $dropResults | Out-Null

                # Publish acceptance test results for this build to the TFS server
                Exec -errorMessage "Error publishing test results for $dropResults" {

                    $command = "mstest /publish:`"$(Get-BuildCollectionUri)`" /teamproject:`"$(Get-BuildTeamProject)`" /publishbuild:`"$(Get-BuildName)`" /publishresultsfile:`"$dropResults`" /flavor:$buildConfiguration /platform:$platform /nologo"
                    Write-Host "$logPrefix $command"
                    Invoke-Expression "$command"
                }
			
			    Write-BuildSummaryMessage -name "TestUnits" -header "Unit Tests" -message "MSTest: $file -> $results"
            }
        }
	}
}