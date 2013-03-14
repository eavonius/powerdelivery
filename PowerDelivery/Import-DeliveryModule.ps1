function Import-DeliveryModule {
	[CmdletBinding()]
	param([Parameter(Position=0,Mandatory=1)][string] $name)
	
	if ($global:g_powerdelivery_delivery_modules -eq $null) {
		$global:g_powerdelivery_delivery_modules = @()
	}
	
	if ($global:g_powerdelivery_delivery_modules -notcontains $name) {
		$global:g_powerdelivery_delivery_modules += $name
	}
}