function Initialize-MSBuildDeliveryModule {

	Register-DeliveryModuleHook 'PreCompile' {
	
		$moduleConfig = Get-BuildModuleConfig
		$msBuildProjects = $moduleConfig.MSBuild

		if ($msBuildProjects) {
			$msBuildProjects.Keys | % {
				$invokeArgs = @{}
				
				$project = $msBuildProjects[$_]
				
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
					$invokeArgs.Add('toolsVersion', $project.ToolsVersion)
				}
				if ($project.Verbosity) {
					$invokeArgs.Add('verbosity', $project.Verbosity)
				}				
				if ($project.Flavor) {
					$invokeArgs.Add('flavor', $project.Flavor)
				}
				if ($project.IgnoreProjectExtensions) {
					$invokeArgs.Add('ignoreProjectExtensions', $project.IgnoreProjectExtensions)
				}
				if ($project.DotNetVersion) {
					$invokeArgs.Add('dotNetVersion', $project.DotNetVersion)
				}
				if ($project.Properties) {
					$invokeArgs.Add('properties', $project.Properties)
				}
				& Invoke-MSBuild @invokeArgs
			}
		}
	}
}