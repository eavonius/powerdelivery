function Get-BuildSetting {
    [CmdletBinding()]
    param([Parameter(Position=0,Mandatory=1)][string] $name)

	ForEach ($envVar in $powerdelivery.envConfig) {
		if ($envVar.Name -eq $name) {
			return $envVar.Value
		}
	}
	throw "Couldn't find build setting '$name'"
}