function Add-CommandCredSSP {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName, 
        [Parameter(Position=1,Mandatory=1)] $invokeArgs,
        [Parameter(Position=2,Mandatory=0)][string] $credentialUserName
    )

    if (!$computerName.StartsWith("localhost")) {

        $invokeArgs.Add("ComputerName", $computerName)
        $invokeArgs.Add("Authentication", "Credssp")

        Add-CredSSPTrustedHost $computerName

        $credentials = Get-BuildCredentials $credentialUserName
        $invokeArgs.Add("Credential", $credentials)
    }
}