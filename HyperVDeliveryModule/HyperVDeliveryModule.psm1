function Initialize-HyperVDeliveryModule {
	<#
	Register-DeliveryModuleHook 'PreSetupEnvironment' {

		$modulesFolder = Get-BuildDeliveryModulesFolder
		$projectsFile = Join-Path $modulesFolder "HyperV.csv"
		
		if (Test-Path $hyperVFile) {
			Import-Csv $hyperVFile | ForEach-Object {
				$invokeArgs = @{}
				
				$vmComputer = "localhost"
				$vmName = "PowerDeliveryASPNETMVC4_Dev"
				$vmMemory = "1073741824" # 1gb
				$vmSize = "21474836480" #20gb
				$vmNewVHDPath = "D:\VMs\Hyper-V\PowerDeliveryASPNETMVC4_Dev\Virtual Hard Disks\PowerDeliveryASPNETMVC4_Dev.vhdx"
				$vmRootPath = "D:\VMs\Hyper-V"
				
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
				
				
				$vm = Get-VM -Name $vmName -ErrorAction Ignore
				if ($vm) {
					"Found existing virtual Machine $vmName."
				}
				else {
					"Creating virtual machine $vmName..."
					$vm = New-VM -ComputerName $vmComputer -Name $vmName `
						   -MemoryStartupBytes $vmMemory -NewVHDSizeBytes $vmSize `
						   -NewVHDPath $vmVHDPath -Path $vmPath
				}
				
			}
		}
	}#>
}