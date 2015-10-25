Import-Module ..\Modules\PowerDelivery\PowerDelivery.psd1 -Force

Describe "GetProjectDirectory" {
  InModuleScope PowerDelivery {

    It "should validate required directories" {
      { GetProjectDirectory } | 
        Should Throw "This command must be run from within a powerdelivery project directory."
    }

    It "should return path if valid" {
      Mock Test-Path { return $true }
      Mock Get-Location { return "TestDrive:\MyApp\MyAppDelivery" }
      $projectDir = GetProjectDirectory 
      $projectDir | Should Be 'TestDrive:\MyApp\MyAppDelivery'
    }
  }
}
