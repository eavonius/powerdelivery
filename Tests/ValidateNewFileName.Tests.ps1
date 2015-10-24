Import-Module ..\Modules\PowerDelivery\PowerDelivery.psd1 -Force

Describe "ValidateNewFileName" {
  InModuleScope PowerDelivery {

    It "should not allow spaces" {
      { ValidateNewFileName -Type "test type" -FileName "hey you" } | 
        Should Throw "Please use a test type that only includes alphanumeric characters and no spaces."
    }
    
    It "should not allow special characters" {
      { ValidateNewFileName -Type "test type" -FileName "hey#you" } | 
        Should Throw "Please use a test type that only includes alphanumeric characters and no spaces."
    }
    
    It "should be valid" {
      { ValidateNewFileName -Type "test type" -FileName "heyyou" } | Should Not Throw
    }
  }
}
