Import-Module ..\Modules\PowerDelivery\PowerDelivery.psd1 -Force

Describe "GetKeyBytes" {
  InModuleScope PowerDelivery {
    $myDocumentsFolder = "TestDrive:\MyDocuments"
    $testKey = "W6H8qMR9Q5rn3g6gbc9fy0EpyTop80BRSq5v5zDSK4s="
    $testKeyDir = "TestDrive:\MyDocuments\PowerDelivery\Keys\MyAppDelivery"
    $testKeyPath = "$testKeyDir\MyKey.key"
    
    It "should verify existence of key" {
      Mock GetMyDocumentsFolder { $myDocumentsFolder }
      { GetKeyBytes -ProjectDir "MyAppDelivery" -KeyName "MyKey" -ThrowOnError } | 
        Should Throw "Key not found at $testKeyPath"
    }

    It "should return null on no key without -ThrowOnError" {
      Mock GetMyDocumentsFolder { $myDocumentsFolder }
      $keyBytes = GetKeyBytes -ProjectDir "MyAppDelivery" -KeyName "MyKey"
      $keyBytes | Should Be $null
    }

    It "should get valid key" {
      New-Item -ItemType Directory $testKeyDir
      Set-Content -Path $testKeyPath -Value $testKey
      Mock GetMyDocumentsFolder { $myDocumentsFolder }
      $keyBytes = GetKeyBytes -ProjectDir "MyAppDelivery" -KeyName "MyKey"
      $keyBytes | Should Be @(91, 161, 252, 168, 196, 125, 67, 154, 231, 222, 
                              14, 160, 109, 207, 95, 203, 65, 41, 201, 58, 41, 
                              243, 64, 81, 74, 174, 111, 231, 48, 210, 43, 139)
    }
  }
}
