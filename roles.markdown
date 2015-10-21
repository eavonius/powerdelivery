---

layout: page

---

# Roles

When performing deployment activities with powerdelivery, the real work that applies changes to your nodes happens in roles. These are PowerShell scripts within the *Roles* directory of your project in their own directory named after the role.

## Generating roles

To assist with creating roles, you can use the [New-DeliveryRole](reference.html#new_deliveryrole_cmdlet) cmdlet to generate one for your project. Run this cmdlet in the directory above your powerdelivery project.

<br />

Below is an example of creating a role for installing the <a href="http://www.chocolatey.org" target="_blank">chocolatey</a> package manager:

<div class="row">
	<div class="col-sm-8">
		{% include console_title.html %}
		<div class="console">
{% highlight powershell %}
PS> New-DeliveryRole MyApp Chocolatey
Role created at ".\MyAppDelivery\Roles\Chocolatey"
{% endhighlight %}
		</div>
	</div>
</div>

<br />

After this cmdlet completes it will have added the following to your directory structure:

<div class="row">
  <div class="col-sm-8">
    <pre class="directory-tree">
.\MyAppDelivery\
    |-- Roles\
        |-- Compile\
            |-- Always.ps1
            |-- Migrations\</pre>
  </div>
</div>

<br />

The contents of Always.ps1 as generated looks like this:

<div class="row">
  <div class="col-sm-8">
{% highlight powershell %}
Delivery:Role {
  -Up {
    param($target, $config, $node)
  }
  -Down {
    param($target, $config, $node)
  }
}
{% endhighlight %}
  </div>
</div>


## Anatomy of a role script

Every role script must contain the *Delivery:Role* statement. After this statement, an *-Up* block specifies what will happen when a normal deployment occurs applying this role. If specified, a *-Down* block will run when you request a rollback while running the [Start-Delivery](reference.html#start_delivery_cmdlet) cmdlet. The down block is optional, and if you specify just one block without a name, it will be used as the up block.

<br />

The example below shows a script with only the default (up) block:

<div class="row">
  <div class="col-sm-8">
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)
}
{% endhighlight %}
  </div>
</div>

### Role script parameters

Every block in a role, whether performing an up or down (rollback), must declare three parameters. These are the [$target](reference.html#target_parameter), [$config](reference.html#config_parameter), and [$node](reference.html#node_parameter) parameters. These parameters provide context to where your role is running and will be very useful depending on what you're trying to do.


## Types of role scripts

There are two types of role scripts, which you can run both of or just one. Read the sections below to decide which makes the most sense for your particular infrastructure and release process.

<br />

### The "Always" role script

Always.ps1 runs, as so aptly named, every time the role is applied. If you are [provisioning nodes at deploy time](environments.html#provisioning_nodes_at_deploy_time) you can put all of your role logic here, as it will be applied to a fresh node every time you deploy; regardless of the target environment.

<br />

### Role migration scripts

If you are deploying to nodes that were provisioned ahead of time and are not to be re-created from scratch on each deployment, consider using role migration scripts. Role migration scripts are similar to data migrations in ruby on rails. They allow you to script a set of changes that will be made to a node and associated with a version, so the node upon which they are run remembers whether it was already applied.

Migration scripts are important because without them, if someone deploys changes to one environment (say, a development server) and then changes the script, the test environment may never get that change applied to it once it is deployed to. With migration scripts, changes are rolled forward in a predictable fashion.

<br />

**Generating a role migration script**

Use the [New-DeliveryRoleMigration](reference.html#new_deliveryrolemigration_cmdlet) cmdlet to add a role migration to an existing role in your project. The role you add the migration to must already have been created by the *New-DeliveryRole* cmdlet. Run this cmdlet in the directory above your powerdelivery project.

<br />

Below is an example of adding a migration script to a role named *Database*:

<div class="row">
  <div class="col-sm-10">
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS> New-DeliveryRoleMigration MyApp Database "Truncate Logfile"
Role migration created at ".\MyAppDelivery\Roles\Database\Migrations\20151019_112811_Truncate_Logfile.ps1"
{% endhighlight %}
    </div>
  </div>
</div>

**Tips**: 

* The content of a role migration script is just like Always.ps1. You can specify just the up block, or both up and down.
* Always.ps1 runs *before* any migration scripts if present during a normal deployment.
* Always.ps1 runs *after* any migration scripts if present when rolling back.

<br />

## Scripting roles

### Installing dependencies

There are a few important nuances to remember about roles. First, if a role is set to run on localhost, you may use any of the PowerShell cmdlets installed on a developer or build server computer. However, if a role runs on a remote computer, any PowerShell cmdlets you want to use need to be installed before you can use them. Many PowerShell cmdlets, including powerdelivery itself, are installed with the popular [chocolatey](http://www.chocolatey.org) package manager. 

Lets modify our script we generated at the beginning of this topic by editing the file *Always.ps1* to install chocolatey:

<br />


<div class="row">
  <div class="col-sm-10">
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  if (!(Test-CommandExists choco)) {
    Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    $path = $env:PATH
    $allUsersProfile = $env:ALLUSERSPROFILE
    $env:PATH = "$path;$allUsersProfile\chocolatey\bin"
  }
}
{% endhighlight %}
  </div>
</div>

<br />

Now if we want any remote node to have chocolatey installed, we can just include the "Chocolatey" role in the steps of a the [target](targets.html) script that make sense. We can also add calls to the *choco* command-line client to install packages in this role, or another that is set to run after it in our target.

<br />

### Next read about [targets](targets.html).