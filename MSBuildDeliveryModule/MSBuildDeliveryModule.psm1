function Invoke-MSBuildDeliveryModulePreCompile {

	$modulesFolder = Get-BuildDeliveryModulesFolder
	$projectsFile = Join-Path $modulesFolder "MSBuild.csv"
	
	if (Test-Path $projectsFile) {
		Import-Csv $projectsFile | ForEach-Object {
			$invokeArgs = @{}
			
			if ($_.ProjectFile) {
				$invokeArgs.Add('projectFile', $_.ProjectFile)
			}
			
			if ($_.Target) {
				$invokeArgs.Add('target', $_.Target)
			}
			
			if ($_.Target) {
				$invokeArgs.Add('target', $_.Target)
			}
			
			if ($_.ToolsVersion) {
				$invokeArgs.Add('verbosity', $_.Verbosity)
			}
			
			if ($_.BuildConfig) {
				$invokeArgs.Add('target', $_.Target)
			}
			
			if ($_.Properties) {
				$properties = ConvertFrom-StringData $_.Properties
				$invokeArgs.Add('properties', $properties)
			}
			
			& Invoke-MSBuild @invokeArgs
		}
	}
}