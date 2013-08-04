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
		[Parameter(Position=3,Mandatory=0)][string] $computerName,
        [Parameter(Position=4,Mandatory=0)] $credentials,
        [Parameter(Position=5,Mandatory=0)][string] $platform = 'AnyCPU',
		[Parameter(Position=6,Mandatory=0)][string] $buildConfiguration
    )

    $logPrefix = "Invoke-MSTest:"

	$isRemote = $false
	$shareTestsPath = ""
	
	$environment = Get-BuildEnvironment
	$dropLocation = Get-BuildDropLocation
	$currentDirectory = Get-Location

    $localResults = Join-Path $currentDirectory $results
	
	$fileName = [System.IO.Path]::GetFileName($file)
	$testsDir = [System.IO.Path]::GetDirectoryName($file)

	if (![String]::IsNullOrWhiteSpace($computerName)) {
		$isRemote = $true;

        if ($credentials -eq $null) {
            throw "Credentials are required when running tests on another computer."
        }
	}

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

    "$logPrefix Copying $dropTestsDir\* to $localTestsDir"
    copy -Force -Recurse "$dropTestsDir\*" $localTestsDir | Out-Null

	if ($isRemote) {
        $remoteDeployPath = Get-ComputerRemoteDeployPath $computerName

        Write-Host "$logPrefix Remote Deploy Path: $remoteDeployPath"
        Write-Host "$logPrefix Tests Dir: $testsDir"

		$shareTestsPath = "$($remoteDeployPath)\$($testsDir)"
        mkdir -force $shareTestsPath | Out-Null

        "$logPrefix Copying $localTestsDir\* to $shareTestsPath"
		copy -Force -Recurse -Path "$localTestsDir\*" $shareTestsPath | Out-Null
	}
    
	$dropResults = "$dropLocation\$results"

    try {
        if ($isRemote) {
            $localDeployPath = Get-ComputerLocalDeployPath $computerName

            Invoke-Command -ComputerName $computerName -Credential $credentials {
                $workingDirectory = $using:localDeployPath
		        $filePath = $using:file

                $shareResults = Join-Path $workingDirectory $using:results

		        rm -ErrorAction SilentlyContinue -Force $shareResults | Out-Null
	
                Set-Location $using:localDeployPath

                $command = "mstest /testcontainer:`"$filePath`" /category:`"$using:category`" /resultsfile:`"$shareResults`" /usestderr /nologo"
                "$logPrefix $command"
                Invoke-Expression $command
		
		        if ($LASTEXITCODE -ne 0) {
			        throw "Error running tests in $filePath"
		        }
            }
        }
        else {
            $workingDirectory = Get-Location
		    $filePath = $file

		    $localResults = Join-Path $workingDirectory $results

		    rm -ErrorAction SilentlyContinue -Force $localResults | Out-Null
	
		    Exec -errorMessage "Error running tests in $filePath" {
                $command = "mstest /testcontainer:`"$filePath`" /category:`"$category`" /resultsfile:`"$localResults`" /usestderr /nologo"    			    
                Write-Host "$logPrefix $command"
                Invoke-Expression $command
		    }
        }
	}
	finally {
		
        if ($powerdelivery.onServer) {
		 
           if ($isRemote) {
			    $remoteResults = Join-Path $shareTestsPath $results
			    if (Test-Path $remoteResults -PathType Leaf) {
				    copy -Force $remoteResults $localResults | Out-Null
			    }
		    }
	
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