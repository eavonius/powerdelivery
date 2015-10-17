---

layout: page

---

# Getting Started

This page provides a walkthrough of getting setup and building a simple automated build to demonstrate some of the core features of powerdelivery. We'll just scratch the surface - to automate the release of your product, you'll want to read the rest of the topics when you're done here.

<a name="setup"></a>

## Set up your dev box or build server

Powerdelivery can be run directly from a developer's computer, or you can set it up to run automatically when developers check code into their source control repository. Either way, the computer that will run powerdelivery needs the following components:

* Windows 7, 8.1, or 10; or Windows Server 2008 R2 or 2012
* PowerShell 3.0 or greater
* Tools for compiling assets into deliverables (Visual Studio, Java, Grunt, etc.)
* Open ports in the firewall from the computer to any nodes it will deploy to

## Installation

Before you can use powerdelivery you'll need to install it onto your developer's computer, and your build server (if using one). Before using either of the methods below, you'll need to permit Powershell scripts downloaded from the internet to run on your computer. To do this, open a Powershell Administrator console and enter the command below:

<div class="row">
  <div class="col-sm-8">
    <div class="console">
{% highlight powershell %}
Set-ExecutionPolicy Unrestricted
{% endhighlight %}
    </div>
  </div>
</div>

<br />

### Installing with chocolatey

  The easiest way to install powerdelivery is with the <a href="http://www.chocolatey.org" target="_blank">chocolatey</a> package manager. Once you have chocolatey installed, open a Powershell Administrator console and enter the following command:

<div class="row">
	<div class="col-sm-8">
		<div class="console">
{% highlight powershell %}
choco install powerdelivery
{% endhighlight %}
		</div>
	</div>
</div>

After this completes, close and re-open an Administrator Powershell console.

<br />

### Installing from source

If you are not permitted to install chocolatey but you can execute Powershell scripts on the developer's computer or build server, you can install powerdelivery from source on github. Use your favorite git tool and clone the following repo:

*https://github.com/eavonius/powerdelivery.git*

Once you have the code in a local directory, modify the PSMODULEPATH environment variable from the Windows "System" control panel application. Append the "Modules" subdirectory of the source to the end of your path.

For example, if you cloned the github repo into *C:\Powerdelivery* and the current value of this variable is set to *C:\Somepath;C:\Someotherpath* the updated variable should look like this:

*C:\Somepath;C:\Someotherpath;C:\Powerdelivery\Modules*

Once you've set this variable, close any open consoles and re-open an Administrator Powershell console.

## Create a project

Powerdelivery includes the [pow:New](reference.html#pow_command) command that can be run from your console to [generate most of the files you'll 
need](reference.html#generators) to start quickly putting together automated releases. You'll want to store the files it generates in source control 
so first pull down a copy of your product's source code into a directory. 

In the example below, we'll pretend our product's source code has been pulled into the directory *C:\Projects\MyApp* and the name of the product is *MyApp*. We'll also assume we want developers to be able to test the deployment on their local computers; as well as to deploy to a test environment for user acceptance testing, and eventually to production.

<div class="row">
	<div class="col-sm-8">
		<div class="console">
{% highlight powershell %}
pow:new 'MyApp' @('Local', 'Test', 'Production')
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

## Configure environments

Next you need to tell powerdelivery what nodes will host the product in each environment. This will be totally dependent on your application.

Let's pretend our test environment will have two web server nodes and one database server node. We'll also pretend that in production, there will be four web servers and two database servers that have been setup for fault tolerance by being part of a Windows cluster.

With these decisions made, we fill out [environment scripts](environments.html) with our nodes:

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

A couple of notes about the scripts above. You'll note each script file is named after the environment. Also, the IP addresses could be computer names if resolvable through DNS or NetBIOS. Lastly, the "Build" group of nodes always specifies localhost - this ensures that any actions performed on this set of nodes are run on the developer's computer (or the build server) and not a test or production node.

<a name="roles"></a>

## Create a role

In powerdelivery, a role is a batch of Powershell commands that are intended to apply a set of changes to a node to enable it to serve a particular function in your overall product's architecture. Examples of roles might be "I host a web service", or "I run a database", or more generically - "I have .NET 4.5 and [chocolatey](http://www.chocolatey.org) installed". Powerdelivery doesn't create roles for you so let's dig into creating one.

The most common thing needed before any deployment of a release can occur on most Windows projects is compiling of code. This is not necessary, and since roles are Powershell scripts, you can call any commands to compile, retrieve, download, or generate whatever's needed to create assets that will be released to nodes. In our case, we'll use powerdelivery's included [Invoke-MSBuild](refresh.html#invoke_msbuild_cmdlet) cmdlet to compile a Visual Studio solution.

<p class="small" align="right">MyAppDelivery\Roles\Compile\Tasks.ps1</p>
{% highlight powershell %}
pow:role {
  param($target, $config, $node)

  Invoke-MSBuild -ProjectFile MyApp.sln
}
{% endhighlight %}

The [pow:Role](reference.html#pow_role_statement) statement tells powerdelivery we want any code within the brackets to execute when this role is applied as part of a [target](targets.html). The second line declares the three special parameters that are passed to every role. These are the [$target parameter](reference.html#target_parameter) (which provides many properties you can use in your role), the [$config parameter](reference.html#config_parameter) to allow you to access your configuration variables, and the [$node parameter](reference.html#node_parameter) which contains the name or IP address of the node the role is currently executing on. We're not using them here so you can ignore them for now.

<a name="targets"></a>

## Create a target

In powerdelivery, a sequential deployment process you might want to perform is represented by a target script. You can [read more about targets here](targets.html). We'll use the default *Release.ps1* script generated by the [pow:new](reference.html#pow_new_command) command to configure our target:

<div class="row">
	<div class="col-sm-8">
		<p class="small">MyAppDelivery\Targets\Release.ps1</p>
{% highlight powershell %}
[ordered]@{
  "Building the product" = @{
    Roles = ('Compile');
    Nodes = ('Build')
  }
}
{% endhighlight %}
	</div>
</div>

The *ordered* keywords tells powerdelivery to run these steps in sequence. The key of each step will be displayed as a status message, it can be whatever you like. *Roles* is an array of any roles that should be applied when this step is reached. In this case we will apply the *Compile* role we implemented in the role script earlier. Lastly, *Nodes* is an array of sets of nodes from the environment script that specifies what computing nodes will have the roles run on them.

## Run a target

To run a target, use the [pow](reference.html#pow_command) command. This command takes takes the name of the product as the first argument ("MyApp"), the target to run as the second argument, and the environment to apply the target to as the third parameter. 

The console session below demonstrates running pow from the directory above your powerdelivery project (*C:\Projects\MyApp* in this case) to run the Release target in the Local environment:

<div class="row">
  <div class="col-sm-8">
    <div class="console">
{% highlight powershell %}
pow myapp release local
powerdelivery v3.0.1 started by MYDOMAIN\me

Running target "release" in "local" environment...

[----- Building the product
[---------- Compile -> (localhost)

powerdelivery build succeeded in 1 sec 857 ms
{% endhighlight %}
    </div>
  </div>
</div>

Upon running the command you will see a build log in Powershell similar to above that shows who ran the build, which targets are executing, and on which nodes. If any errors occur you will need to resolve them and try your target again.

Now that you've had an overview of powerdelivery, follow the directions on this page to install it and create your own project, and continue by reading about [environments](environments.html) in more detail.