function Invoke-DeliveryCommand
{
  param(
    [Parameter(Position=0,Mandatory=1)][string] $commandName,
    [Parameter(Position=1,Mandatory=1)][string] $summaryMessage,
    [Parameter(Position=2,Mandatory=0)] $logFile,
    [Parameter(Position=3,Mandatory=1)] $command,
    [Parameter(Position=4,Mandatory=0)][string] $actionName
  )

  $buildAction = $commandName

  if (![String]::IsNullOrWhitespace($actionName))
  {
    $buildAction = $actionName
  }

  Write-BuildSummaryMessage $summaryMessage $buildAction
  Write-BuildCommandMessage $commandName $command $buildAction

  if (![String]::IsNullOrWhitespace($logFile))
  {
    Write-BuildLogFileMessage $logFile $buildAction
  }

  Invoke-Expression "& $command" | Out-Null

  if ($lastexitcode -ne 0)
  {
    $errorMessage = "Command $buildAction failed. Check your parameters or try again with verbose output." 

    if (![String]::IsNullOrWhitespace($logFile))
    {
      $errorMessage += " See $logFile for details."
    }
    
    throw $errorMessage
  }
}

Export-ModuleMember -Function Invoke-DeliveryCommand