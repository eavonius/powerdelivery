<#
.Synopsis
Writes a message to the PowerDelivery HTML build summary page (YourBuild.html in the PowerDelivery\Deploy dir).

.Description
Writes a message to the PowerDelivery HTML build summary page.

.Parameter message
The message to add to the build summary.

.Parameter actionName
Optional. The PowerShell cmdlet or function that sent the message.

.Example
Write-BuildSummaryMessage 'My-Cmdlet' 'Something important happened!'
#>
function Write-BuildSummaryMessage
{
  [CmdletBinding()]
  param(
      [Parameter(Position=0,Mandatory=1)][string] $message,
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
  
  if ($pow.lastAction -ne $action)
  {
    Write-Host "[$action] " -ForegroundColor $pow.colors['RoleForeground']
  }
  
  Write-Host $message

  $pow.lastAction = $action
}

Export-ModuleMember -Function Write-BuildSummaryMessage