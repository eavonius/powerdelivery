<# Verify.ps1

Verifies powerdelivery with chocolatey test environment https://github.com/chocolatey/chocolatey-test-environment.
You must pull the source into C:\Projects\chocolatey-test-environment and follow the instructions for installing 
virtualbox 4.8x, vagrant, sahara, and doing a "vagrant up" and "vagrant sandbox on" successfully before running this.

Also edit the Vagrantfile included with chocolatey-test-environment and update # THIS IS WHAT YOU CHANGE line 2 to:

choco.exe install -fdvy powerdelivery3 --allow-downgrade --source "'c:\\packages;http://chocolatey.org/api/v2/'"
#>
$startDir = Get-Location
$verifierDir = "C:\Projects\chocolatey-test-environment"
$packagesDir = "C:\Projects\chocolatey-test-environment\packages"

cp powerdelivery3.*.nupkg $packagesDir -force
cp powerdelivery3node.*.nupkg $packagesDir -force

Set-Location $verifierDir

try {
  vagrant provision
}
finally {
  Set-Location $startDir
}
