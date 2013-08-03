<#
.Synopsis
Stops and then uninstalls a Windows Service for an NServiceBus version 4+ Enterprise Service Bus host.

.Description
Stops and then uninstalls a Windows Service for an NServiceBus version 4+ Enterprise Service Bus host. 
You should call this cmdlet prior to Install-NServiceBusService otherwise files will be in use.

.Parameter ComputerName
The name of the remote computer to uninstall the service from.

.Parameter Name
The name of the service. This can be used to start/stop the service with the "net" command.

.Parameter Directory
A local path on the computer specified by the ComputerName parameter containing the service.

.Example
Uninstall-NServiceBusService `
	-ComputerName MyComputer `
	-Name MyService `
	-Directory "C:\Share\MyService" 
#>
function Uninstall-NServiceBusService{
	param(
		[Parameter(Position=0,Mandatory=1)]$ComputerName,
		[Parameter(Position=1,Mandatory=1)]$Name,
		[Parameter(Position=2,Mandatory=1)]$Directory
	)

    $logPrefix = "Uninstall-NServiceBusService:"

    $computerNames = $ComputerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

	    Invoke-Command -ComputerName $curComputerName {

		    if ((Get-Service -Name $using:Name -ErrorAction SilentlyContinue) -ne $null) {

                $priorSvcCmd = (Get-WmiObject -query "SELECT PathName FROM Win32_Service WHERE Name = '$using:Name'").PathName                $priorSvcExePath = ($priorSvcCmd -replace '^\"([^\"]*)\".*$','$1').Trim('"')                $priorSvcLocalPath = (Split-Path $priorSvcExePath -Parent)

		 	    $uninstallServiceArgs = @(
		 		    "-uninstall",
		 		    "-serviceName",
		 		    $using:Name
			    )

                "$using:logPrefix Uninstalling previous copy of $using:Name service from $using:curComputerName in $priorSvcLocalPath"

			    $uninstallResult = Start-Process -WorkingDirectory $priorSvcLocalPath `
			 	    -FilePath "$priorSvcLocalPath\NServiceBus.Host.exe" `
			  	    -ArgumentList $uninstallServiceArgs `
			 	    -ErrorAction SilentlyContinue `
			 	    -Wait `
			 	    -PassThru

			    if ($false -eq ($uninstallResult -is [System.Diagnostics.Process]))
			    {
			 	    throw "Failed to launch NServiceBus.Host.exe on $curComputerName"
			    }

			    $uninstallResult.WaitForExit()
		    }
        }
	}
}