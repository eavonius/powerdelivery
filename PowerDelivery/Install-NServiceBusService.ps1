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
A relative path in the build drop location of files containing the service to install.

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
		[Parameter(Position=1,Mandatory=1)][string] $Name,
		[Parameter(Position=2,Mandatory=1)][string] $DisplayName,
		[Parameter(Position=3,Mandatory=1)][string] $Description,
		[Parameter(Position=4,Mandatory=1)][string] $Directory,
		[Parameter(Position=5,Mandatory=1)][string] $AccountName,
		[Parameter(Position=6,Mandatory=1)][string] $AccountPassword,
        [Parameter(Position=7,Mandatory=0)] $IsMaster = $false,
        [Parameter(Position=8,Mandatory=0)] $IsDistributor = $false,
        [Parameter(Position=9,Mandatory=0)][string] $DistributorAddress,
        [Parameter(Position=10,Mandatory=0)][string] $EndpointConfigurationType
	)

    $logPrefix = "Install-NServiceBusService:"

    $dropLocation = Get-BuildDropLocation

    if ($IsMaster -and $IsDistributor) {
        throw "An instance cannot be a distributor and a master."
    }

    if (($IsMaster -or $IsDistributor) -and ![String]::IsNullOrWhiteSpace($DistributorAddress)) {
        throw "The distributor address does not need to be specified for a master or distributor."
    }

    $computerNames = $ComputerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        Invoke-Command -ComputerName $curComputerName {
            Enable-WSManCredSSP -Role Server -Force | Out-Null
        }

        Enable-WSManCredSSP -Role Client -DelegateComputer $curComputerName -Force | Out-Null

        $dropServicePath = Join-Path $dropLocation $Directory
        
        $remoteDeployPath = Get-ComputerRemoteDeployPath $curComputerName
        $remoteServicePath = Join-Path $remoteDeployPath $Directory

        $localDeployPath = Get-ComputerLocalDeployPath $curComputerName
        $localServicePath = Join-Path $localDeployPath $Directory

        "$logPrefix Creating $remoteServicePath"
        mkdir -Force $remoteServicePath | Out-Null

        "$logPrefix Copying $dropServicePath\* to $remoteServicePath"
        copy "$dropServicePath\*" $remoteServicePath -Force -Recurse | Out-Null

        "$logPrefix Installing $Name service on $curComputerName as $($AccountName)..."

        $secpasswd = ConvertTo-SecureString $AccountPassword -AsPlainText -Force        $accountCreds = New-Object System.Management.Automation.PSCredential ($AccountName, $secpasswd)

	    Invoke-Command -ComputerName $curComputerName -Authentication Credssp -Credential $accountCreds {

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

            if (![String]::IsNullOrWhiteSpace($using:EndpointConfigurationType)) {
                $installServiceArgs.Add('EndpointConfigurationType', $using:EndpointConfigurationType)
            }

            cd $using:localServicePath
	 	    & "$using:localServicePath\NServiceBus.Host.exe" @installServiceArgs

	 	    if ($LASTEXITCODE -ne 0) {
	 		    throw "Error installing $using:Name - return code was $LASTEXITCODE"
		    }
	 	    else {
	 		    Write-Host "$using:Name service installed on $using:curComputerName."
		    }

	 	    "$using:logPrefix Starting $using:Name service on $using:curComputerName ..."

            Get-Service -ComputerName $using:curComputerName $using:Name | Restart-Service
	
	        Do {
		        Start-Sleep -Seconds 5
                "$using:logPrefix Polling for $using:Name on $using:curComputerName to finish restarting..."
	        } Until ((Get-Service -ComputerName $using:curComputerName $using:Name).Status -eq "Running")

            "$using:logPrefix $using:Name service started on $using:curComputerName successfully."
        }
	}
}