<#
.Synopsis
Writes a message to the console with the path to a log file.

.Description
Writes a message to the console with the path to a log file.

.Parameter logFilePath
The path to the logfile.

.Parameter actionName
Optional. The PowerShell cmdlet or function that sent the message.

.Example
Write-BuildLogFileMessage 'C:\MyPath\MyLogFile.log'
#>
function Write-BuildLogFileMessage
{
  [CmdletBinding()]
  param(
      [Parameter(Position=0,Mandatory=1)][string] $logFilePath,
      [Parameter(Position=1,Mandatory=0)][string] $actionName = $null
  )

  $action = $actionName

  if ([String]::IsNullOrWhitespace($actionName))
  {
      $action = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PSCommandPath)
  }

  $actionText = $action

  if ($pow.lastAction -eq $action)
  {
      $actionText = ''
  }

  if (![System.IO.Path]::IsPathRooted($logFilePath))
  {
      $logFilePath = Join-Path (Get-Location) $logFilePath
  }

  $logFileName = [System.IO.Path]::GetFileName($logFilePath)

  if ($pow.lastAction -ne $action)
  {
      Write-Host "[$actionText] " -ForegroundColor $pow.colors['RoleForeground']
  }

  Write-Host "Logfile: $(Write-RelativePath $logFilePath)" -ForegroundColor $pow.colors['LogFileForeground']

  $pow.lastAction = $action
}

Export-ModuleMember -Function Write-BuildLogFileMessage