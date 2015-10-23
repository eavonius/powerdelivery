<#
.Synopsis
Returns an absolute path relative to the current directory.

.Description
Returns an absolute path relative to the current directory.

.Example
Write-RelativePath "C:\SomeDir\SomeOtherDir"

.Parameter Path
The absolute path to return the relative form of.
#>
function Write-RelativePath {
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

    $pathBldr = New-Object -TypeName System.Text.StringBuilder 260

    $startDir = Get-Location

    if ($powerdelivery.inBuild) {
      $startDir = $pow.target.StartDir
    }
    
    $result = [win32.Shell]::PathRelativePathTo($pathBldr, $startDir, [System.IO.FileAttributes]::Normal, $fullPath, [System.IO.FileAttributes]::Normal)
    if ($result) {
      $pathBldr.ToString()
    }
    else {
      "NOTFOUND"
    }
  }
}

Export-ModuleMember -Function Write-RelativePath