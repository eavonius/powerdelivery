Import-Module ..\Modules\PowerDelivery\PowerDelivery.psd1 -Force

Describe "New-DeliveryRole" {
  InModuleScope PowerDelivery {
    
    It "should not overwrite existing" {
      Mock GetProjectDirectory { "TestDrive:\MyAppDelivery" }
      Mock Test-Path { $true }

      { New-DeliveryRole "Chocolatey" } |
        Should Throw "Directory .\Roles\Chocolatey already exists."
    }

    It "should create role" {
      Mock GetProjectDirectory { "TestDrive:\MyAppDelivery" }
      Mock Test-Path { $false }
      Mock Write-Host {} -Verifiable -ParameterFilter { $Object -eq "Role created at "".\Roles\Chocolatey""" }

      New-DeliveryRole "Chocolatey"

      Assert-VerifiableMocks

      "TestDrive:\MyAppDelivery\Roles\Chocolatey\Always.ps1" | Should Contain "Delivery:Role -Up {"
      "TestDrive:\MyAppDelivery\Roles\Chocolatey\Migrations" | Should Exist
    }
  }
}
