function Write-BuildPath {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=0)][string] $path
  )

  $pathUri = New-Object -TypeName System.Uri -ArgumentList $path

  if ($pathUri.IsUnc) {
    $path
  }
  else {
    if (-not ("win32.Shell" -as [type])) {
      Add-Type -Namespace win32 -Name Shell -MemberDefinition @"
      [DllImport("Shlwapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
      public static extern bool PathRelativePathTo(System.Text.StringBuilder lpszDst,
      string From, System.IO.FileAttributes attrFrom, String to, System.IO.FileAttributes attrTo);
"@
    }

    $fullPath = [System.IO.Path]::GetFullPath($path)

    if ($pow.EnvironmentName -eq 'Local') {
      $pathBldr = New-Object -TypeName System.Text.StringBuilder 260
      $startDir = $pow.Target.StartDir
      
      $result = [win32.Shell]::PathRelativePathTo($pathBldr, $startDir, [System.IO.FileAttributes]::Normal, $fullPath, [System.IO.FileAttributes]::Normal)
      if ($result) {
        $pathBldr.ToString()
      }
      else {
        "NOTFOUND"
      }
    }
  }
}

Export-ModuleMember -Function Write-BuildPath