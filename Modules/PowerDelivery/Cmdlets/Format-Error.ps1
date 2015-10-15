function Format-Error
{
  param(
    [Parameter(Position=0,Mandatory=1)] $errorObject
  )

  $result = [String]::Empty

  $ErrorRecord = $errorObject[0]
  $Exception = $ErrorRecord.Exception

  if (![String]::IsNullOrWhiteSpace($ErrorRecord.FullyQualifiedErrorId))
  {
    $result += "$($ErrorRecord.FullyQualifiedErrorId)"
  }

  if (![String]::IsNullOrWhiteSpace($result))
  {
    $result += "`n"
  }

  $result += "$($ErrorRecord.ScriptStackTrace)"
  #}

  $result
}

Export-ModuleMember -Function Format-Error