<#
.Synopsis
Writes a command to the PowerDelivery HTML build summary page (YourBuild.html in the PowerDelivery\Deploy dir).

.Description
Writes a command to the PowerDelivery HTML build summary page.

.Parameter commandName
The name of the command to add to the build summary.

.Parameter commandLine
The full commandline of the command to add to the build summary.

.Parameter actionName
Optional. The PowerShell cmdlet or function that sent the message.

.Example
Write-BuildSummaryMessage 'msbuild.exe myfile.sln /t:sometarget'
#>
function Write-BuildCommandMessage
{
  [CmdletBinding()]
  param(
      [Parameter(Position=0,Mandatory=1)][string] $commandName,
      [Parameter(Position=1,Mandatory=1)][string] $commandLine,
      [Parameter(Position=2,Mandatory=0)] $actionName = $null
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

  if (Test-Verbose)
  {
      if ($pow.lastAction -ne $action)
      {
          Write-Host "[$action] " -ForegroundColor $pow.colors['CommandForeground']
      }

      Write-Host $commandLine
  }

  $pow.lastAction = $action
}

Export-ModuleMember -Function Write-BuildCommandMessage