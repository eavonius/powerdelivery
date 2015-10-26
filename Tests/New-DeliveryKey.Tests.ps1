Import-Module ..\Modules\PowerDelivery\PowerDelivery.psd1 -Force

Describe "New-DeliveryKey" {
  InModuleScope PowerDelivery {
    
    It "should not overwrite existing" {
      Mock GetProjectDirectory { "TestDrive:\MyAppDelivery" }
      Mock GetMyDocumentsFolder { "TestDrive:\MyDocuments" }
      Mock Test-Path { $true }

      { New-DeliveryKey "TestKey" } |
        Should Throw "Key TestDrive:\MyDocuments\PowerDelivery\Keys\MyAppDelivery\TestKey.key already exists."
    }

    It "should create key" {
      Mock GetProjectDirectory { "TestDrive:\MyAppDelivery" }
      Mock GetMyDocumentsFolder { "TestDrive:\MyDocuments" }
      Mock Test-Path { $false }

      Mock Write-Host {} -Verifiable -ParameterFilter { $Object -eq "Key written to ""TestDrive:\MyDocuments\PowerDelivery\Keys\MyAppDelivery\TestKey.key""" }

      New-DeliveryKey "TestKey"

      Assert-VerifiableMocks

      "TestDrive:\MyDocuments\PowerDelivery\Keys\MyAppDelivery\TestKey.key" | Should Exist
    }
  }
}
