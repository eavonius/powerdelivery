function Publish-MasterDataServices {
    param(
        [Parameter(Position=0,Mandatory=1)] $computerName,
        [Parameter(Position=1,Mandatory=1)] $model,
        [Parameter(Position=2,Mandatory=1)] $service,
        [Parameter(Position=3,Mandatory=0)] $credentialUserName,
        [Parameter(Position=4,Mandatory=0)] $mdsDeployPath = "C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\MDSModelDeploy"
    )    
}