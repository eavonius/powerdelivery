<#
.Synopsis
Installs a Windows Service for an NServiceBus version 4+ Enterprise Service Bus host.

.Description
Installs a Windows Service for an NServiceBus version 4+ Enterprise Service Bus host. 
You must have already copied the files necessary to run the host, including a copy 
of NServiceBus.Host.exe to a directory local to that computer prior to calling this 
cmdlet. You should call Uninstall-NServiceBusService prior to this cmdlet, 
otherwise files will be in use.

.Parameter ComputerName
The name of the remote computer to install the service on.

.Parameter Name
The name of the service. This can be used to start/stop the service with the "net" command.

.Parameter DisplayName
The name that appears in the services control panel applet.

.Parameter Description
The description that appears in the services control panel applet.

.Parameter Directory
A local path on the computer specified by the ComputerName parameter containing the service.

.Parameter AccountName
The user account under which the service will be configured to run. This account must already 
exist on the computer specified by the ComputerName parameter.

.Parameter AccountPassword
The password under which the service will be configured to run.

.Example
Install-NServiceBusService `
	-ComputerName MyComputer `
	-Name MyService `
	-DisplayName "My Service" `
	-Description "Does something wonderful" `
	-Directory "C:\Share\MyService" `
	-AccountName "MYDOMAIN\myuser" `
	-AccountPassword "somep@ssword12"
#>
function Install-NServiceBusService {
	param(
		[Parameter(Position=0,Mandatory=1)] $ComputerName,
		[Parameter(Position=1,Mandatory=1)] $Name,
		[Parameter(Position=2,Mandatory=1)] $DisplayName,
		[Parameter(Position=3,Mandatory=1)] $Description,
		[Parameter(Position=4,Mandatory=1)] $Directory,
		[Parameter(Position=5,Mandatory=1)] $AccountName,
		[Parameter(Position=6,Mandatory=1)] $AccountPassword
	)

	Write-Host "Installing $Name service..."

	Invoke-Command -ComputerName $ComputerName {

		$installServiceArgs = @(
		 	"-install",
		 	"-serviceName",
		 	$using:Name,
		 	"-displayName",
		 	"`"$using:DisplayName`"",
		 	"-description",
		 	"`"$using:Description`"",
		 	"-username",
		 	$using:AccountName,
		 	"-password",
		 	$using:AccountPassword
		)

	 	$installResult = Start-Process -WorkingDirectory $using:Directory `
	 		-FilePath "$using:Directory\NServiceBus.Host.exe" `
	 		-ArgumentList $installServiceArgs `
	 		-Wait `
	 		-PassThru

	 	if ($false -eq ($installResult -is [System.Diagnostics.Process])) {
			throw "Failed to launch NServiceBus.Host.exe"
		}

	 	$installResult.WaitForExit()

	 	$exitCode = [convert]::ToInt32($installResult.ExitCode)

	 	if ($exitCode -ne 0) {
	 		throw "Error installing $using:Name - return code was $exitCode"
		}
	 	else {
	 		Write-Host "$using:Name installation successful."
		}

	 	"Starting $using:Name..."

	 	$startServiceResult = Start-Process -WorkingDirectory $using:Directory `
	 		-FilePath "C:\Windows\System32\net.exe" `
	 		-ArgumentList @("start", $using:Name) `
			-Wait `
			-PassThru

	 	if ($false -eq ($startServiceResult -is [System.Diagnostics.Process])) {
	 		throw "Failed to start $using:Name service!"
		}

	 	$startServiceResult.WaitForExit();

	 	$exitCode = [convert]::ToInt32($startServiceResult.ExitCode)
	 	if ($exitCode -ne 0) {
	 		throw "Error starting $using:Name service - return code was $exitCode"
		}
	 	else {
	 		Write-Host "$using:Name service started successfuly."
		}
	}
}