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

.Parameter sharePath
string - Optional. A share on the remote computer into which the tests will be copied and run from.

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
		[Parameter(Position=3,Mandatory=0)][string] $computerName,
		[Parameter(Position=4,Mandatory=0)][string] $sharePath,
        [Parameter(Position=5,Mandatory=0)][string] $platform = 'AnyCPU',
		[Parameter(Position=6,Mandatory=0)][string] $buildConfiguration
    )
	
	$isRemote = $false
	$shareTestsPath = ""
	
	$environment = Get-BuildEnvironment
	$dropLocation = Get-BuildDropLocation
	$currentDirectory = Get-Location
	
	$fileName = [System.IO.Path]::GetFileName($using:file)
	$testsDir = [System.IO.Path]::GetDirectoryName($file)
	
	if (![String]::IsNullOrWhiteSpace($computerName)) {
		$isRemote = $true;
	}
	
	if ($isRemote -and [String]::IsNullOrWhiteSpace($sharePath)) {
		throw "You must specify a UNC share path to run tests from when executing MSTest on a remote computer."
	}

	if ([String]::IsNullOrWhiteSpace($buildConfiguration)) {
		if ($environment -eq 'Local') {
			$buildConfiguration = 'Debug'
		}
		else {
			$buildConfiguration = 'Release'
		}
	}
	
	if ($isRemote) {
		$shareTestsPath = Join-Path $sharePath $testsDir
		copy -Force -Recurse "$testsDir\*" "$shareTestsPath"
	}

	$dropResults = "$dropLocation\$results"

	$commandArgs = @{'ScriptBlock' = {

		$workingDirectory = Get-Location
		$filePath = $using:file

		if ($using:isRemote) {
			$shareLocalDir = (Get-WmiObject Win32_Share -filter "Name LIKE '$using:sharePath'").path
			$workingDirectory = Join-Path $shareLocalDir $using:testsDir
			$filePath = Join-Path $workingDirectory $using:fileName
		}

		$localResults = "$workingDirectory\$using:results"

		rm -ErrorAction SilentlyContinue -Force $localResults | Out-Null
	
        # Run acceptance tests out of working directory
        Invoke-Expression "mstest /testcontainer:`"$filePath`" /category:`"$using:category`" /resultsfile:`"$localResults`" /usestderr /nologo"
		
		if ($LASTEXITCODE -ne 0) {
			throw "Error running tests in $filePath"
		}
	}}
	
	if ($isRemote) {
		$commandArgs.Add('ComputerName', $computerName)
	}
	
	try {
		Invoke-Command @commandArgs
	}
	finally {
		
		if ($isRemote) {
			$remoteResults = Join-Path $shareTestsPath $results
			if (Test-Path $remoteResults -PathType Leaf) {
				copy -Force $remoteResults $localResults
			}
		}
	
		if ((Test-Path $localResults -PathType Leaf) -and $powerdelivery.onServer) {

            copy $localResults $dropResults

            # Publish acceptance test results for this build to the TFS server
            Exec -errorMessage "Error publishing test results for $dropResults" {
                mstest /publish:"$(Get-BuildCollectionUri)" `
                       /teamproject:"$(Get-BuildTeamProject)" `
                       /publishbuild:"$(Get-BuildName)" `
                       /publishresultsfile:"$dropResults" `
                       /flavor:$buildConfiguration `
                       /platform:$platform `
					   /nologo
            }
			
			Write-BuildSummaryMessage -name "TestUnits" -header "Unit Tests" -message "MSTest: $file -> $results"
        }
	}
}