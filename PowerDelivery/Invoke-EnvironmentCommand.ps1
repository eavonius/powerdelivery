<#
.Synopsis
Runs a delivery build command on a remote computer.

.Description
The Invoke-EnvironmentCommand cmdlet is used to execute a command on a remote computer as part of deployment.

If you use this cmdlet to modify the environment instead of PowerShell's built in Invoke-Command function, the benefit is that when running a Local build, it will run as a local command installing all the components necessary for deployment on your computer.

.Example
Invoke-EnvironmentCommand -server MyServer -command "$(whoami)"

.Parameter server
string - The computer to run the command on.

.Parameter command
string - The command to execute.

.Parameter credential
Optional. A set of SSP powershell credentials to pass when invoking the command.

.Notes
The remote computer must have the appropriate PowerShell ports open, have WinRM installed, and permit connection from the build server. It must also have PowerShell 3.0.
#>
function Invoke-EnvironmentCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $server, 
        [Parameter(Mandatory=1)][string] $command, 
        [Parameter(Mandatory=0)] $credential
    )

    $invokeExpression = $null
    if ($server -ne $null -and $credential -ne $null) {
		Write-Host
		"Command on $($server): $command"
        $invokeExpression = "Invoke-Command -ComputerName $server -ScriptBlock { $command } -Authentication CredSSP -credential $credential"
    }
    elseif ($server -ne $null) {
		"Command on $($server): $command"
        $invokeExpression = "Invoke-Command -ComputerName $server -ScriptBlock { $command }"
    }
    else {
        $command
        $invokeExpression = "Invoke-Expression $command"
    }
	
    return Invoke-Expression -Command $invokeExpression -ErrorAction Stop
}