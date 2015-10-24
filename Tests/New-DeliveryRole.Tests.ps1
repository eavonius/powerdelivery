Import-Module ..\Modules\PowerDelivery\PowerDelivery.psd1 -Force

Describe "GetProjectDirectory" {
  InModuleScope PowerDelivery {
    It "should not overwrite existing" {
      Mock GetProjectDirectory { return "C:\MyApp\MyAppDelivery" }
      Mock ValidateNewFileName { return $true }
      Mock Test-Path { return $true }
      { New-DeliveryRole "Compile" } |
        Should Throw "Directory .\Roles\Compile already exists."
    }
  }
}
