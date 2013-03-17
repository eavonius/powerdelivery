function Invoke-MSBuildDeliveryModulePreCompile {

	$modulesFolder = Get-BuildDeliveryModulesFolder
	$projectsFile = Join-Path $modulesFolder "MSBuild.yml"
	
	if (Test-Path $projectsFile) {		
		$projects = Get-Yaml -FromFile $projectsFile
		
		$projects.Keys | ForEach-Object {
			$invokeArgs = @{}
			
			$project = $projects[$_]
			
			if ($project.ProjectFile) {
				$invokeArgs.Add('projectFile', $project.ProjectFile)
			}
			
			if ($project.Target) {
				$invokeArgs.Add('target', $project.Target)
			}
			
			if ($project.BuildConfiguration) {
				$invokeArgs.Add('buildConfiguration', $project.BuildConfiguration)
			}
			
			if ($project.ToolsVersion) {
				$invokeArgs.Add('toolsVersoin', $project.ToolsVersion)
			}
			
			if ($project.Verbosity) {
				$invokeArgs.Add('verbosity', $project.Verbosity)
			}
			
			if ($project.Flavor) {
				$invokeArgs.Add('target', $project.Flavor)
			}
			
			if ($project.IgnoreProjectExtensions) {
				$invokeArgs.Add('target', $project.IgnoreProjectExtensions)
			}
			
			if ($project.DotNetVersion) {
				$invokeArgs.Add('target', $project.DotNetVersion)
			}
			
			if ($project.Properties) {
				$invokeArgs.Add('properties', $project.Properties)
			}
			
			& Invoke-MSBuild @invokeArgs
		}
	}
}