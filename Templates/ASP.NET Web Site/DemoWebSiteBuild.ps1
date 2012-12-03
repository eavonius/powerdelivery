Param (
	[Switch] $onServer,
	[Parameter()]
	[ValidateNotNullOrEmpty()] 
	[String]
	$dropLocation,
	[Parameter()]
	[String]
	$changeSet,
	[Parameter()]
	[String]
	$requestedBy,
	[Parameter()]
	[String]
	$teamProject,
	[Parameter()]
	[String]
	$workspaceName,
	[String]
	$environment
)

$appName = "powerdelivery ASP.NET Website"
$appVersion = "1.0.0"

$webSiteSource = "ASPNETWebSite"
$webSiteSolution = "$webSiteSource\ASPNETWebSite.sln"

function AddTargets() {

    Add-AssemblyInfo -path $webSiteSource
    
    Add-MSBuildTarget -project $webSiteSolution

    Add-Database -connection (Get-BuildSetting "ConnectionString") 
                 -database (Get-BuildSetting "DatabaseName")
    
    Add-WebSite -server $webServer
}

#function Compile() {
#	Update-AssemblyInfoFiles -path $webSiteSource
#    Compile-MSBuild -project $webSiteSolution
#}

function SetupEnvironment() {

    SetXmlValue -file "$webSiteSource\Web.config" `
                -path "system\connectionStrings\add[@name='ASPNetDatabase']\@value" `
                -value $connectionString
}

#function TestEnvironment() {
#    Ping-Database $connectionString
#    Ping-Webserver $webServer
#}

#function Deploy() {
#    Deploy-MSBuild -project $webSiteSolution
#    Migrate-Database -connectionString $connectionString
#}

#function TestAcceptance() {
#    Run-MSTest -vsmdi "$webSiteSource\ASPNETWebSiteTests.vsmdi"
#}

. '.\PowerShellModules\ContinuousDelivery.ps1'