function Publish-SSISProject {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $connectionString,
        [Parameter(Position=2,Mandatory=1)][string] $isPacFile,
        [Parameter(Position=3,Mandatory=1)][string] $projectName,
        [Parameter(Position=4,Mandatory=1)][string] $folderName,
        [Parameter(Position=5,Mandatory=0)] $variables = @{}
    )

    $logPrefix = "Publish-SSISProject:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        "$logPrefix Deploying $isPacFile to SSIS on $curComputerName"

        $dropLocation = Get-BuildDropLocation

        $invokeArgs = @{
            "ComputerName" = $curComputerName;
            "ArgumentList" = @($computerName, $connectionString, $isPacFile, $projectName, $folderName, $dropLocation, $logPrefix);
            "ScriptBlock" = {
                param($computerName, $connectionString, $isPacFile, $projectName, $folderName, $dropLocation, $logPrefix)

                # Load the IntegrationServices Assembly
                [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
                 
                # Store the IntegrationServices Assembly namespace to avoid typing it every time
                $ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"
                 
                # Create a connection to the server
                $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
                 
                # Create the Integration Services object
                $integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection

                $catalog = $integrationServices.Catalogs["SSISDB"]
                if (!$catalog) {
                  Write-Host "Creating new SSISDB Catalog ..."
                  $catalog = New-Object $ISNamespace".Catalog" ($integrationServices, "SSISDB", "SUPER#secret1")
                  $catalog.Create()
                }
                
                $folder = $catalog.Folders[$folderName]
                if (!$folder) {
                  Write-Host "Creating SSIS Folder " $folderName " ..."
                  $folder = New-Object $ISNamespace".CatalogFolder" ($catalog, $folderName, "Folder description")
                  $folder.Create()
                }

                $isPacFullPath = Join-Path $dropLocation $isPacFile
                 
                Write-Host "Deploying " $projectName " SSIS project ..."
                 
                # Read the project file, and deploy it to the folder
                [byte[]] $projectFile = [System.IO.File]::ReadAllBytes($isPacFullPath)
                $folder.DeployProject($projectName, $projectFile)
                
                $environment = $folder.Environments[$powerdelivery.environment]
                if (!$environment)  {
                  Write-Host "Creating environment ..."
                  $environment = New-Object $ISNamespace".EnvironmentInfo" ($folder, $powerdelivery.environment, "Description")
                  $environment.Create()            
                }
                 
                Write-Host "Adding server variables ..."
                 
                # Adding variable to our environment
                # Constructor args: variable name, type, default value, sensitivity, description

                if ($variables.length -gt 0) {
                    $variables.Keys | % {
                      if ($environment.Variables.Contains($_)) {
                        $environment.Variables[$_].Value = $variables.Item($_)
                      }
                      else {
                        $environment.Variables.Add($_, [System.TypeCode]::String, $variables.Item($_), "false", $_)
                      }
                    }

                    $environment.Alter()
                }
 
                Write-Host "Adding environment reference to project ..."
                 
                # making project refer to this environment
                $project = $folder.Projects[$projectName]
                if ($project.References.Contains($powerdelivery.environment, $folder.Name) -eq $false) {
                  $project.References.Add($powerdelivery.environment, $folder.Name)
                  $project.Alter() 
                }
            };
            "ErrorAction" = "Stop"
        }

        if ($curComputerName -eq 'localhost') {
          $invokeArgs.Remove("ComputerName")
        }

        Invoke-Command @invokeArgs

        Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "SSIS Project: $isPacFile -> $curComputerName"
    }
}