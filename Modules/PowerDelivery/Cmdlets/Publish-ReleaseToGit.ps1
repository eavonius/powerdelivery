function Publish-ReleaseToGit {
  param(
    [Parameter(Position=0,Mandatory=1)][string] $repoUrl,
    [Parameter(Position=1,Mandatory=0)][string] $repoUser,
    [Parameter(Position=2,Mandatory=0)][string] $repoPassword
  )

  $newId = [System.Guid]::NewGuid()

  $appDataDir = [Environment]::GetFolderPath("ApplicationData")

  $tempReleaseDir = Join-Path $appDataDir "PowerDelivery\$newId"

  $gitCommand = "git clone https://$($repoUrl) $tempReleaseDir"

  if (!([String]::IsNullOrEmpty($repoUrl)) -and !([String]::IsNullOrEmpty($repoPassword))) {
    $gitCommand = "git clone https://$($repoUser):$($repoPassword)@$($repoUrl) $tempReleaseDir"  
  }

  pow:Invoke git "$($pow.target.StartedAt) -> ($repoUrl)" $null $gitCommand Publish-ReleaseToGit

  Remove-Item -Path $tempReleaseDir -Recurse -Force
}

Export-ModuleMember -Function Publish-ReleaseToGit