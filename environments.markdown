---

layout: page

---

# Environments

To smoothly deploy products through the various environments in a typical release process (development, test, production etc.), it makes sense to figure out what computing resources are necessary to host the product as early as possible. Waiting until the end of an engineering effort to provision test and production infrastructure is one of the best ways to miss your release goals.

Whether a physical computer or a virtual machine (on-premise or in the cloud), powerdelivery refers to each computing unit as a node. 

## Environment scripts

PowerShell scripts in the *Environments* directory of your project are where you tell powerdelivery which nodes will have [roles](roles.html) applied to them when deployment occurs. One script must exist for each environment that you will deploy to. These scripts must return a hash that contains sets of IP addresses, computer names, or domain names of the nodes to which the roles will be applied. 

<br />

An example environment script:

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Build = "localhost";
  Database = "x.x.x.1";
  Website = "x.x.x.2", "x.x.x.3"
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Test.ps1</div>
  </div>
</div>

Each set of nodes can contain multiple names or IP addresses separated by commas as the *Website* set demonstrates above. When powerdelivery deploys to this environment, it will apply any roles applied to Website nodes in a [target](targets.html) to all the listed nodes.

<a name="physical_and_vm_deployment"></a>

## Physical and VM deployment

The following sections help you use powerdelivery to deploy to nodes that are physical computers or virtual machines. To use powerdelivery with "platform as a service" resources (such as Windows Azure's cloud and mobile services), see [Cloud platform deployment](#cloud_platform_deployment).

<br />

### Enabling deployment to nodes

Powerdelivery uses WinRM to communicate from the computer running a [target](targets.html) to a remote node. When a fresh copy of Windows is installed on the node, default permissions usually prevent this from occurring. Without a way around this, you will be denied permission to apply roles to it.

To enable deployment to a node, first login to that node and [download this script](#) as *AllowDelivery.ps1*. Open an Administrator PowerShell console and change your working directory to wherever you downloaded it. 

<br />

The PowerShell console session below demonstrates permitting powerdelivery to deploy to this node:

<div class="row">
  <div class="col-sm-8">
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS> .\AllowDelivery.ps1
Powerdelivery has been permitted to deploy to this computer.
{% endhighlight %}
    </div>
  </div>
</div> 

**TIP**: If you will be deploying to many nodes with powerdelivery, save yourself some trouble and create an image using sysprep or another imaging tool that has had this script already run on it. This will allow you to provision a new node quickly that is already ready to be deployed to with powerdelivery if you need to scale up your infrastructure.

**Troubleshooting**: If you receive an error similar to below, chances are you have failed to run *AllowDelivery.ps1* on a node.

<div style="color: firebrick">[x.x.x.x] Connecting to remote server [x.x.x.x] failed with the following error message : WinRM cannot complete the operation. Verify that the specified computer name is valid, that the computer is accessible over the network, and that a firewall exception for the WinRM service is enabled and allows access from this computer. By default, the WinRM firewall exception for public profiles limits access to remote computers within the same local subnet. For more information, see the about_Remote_Troubleshooting Help topic.</div>

<br />

<a name="provisioning_nodes_at_deploy_time"></a>

### Provisioning nodes at deploy-time

In IT environments where computing resources are scarce (resources are on-premise or in boot-strapping startups), the cost of running multiple nodes is a factor. In this case, it is probably desirable to procure hardware or processing space and leave it dedicated as "the dev server", or "the test database server" throughout the release cycle of a product. [Physical and VM deployment](#physical_and_vm_deployment) (above) is perfect in this case.

If you have more resources available, it can be better to create a new node each time. This lets you rollback by pointing load balancers to the old site if you have a problem, and utilize other recovery methods when the previous release is still untouched.

To provision nodes on each run of powerdelivery, add PowerShell logic to the environment script above the statement that returns the hash of nodes. You'll need to install additional Powershell modules (Azure, AWS, VMWare, or Hyper-V cmdlets for example) and make sure these are able to be found when you run powerdelivery from the Administrator console. After you've provisioned the nodes, gather the name or IP address of them and add them to the hash to be returned.

<br />

The example below uses encrypted Azure [credentials](credentials.html) managed by powerdelivery:

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)

# Look up Azure credentials that were encrypted with powerdelivery
$azureCredentials = $target.Credentials["me@somewhere.com"]

Import-Module Azure

# "Sign-in" to Azure's PowerShell cmdlets with the credentials
Add-AzureAccount -Credential $azureCredentials

$nodes = @{}

#
# Omitted: do whatever is necessary to provision the nodes, 
# then add to the node list for example:
# 
# $nodes.Add("Website", @("x.x.x.5", "x.x.x.6"))
#

# Return the list of nodes at the conclusion of the script
$nodes
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Test.ps1</div>
  </div>
</div>

**TIP**: Nodes provisioned during deployment must be created from an image that has had the *GrantToDelivery.ps1* script already applied to them as described above.

<a name="cloud_platform_deployment"></a>

## Cloud platform deployment

Deploying to cloud platform resources, such as Windows Azure's Cloud and Mobile services simplifies environment configuration. Because these platform services do not provide direct VM access, use localhost as the node for any [roles](roles.html) that will access cloud resources. These roles' scripts should then use cmdlets provided by the vendor to access cloud platform resources.

Since most cmdlets from cloud platform vendors require [credentials](credentials.html), you can use the *Credentials* property of the [$target parameter](reference.html#target_parameter) in role scripts to retrieve any you've stored using [Write-DeliveryCredentials](reference.html#write_deliverycredentials_cmdlet). This will enable you to securely access cloud resources without storing credentials for provisioning and access in source control. See [using credentials in roles](credentials.html#using_credentials_in_roles) for an example.

<br />

### Next read about [credentials](credentials.html).