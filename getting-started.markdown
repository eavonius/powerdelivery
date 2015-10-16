---

layout: page

---

# Getting Started

This page provides a walkthrough of getting setup and building a simple automated deployment pipeline to demonstrate some of the core features of powerdelivery.

<a name="setup"></a>

## Setting up your dev box or build server

Powerdelivery can be run directly from a developer's computer, or you can set it up to run automatically when developers check code into their source control repository. Either way, the computer that will run powerdelivery needs the following components:

* Windows 7, 8.1, or 10; or Windows Server 2008 R2 or 2012
* PowerShell 3.0 or greater
* Tools for compiling assets into deliverables (Visual Studio, Java, Grunt, etc.)
* Open ports in the firewall from the computer to any nodes it will deploy to

## Installation

Before you can use powerdelivery you'll need to install it onto your developer's computer, and your build server (if using one). Open a Windows Powershell **Administrator** command-prompt wherever powerdelivery needs to run and enter the following commands:

<div class="row">
	<div class="col-sm-8">
		<div class="console">
{% highlight powershell %}
Set-ExecutionPolicy Unrestricted
choco install PowerDelivery
{% endhighlight %}
		</div>
	</div>
</div>

After this completes, close and re-open an Administrator PowerShell command-prompt.

## Creating a project

Powerdelivery includes a Powershell command that can be run from your console to [generate most of the files you'll 
need](reference.html#invoke_powerdelivery_cmdlet) to start quickly putting together automated releases. You'll want to store the files it generates in source control 
so first pull down a copy of your product's source code into a directory. 

In the example below, we'll pretend our product's source code has been pulled into the directory *C:\Projects\MyApp* and the name of the product is *MyApp*. We'll also assume we want developers to be able to test the deployment on their local computers; as well as to deploy to a test environment for user acceptance testing, and eventually to production.

<div class="row">
	<div class="col-sm-8">
		<div class="console">
{% highlight powershell %}
pow:New 'MyApp' @('Local', 'Test', 'Production')
{% endhighlight %}
		</div>
	</div>
</div>

After this command completes you'll be left with the following directory structure:

<div class="row">
	<div class="col-sm-8">
		<pre class="directory-tree">
C:\Projects\MyApp\MyAppDelivery
  |-- Configuration
      |-- _Shared.ps1
      |-- Local.ps1
      |-- Test.ps1
      |-- Production.ps1
  |-- Credentials
  |-- Environments
      |-- Local.ps1
      |-- Test.ps1
      |-- Production.ps1
  |-- Roles
  |-- Targets
      |-- Release.ps1</pre>
	</div>
</div>
<br />
Because we specified three environment names as the second parameter to the command, powerdelivery generated files specific to each environment as appropriate. You could name these whatever makes sense for your particular method of release. We'll disect each of the above directories and generated files in the sections that follow.

<a name="infrastructure"></a>

## Planning and configuring your infrastructure

Next you need to think about what groups of computing nodes in your infrastructure will host your product in production. For example, you may need a set of three nodes participating as a "farm" to serve a website, two nodes running in a Windows cluster to host the database, and two more nodes that perform some batch processing. This will be totally dependent on your application - powerdelivery places no restrictions on the scale or structure you wish to employ.

Powerdelivery can deploy to computing nodes that are on-premise or in the cloud. It can also deploy to nodes that have already been provisioned (stood up with the operating system already joined to a domain), or spin up new ones on the fly. You can read about provisioning on the fly in the [roles](roles.html) topic, this is a more advanced technique that we'll skip for now to keep this overview topic moving forward.

Continuing with the example product we've used so far, let's assume our test environment will just have two web server nodes and one database server node. It's often good to have at least two nodes in any test environment that will have more than one in production to catch issues that only arise when things are load balanced or part of a "cluster" or "availability set". Let's assume then that in production, there will be four web servers and two database servers that have been setup for fault tolerance by being part of a Windows cluster. Again, there are no requirements about how you slice and dice the infrastructure. If you want to have one node for both environments that is up to you, but you must figure this out before you can start deploying into these environments.

Assuming the environment topology above, we fill out the [environment scripts](environments.html) with our nodes:

<div class="row">
	<div class="col-sm-8">
		<p class="small">MyAppDelivery\Environments\Local.ps1</p>
{% highlight powershell %}
@{
  Build = ('localhost');
  Database = ('localhost');
  Website = ('localhost')
}
{% endhighlight %}
	</div>
</div>

<div class="row">
	<div class="col-sm-8">
		<p class="small">MyAppDelivery\Environments\Test.ps1</p>
{% highlight powershell %}
@{
  Build = ('localhost');
  Database = ('x.x.x.1');
  Website = ('x.x.x.2', 'x.x.x.3')
}
{% endhighlight %}
	</div>
</div>

<div class="row">
	<div class="col-sm-8">
		<p class="small">MyAppDelivery\Environments\Production.ps1</p>
{% highlight powershell %}
@{
  Build = ('localhost');
  Database = ('x.x.x.4','x.x.x.5');
  Website = ('x.x.x.6','x.x.x.7','x.x.x.8','x.x.x.9')
}
{% endhighlight %}
	</div>
</div>

A couple of notes about the scripts above. You'll note each script (.ps1 file) is named after the environment. Also, the "Build" group of nodes always specifies localhost - this ensures that any tasks executed during the this phase are run on the developer's computer (or the build server) and not a test or production node.

<a name="roles"></a>

## Creating roles

In powerdelivery, a role is a batch of Powershell commands that are intended to apply a set of changes to a node to enable it to serve a particular function in your overall product's architecture. Examples of roles might be "I host a web service", or "I run a database", or more generically - "I have .NET 4.5 and [chocolatey](http://www.chocolatey.org) installed". Powerdelivery doesn't create roles for you so let's dig into creating one.

The most common thing needed before any deployment of a release can occur on most Windows projects is compiling of code. This is not necessary, and since roles are Powershell scripts, you can call any commands to compile, retrieve, download, or generate whatever's needed to create assets that will be released to nodes. In our case, we'll use powerdelivery's included [Invoke-MSBuild](refresh.html#invoke_msbuild_cmdlet) cmdlet to compile a Visual Studio solution.

<p class="small" align="right">MyAppDelivery\Roles\Compile\Tasks.ps1</p>
{% highlight powershell %}
pow:Role {
  param($Target, $Config, $Node)

  Invoke-MSBuild -ProjectFile "$($Config.SourceCodeRoot)MyApp.sln"
}
{% endhighlight %}

The first statement (pow:Role) tells powerdelivery we want any code within the brackets to execute when this role is applied as part of a [target](targets.html). The second line declares the three special parameters that are passed to every role. These are the [$Target variable](reference.html#target_variable) (which provides many properties you can use in your role), the [$Config variable](reference.html#config_variable) to allow you to access your configuration variables, and the [$Node variable](reference.html#node_variable) which contains the name or IP address of the node the role is currently executing on.

<a name="targets"></a>

## Creating targets

In powerdelivery, a sequential deployment process you might want to perform is represented by a target script. You can [read more about targets here](targets.html). We'll use the default *Release* target to tell powerdelivery to compile a Visual Studio project's source code on the local computer as the first step. If we assume the source code is in the same directory that our powerdelivery project is in, the script might look like this:

<div class="row">
	<div class="col-sm-8">
		<p class="small">MyAppDelivery\Targets\Release.ps1</p>
{% highlight powershell %}
[ordered]@{
  BuildProduct = @{
    Roles = ('Compile');
    Nodes = ('Build')
  }
}
{% endhighlight %}
	</div>
</div>

The *ordered* keywords tells powerdelivery to run these steps in sequence. We only have one step, but you should always include this as the first statement. *BuildProduct* defines the name of a step; it can be whatever you like. *Roles* is an array of any roles that should be applied when this step is reached. In this case we will apply the *Compile* role we implemented in the role script earlier. Lastly, *Nodes* is an array of sets of nodes from the environment script that specifies what computing nodes will have the roles run on them.