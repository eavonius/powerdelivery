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