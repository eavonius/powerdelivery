---

layout: page

---

# Environments

To smoothly deploy products through the various environments in a typical release process (development, test, production etc.), it makes sense to figure out what computing resources are necessary to host the product as early as possible. Waiting until the end of an engineering effort to provision test and production infrastructure is one of the best ways to miss your release goals.

Whether a physical computer or a virtual machine (on-premise or in the cloud), powerdelivery refers to each computing unit as a node. 

## Environment scripts

PowerShell scripts in the *Environments* directory of your project are where you tell powerdelivery which nodes will have [roles](roles.html) applied to them when deployment occurs. One script must exist for each environment that you will deploy to. These scripts must return a hash that contains a nested hash with sets of nodes that will be deployed to when the environment named after the script is targeted using the [Start-Delivery](reference.html#start_delivery_cmdlet) cmdlet.

<br />

### Hostname nodes

One way PowerShell can connect to nodes is using a hostname (IP address, computer name, or domain name). When you want to connect to a node this way to deploy, use the *Hosts* key for each set of nodes. You may supply multiple hosts in the same set of nodes separated by commas.

<br />

An example "Test" environment script using hosts:

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Build = @{
    Hosts = "localhost"
  };
  Database = @{
    Hosts = "x.x.x.1"
  };
  Website = @{
    Hosts = "x.x.x.2", "x.x.x.3"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Test.ps1</div>
  </div>
</div>

<br />

When powerdelivery deploys to this environment, it will apply any roles in a [target](targets.html) that are set to *Website* to all the listed hosts. You can also use the [$target parameter](reference.html#target_parameter) and [$config parameter](reference.html#config_parameter) to dynamically construct your node host names if necessary.

<br />

### Connection URI nodes

PowerShell can also connect to nodes using a connection URI. When you want to connect to a node this way to deploy, use the *Connections* key for each set of nodes. Windows Azure VMs are typically connected to in this way. You may supply multiple connections in the same set of nodes separated by commas.

<br />

An example "Test" environment script using connection URIs:

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Build = @{
    Hosts = "localhost"
  };
  Database = @{
    Connections = "http://mydatabasevm.cloudapp.net:5986/"
  };
  Website = @{
    Connections = "http://mywebsvc.cloudapp.net:5986/", `
                  "http://mywebsvc.cloudapp.net:5987/"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Test.ps1</div>
  </div>
</div>

<br />

When powerdelivery deploys to this environment, it will apply any roles in a [target](targets.html) that are set to *Website* using all the listed connection URIs. You can use the [$target parameter](reference.html#target_parameter) and [$config parameter](reference.html#config_parameter) to dynamically construct your node connection URIs if necessary.

<br />

<a name="connection_settings"></a>

## Connection settings

Each set of nodes may optionally specify a *Credentials* attribute to refer to [credentials](credentials.html) that will be used to connect to the node remotely with PowerShell. You may also supply an *Authentication* attribute which specifies how these credentials are passed to a remote node. Valid values are Default, Basic, Credssp, Digest, Kerberos,
Negotiate, and NegotiateWithImplicitCredential. If you don't specify an authentication method, the default value is *Default*. You can read more about these by referring to the the PowerShell documentation for [Invoke-Command](https://technet.microsoft.com/en-us/library/hh849719.aspx).

<br />

Below is an example of specifying to use credentials and Kerberos authentication with a node set:

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Database = @{
    Hosts = "x.x.x.1";
    Credentials = "me@somewhere.com";
    Authentication = "Kerberos"
  }
}
{% endhighlight %}
  </div>
</div>

<br />

You may also require clients to use SSL to establish the PowerShell remote connection. To do this, set the *UseSSL* key in the set of nodes set to true.

<br />

Below is an example of specifying to use SSL with a node set:

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Database = @{
    Hosts = "x.x.x.1";
    Credentials = "me@somewhere.com";
    UseSSL = $true
  }
}
{% endhighlight %}
  </div>
</div>

<br />

**Tips** 

* This article titled [about remote troubleshooting](https://technet.microsoft.com/en-us/library/hh847850.aspx) is invaluable in working through any connection issues you may run into.
* If deploying to Windows Azure virtual machines, [download this script from Microsoft](https://gallery.technet.microsoft.com/scriptcenter/Configures-Secure-Remote-b137f2fe) and use it to load an SSL certificate on developer computers or build servers targeting the VMs.

<br />

<a name="physical_and_vm_deployment"></a>

## Physical and VM deployment

The following sections help you use powerdelivery to deploy to nodes that are physical computers or virtual machines. To use powerdelivery with "platform as a service" resources (such as Windows Azure's cloud and mobile services), see [Cloud platform deployment](#cloud_platform_deployment).

<br />

<a name="enabling_deployment_to_nodes"></a>

### Enabling deployment to nodes

Powerdelivery uses PowerShell to communicate from the computer running a [target](targets.html) to a remote node. When a fresh copy of Windows is installed on the node, default permissions usually prevent this from occurring. Without a way around this, you will be denied permission to apply roles to it.

<br />

<b>Step 1: Add users who can deploy</b>

To enable deployment to a node, first login and add any users that will be permitted to do so to the Windows *Remote Management Users* group. If the user is not a member of that or the *Administrators* group, they will get Access Denied errors when deploying.

<br /> 

<b>Step 2: Allow PowerShell delivery</b>

Second, login to the node again and <a href="https://raw.githubusercontent.com/eavonius/powerdelivery/master/Scripts/Nodes/AllowDelivery.ps1" target="_blank">download this powerdelivery script</a> as *AllowDelivery.ps1* using a web browser. Open an Administrator PowerShell console and change your working directory to wherever you downloaded it. 

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

<br />

**Tip:** If you will be deploying to many nodes with powerdelivery, save yourself some trouble and create an image using sysprep or another imaging tool that has had this script already run on it. This will allow you to provision a new node quickly that is already ready to be deployed to with powerdelivery if you need to scale up your infrastructure.

<br />

<a name="provisioning_nodes_at_deploy_time"></a>

### Provisioning nodes at deploy-time

In IT environments where computing resources are scarce (resources are on-premise or in boot-strapping startups), the cost of running multiple nodes is a factor. In this case, it is probably desirable to procure hardware or processing space and leave it dedicated as "the dev server", or "the test database server" throughout the release cycle of a product. [Physical and VM deployment](#physical_and_vm_deployment) (above) is perfect in this case.

If you have more resources available, it can be better to create a new node each time. This lets you rollback by pointing load balancers to the old site if you have a problem, and utilize other recovery methods when the previous release is still untouched.

To provision nodes on each run of powerdelivery, add PowerShell logic to the environment script above the statement 
that returns the hash of nodes. You'll need to install additional PowerShell modules (Windows Azure, Amaozon Web Services, VMWare, or Hyper-V cmdlets for example) and make sure these are able to be found when you run powerdelivery from the Administrator console. After you've provisioned the nodes, gather the name or IP address of them and add them to the hash to be returned.

<br />

The example below provisions a node at runtime with Windows Azure:

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)

# Declare the nodes we'll return at the end
$nodes = @{}

# Get credentials from an environment configuration variable that 
# your new VM will allow logins from. You'll have to create this 
# ahead of time in Azure AD or a domain controller.
$newVMCredentials = $target.Credentials["powerdelivery@mydomain.com"]

Import-Module Azure

# "Sign-in" to Windows Azure's PowerShell cmdlets with powerdelivery credentials
Add-AzureAccount -Credential $target.Credentials["admin@mydomain.com"]

# Set the Azure subscription from an environment configuration variable
Select-AzureSubscription $config.AzureSubscriptionId

# This would use Windows Server 2012. If dynamically provisioning, 
# don't really do this. You should instead use your own VHD that 
# has had powerdelivery already configured on it as described in 
# "Enabling deployment to nodes" above, otherwise powerdelivery 
# won't be able to connect to it
$image = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-Datacenter-201305.01-en.us-127GB.vhd"

# Create the VM using the image and an admin username and password
New-AzureVMConfig -Name "TestVM" `
                  -InstanceSize "Small" `
                  -ImageName $image | 
  Add-AzureProvisioningConfig -Windows `
                              -AdminUsername "MYDOMAIN\admin" `
                              -Password "s@m3p@@sw0rd" |
    New-AzureVM -ServiceName "MyService" -Location "West US" -WaitForBoot 

# Execute the script from microsoft that sets up a VM for PowerShell
.\Scripts\InstallWinRMCertAzureVM.ps1 -SubscriptionName $config.AzureSubscriptionId `
                                      -ServiceName "MyService" `
                                      -Name "TestVM"

# Get the connection URI from the new VM so we can connect to it via PowerShell
$uri = Get-AzureWinRMUri -ServiceName "MyService" -Name "TestVM"

# Add the provisioned VM to the list of nodes for the "Website" role
$nodes.Add("Website", @{ Connections = $uri; Credentials = $newVMCredentials })

# Return the list of nodes at the conclusion of the script
$nodes
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Test.ps1</div>
  </div>
</div>

<br />

**Tips**

* Nodes provisioned during deployment must be created from an image that has had the *GrantToDelivery.ps1* script already applied to them as described above.
* [This article by Michael Washam](http://michaelwasham.com/windows-azure-powershell-reference-guide/introduction-remote-powershell-with-windows-azure/) was crucial for writing the above example. Thanks Michael!

<br />

<a name="cloud_platform_deployment"></a>

## Cloud platform deployment

Deploying to cloud platform resources, such as Windows Azure's Cloud and Mobile services simplifies environment configuration. Because these platform services do not provide direct VM access, use localhost as the node for any [roles](roles.html) that will access cloud resources. These roles' scripts should then use cmdlets provided by the vendor to access cloud platform resources.

Since most cmdlets from cloud platform vendors require [credentials](credentials.html), you can use the *Credentials* property of the [$target parameter](reference.html#target_parameter) in role scripts to retrieve any you've stored using [Write-DeliveryCredentials](reference.html#write_deliverycredentials_cmdlet). This will enable you to securely access cloud resources without storing credentials for provisioning and access in source control. See [using credentials in roles](credentials.html#using_credentials_in_roles) for an example.

<br />

### Next read about [credentials](credentials.html).