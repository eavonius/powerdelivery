function InvokePowerDeliveryModuleHook($blockName, $stage) {
	$global:g_powerdelivery_delivery_modules | ForEach-Object {
		$moduleName = $_
		$functionName = "Invoke-$($moduleName)DeliveryModule$stage$blockName"
		if (Get-Command $functionName -ErrorAction SilentlyContinue) {
			& $functionName
			return $true
		}
	}
	return $false
}

function InvokePowerDeliveryBuildAction($condition, $stage, $description, $status, $blockName) {
	if ($condition) {
		$actionPerformed = $false
		
		Write-Host
		"$status..."
    	Write-ConsoleSpacer
    	Write-Host
		
		try {
			if (InvokePowerDeliveryModuleHook $blockName 'Pre') {
				$actionPerformed = $true
			}
		    if ($stage) {
	        	& $stage
				$actionPerformed = $true
			}			
			if (InvokePowerDeliveryModuleHook $blockName 'Post') {
				$actionPerformed = $true
			}
			
			$message = "No actions performed."
			
			if ($actionPerformed) {
				$message = "Successful."
			}

			if ($blockName -ne 'Init') {
				Write-BuildSummaryMessage -name $blockName -header $description -message $message
			}
		}
		finally {
		   	Set-Location $powerdelivery.currentLocation
		}
	}
}

function Init {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.init = $action
}

function Compile {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.compile = $action
}

function Deploy {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.deploy = $action
}

function SetupEnvironment {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.setupEnvironment = $action
}

function TestEnvironment {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testEnvironment = $action
}

function TestUnits {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testUnits = $action
}

function TestAcceptance {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testAcceptance = $action
}

function TestCapacity {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testCapacity = $action
}

function Pipeline {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=1)][string] $scriptName,
		[Parameter(Mandatory=1)][string] $version
	)
	
	$powerdelivery.pipeline = $this
	$powerdelivery.scriptName = $scriptName

	$buildAppVersion = "$appVersion"
	
    if ($environment -ne 'local') {
	    $changeSetNumber = $powerdelivery.changeSet.Substring(1)
	    $buildAppVersion = "$version." + $changeSetNumber
    }
	else {
		$buildAppVersion = $version
	}

    $powerdelivery.buildAppVersion = $buildAppVersion
}

function Invoke-Powerdelivery {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $buildScript,
        [Parameter(Position=1,Mandatory=0)][switch] $onServer = $false,
	    [Parameter(Position=2,Mandatory=0)][string] $dropLocation,
	    [Parameter(Position=3,Mandatory=0)][string] $changeSet,
	    [Parameter(Position=4,Mandatory=0)][string] $requestedBy,
	    [Parameter(Position=5,Mandatory=0)][string] $teamProject,
	    [Parameter(Position=6,Mandatory=0)][string] $workspaceName,
	    [Parameter(Position=7,Mandatory=0)][string] $environment = 'Local',
        [Parameter(Position=8,Mandatory=0)][string] $buildUri,
        [Parameter(Position=9,Mandatory=0)][string] $collectionUri,
	    [Parameter(Position=10,Mandatory=0)][string] $priorBuild
    )
	
	$ErrorActionPreference = 'Stop'

    if (!$dropLocation.EndsWith('\')) {
	    $dropLocation = "$($dropLocation)\"
    }

    $powerdelivery.assemblyInfoFiles = @()
    $powerdelivery.currentLocation = gl
    $powerdelivery.noReleases = $true
    $powerdelivery.envConfig = @()
    $powerdelivery.environment = $environment
    $powerdelivery.dropLocation = $dropLocation
    $powerdelivery.changeSet = $changeSet
    $powerdelivery.requestedBy = $requestedBy
    $powerdelivery.teamProject = $teamProject
    $powerdelivery.workspaceName = $workspaceName
    $powerdelivery.collectionUri = $collectionUri
    $powerdelivery.buildUri = $buildUri
    $powerdelivery.onServer = $onServer
    $powerdelivery.buildNumber = $null
    $powerdelivery.buildName = $null
	$powerdelivery.priorBuild = $priorBuild

    Write-Host
    "powerdelivery - https://github.com/eavonius/powerdelivery"
	Write-Host
	$appScript = [System.IO.Path]::GetFileNameWithoutExtension($buildScript)

    try {
		if ($onServer -eq $true) {

		    Require-NonNullField -variable $changeSet -errorMsg "-changeSet parameter is required when running on TFS"
		    Require-NonNullField -variable $requestedBy -errorMsg "-requestedBy parameter is required when running on TFS"
		    Require-NonNullField -variable $teamProject -errorMsg "-teamProject parameter is required when running on TFS"
		    Require-NonNullField -variable $workspaceName -errorMsg "-workspaceName parameter is required when running on TFS"
		    Require-NonNullField -variable $environment -errorMsg "-environment parameter is required when running on TFS"
            Require-NonNullField -variable $collectionUri -errorMsg "-collectionUri parameter is required when running on TFS"
            Require-NonNullField -variable $buildUri -errorMsg "-buildUri parameter is required when running on TFS"
            Require-NonNullField -variable $dropLocation -errorMsg "-dropLocation parameter is required when running on TFS"
			
			if ($powerdelivery.environment -ne "Local") {
			
				LoadTFS
				
				$powerdelivery.collection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($collectionUri)
		        $powerdelivery.buildServer = $powerdelivery.collection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
		        $powerdelivery.structure = $powerdelivery.collection.GetService([Microsoft.TeamFoundation.Server.ICommonStructureService])
				
				$buildServerVersion = $powerdelivery.buildServer.BuildServerVersion
				
				if ($buildServerVersion -eq 'v3') {
					$powerdelivery.tfsVersion = '2010'
				}
				elseif ($buildServerVersion -eq 'v4') {
					$powerdelivery.tfsVersion = '2012'
				}
				else {
					throw "TFS server must be version 2010 or 2012, a different version was detected."
				}

		        $powerdelivery.projectInfo = $powerdelivery.structure.GetProjectFromName($teamProject)
		        if (!$powerdelivery.projectInfo) {
		            Write-Error "Project '$teamProject' not found in TFS collection '$collectionUri'"
		            exit
		        }
				
				$powerdelivery.groupSecurity = $powerdelivery.collection.GetService([Microsoft.TeamFoundation.Server.IGroupSecurityService])
		        $powerdelivery.appGroups = $powerdelivery.groupSecurity.ListApplicationGroups($powerdelivery.projectInfo.Uri)
			}
	    }
	    else {
		    $powerdelivery.requestedBy = whoami
			$currentDirectory = Get-Location
			$powerdelivery.dropLocation = [System.IO.Path]::Combine($currentDirectory, "$($appScript)BuildDrop")
			mkdir $powerdelivery.dropLocation -Force | Out-Null
	    }
		
		$envConfigFileName = $appScript + $environment + "Environment.csv"

	    if (Test-Path -Path $envConfigFileName) {
		    $powerdelivery.envConfig = Import-Csv $envConfigFileName	
	    }
	    else {
		    throw "Build configuration file $envConfigFileName not found."
	    }
		
		Invoke-Expression -Command ".\$appScript"
		
		Write-Host
	    "Application"
	    Write-ConsoleSpacer

	    $appProperties = @{"App Name" = $appScript; "App Version" = $powerdelivery.buildAppVersion}

	    Format-Table -InputObject $appProperties -AutoSize -HideTableHeaders

	    "Parameters"
	    Write-ConsoleSpacer

	    $scriptParams = @{}

	    $scriptParams["Requested By"] = $powerdelivery.requestedBy
	    $scriptParams["Environment"] = $powerdelivery.environment
		
		if ($onServer) {
	        $scriptParams["Team Collection"] = $powerdelivery.collectionUri
	        $scriptParams["Team Project"] = $powerdelivery.teamProject
	        $scriptParams["Change Set"] = $powerdelivery.changeSet
	    
	        $buildNameSegments = $powerdelivery.dropLocation.split('\') | where {$_}
	        $buildNameIndex = $buildNameSegments.length - 1
	        $buildName = $buildNameSegments[$buildNameIndex]
	        $powerdelivery.buildName = $buildName
	        $scriptParams["Build Name"] = $powerdelivery.buildName

	        $buildNumber = $powerdelivery.buildUri.Substring($buildUri.LastIndexOf("/") + 1)
	        $powerdelivery.buildNumber = $buildNumber
	        $scriptParams["Build Number"] = $buildNumber
	    
	        if ($powerdelivery.environment -ne "Local" -and $powerdelivery.environment -ne "Commit") {
	            $scriptParams["Prior Build"] = $powerdelivery.priorBuild
	        }

            Write-BuildSummaryMessage -name "Application" -header "Release" -message "Version: $($powerdelivery.buildAppVersion)`nEnvironment: $($powerdelivery.environment)`nBuild: $($powerdelivery.buildNumber)"
	    }
		
		$scriptParams["Drop Location"] = $powerdelivery.dropLocation
		
		$tableFormat = @{Expression={$_.Key};Label="Key";Width=50}, `
	                   @{Expression={$_.Value};Label="Value";Width=75}

	    $scriptParams | Format-Table $tableFormat -HideTableHeaders

	    $vsInstallDir = Get-ItemProperty -Path Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\10.0_Config -Name InstallDir
	    if ([string]::IsNullOrWhiteSpace($vsInstallDir)) {
	        throw "No version of Visual Studio with the same tools as your version of TFS is installed on the build server."
	    }
	    else {
	        $ENV:Path += ";$($vsInstallDir.InstallDir)"
	    }

	    $tableFormat = @{Expression={$_.Name};Label="Name";Width=50}, `
	                   @{Expression={if ($_.Name.EndsWith("Password")) { '********' } else { $_.Value }};Label="Value";Width=75}

	    "Environment"
	    Write-ConsoleSpacer
        
        $powerdelivery.envConfig | Format-Table $tableFormat -HideTableHeaders
      
        $envMessage = @()
        $powerdelivery.envConfig | ForEach-Object {
            $value = $_.Value
            if ($_.Name.EndsWith("Password")) {
                $value = '********'
            }
            $envMessage += "$($_.Name): $value"
        }

        $envMessage = ($envMessage -join "`n")

        Write-BuildSummaryMessage -name "Environment" -header "Environment Configuration" -message $envMessage 

		"Delivery Modules"
		Write-ConsoleSpacer
		$powerdelivery.deliveryModulesFolder = Join-Path $powerdelivery.currentLocation "$($appScript)DeliveryModules"

		$global:g_powerdelivery_delivery_modules | Format-Table $tableFormat -HideTableHeaders

		if ($powerdelivery.environment -ne "Commit" -and $powerdelivery.onServer -eq $true) {

			$groupName = "$appScript $environment Builders"

			$buildGroup = $null
			$permitted = $false
			
			$sidSearchFactor = [Microsoft.TeamFoundation.Server.SearchFactor]::Sid
			$accountNameSearchFactor = [Microsoft.TeamFoundation.Server.SearchFactor]::AccountName
			$expandedQueryMembership = [Microsoft.TeamFoundation.Server.QueryMembership]::Expanded
			
			$requestingIdentity = $powerdelivery.groupSecurity.ReadIdentity($accountNameSearchFactor, $powerdelivery.requestedBy, $expandedQueryMembership)
			
			$powerdelivery.appGroups | ForEach-Object {
                if (($_.AccountName.ToLower() -eq $groupName.ToLower()) -and $buildGroup -eq $null) {
					$buildGroup = $_
					$groupMembers = $powerdelivery.groupSecurity.ReadIdentities($sidSearchFactor, $buildGroup.Sid, $expandedQueryMembership)					
					foreach ($member in $groupMembers) {
						foreach ($memberSid in $member.Members) {
							if ($memberSid -eq $requestingIdentity.Sid) {
								$permitted = $true
							}
						}
					}
                }
            }
			
			if (!$buildGroup) {
                throw "TFS Security group '$groupName' not found for project '$teamProject'. This group must exist to verify the user requesting the build is a member."
            }
			
			if (!$permitted) {
				throw "User '$($powerdelivery.requestedBy)' who queued build must be a member of TFS Security group '$groupName' to build targeting the '$environment' environment."
			}
			
	        $powerdelivery.priorBuild = $powerdelivery.buildServer.GetBuild("vstfs:///Build/Build/$priorBuild")
			
			if ($powerdelivery.priorBuild -eq $null) {
				throw "Build to promote '$priorBuild' could not be found. Are you sure you specified the build number of a prior build?"
			}
			
			$priorBuildName = $powerdelivery.priorBuild.BuildDefinition.Name.ToLower()
			
			if (!$priorBuildName.StartsWith($appScript.ToLower())) {
				throw "Prior build '$priorBuildName' is for a different product. Please specify the build number of a prior build for the same product."
			}
			
			if ($environment -eq 'Production') {
				if (!$priorBuildName.EndsWith('- test')) {
					throw "Attempt to target production with a non-test build. Please specify the build number of a prior Test environment build to promote it to production."
				}
			}
			elseif (!$priorBuildName.EndsWith('- commit')) {
				throw "Attempt to promote a non-commit build. Please specify the build number of a prior Commit environment build to promote it into this environment."
			}
		}

		InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.init -description "Initialization" -status "Initializing" -blockName "Init"
	    InvokePowerDeliveryBuildAction -condition ($powerdelivery.environment -eq 'Commit' -or $powerdelivery.environment -eq 'Local') -stage $powerdelivery.compile -description "Compilations" -status "Compiling" -blockName "Compile"
	    InvokePowerDeliveryBuildAction -condition ($powerdelivery.environment -eq 'Commit' -or $powerdelivery.environment -eq 'Local') -stage $powerdelivery.testUnits -description "Unit Tests" -status "Testing Units" -blockName "TestUnits"
		
		$projectCollection = $null
	    $buildServer = $null
	    $structure = $null

	    if ($powerdelivery.environment -ne "Local" -and $powerdelivery.environment -ne "Commit" -and $powerdelivery.onServer) {
	        $priorBuildDrop = $powerdelivery.priorBuild.DropLocation
	        Copy-Item -Path "$priorBuildDrop\*" -Recurse -Destination $powerdelivery.dropLocation
	    }

	    InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.setupEnvironment -description "Environment Changes" -status "Setting Up Environment" -blockName "SetupEnvironment"
	    InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.deploy -description "Deployments" -status "Deploying" -blockName "Deploy"
	    InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.testEnvironment -description "Environment Tests" -status "Testing Environment" -blockName "TestEnvironment"
	    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -stage $powerdelivery.testAcceptance -description "Acceptance Tests" -status "Testing Acceptance" -blockName "TestAcceptance"
	    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -stage $powerdelivery.testCapacity -description "Capacity Tests" -status "Testing Capacity" -blockName "TestCapacity"
        
	    Write-Host "Build succeeded!" -ForegroundColor DarkGreen
    }
    catch {
	    Set-Location $powerdelivery.currentLocation
	    Write-Host "Build Failed!" -ForegroundColor Red
		throw
    }
}