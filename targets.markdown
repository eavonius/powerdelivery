---

layout: page

---

# Targets

In powerdelivery, a sequential deployment process you might want to perform is represented by a target script. These are scripts contained within the *Targets* subdirectory and describe a sequential process. Each step in this process applies one or more [roles](roles.html) to one or more nodes in an [environment](environments.html). 

## Anatomy of a target script

Targets are simple scripts in powerdelivery that return an ordered hash of steps. Each step must specify a *Roles* value with a comma-separated list of the sets of roles that will be applied when the step is reached. Every step must also specify a *Nodes* value with a comma-separated list of the names of sets of nodes of the environment to apply those roles to. 

<br />

Below is an example target script:

<div class="row">
	<div class="col-sm-8">
{% highlight powershell %}
[ordered]@{
  "Building the product" = @{
    Roles = "Compile";
    Nodes = "Build"
  };
  "Deploying the database" = @{
    Roles = "Database";
    Nodes = "DatabaseServer"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Targets\Release.ps1</div>
	</div>
</div>

<br />

The *ordered* keyword tells powerdelivery to run these steps in sequence. The key of each step will be displayed as a status message. The first step says, in layman's terms, "when *building the product*, apply the *compile* role to the *build* nodes in the environment".

<br />

## Creating additional targets

Every powerdelivery project comes with an empty target *Release* located at *.\Targets\Release.ps1*. You can put all of your steps in this one target, or create as many other additional target scripts as you like. You may delete the Release target script if it doesn't match your naming conventions.

As an example, you may want to create one target that provisions nodes (spins them up in Azure, AWS, or your local VMWare or Hyper-V virtualized resource pool), and another that performs actual deployments. This could then be controlled through [credentials](secrets.html#using_secrets_for_credentials) to allow operations personnel to provision nodes, but only permit developers to perform deployments of the product.

## Running targets

To run a target, use the [Start-Delivery](reference.html#start_delivery_cmdlet) cmdlet. You should always run this from the directory *above* your powerdelivery project. This cmdlet takes the name of the project as the first parameter, the target to run as the second, and the environment to apply the target to as the third. You can read about additional parameters in the reference for the cmdlet.

<br />

The console session below demonstrates a run of the *Release* target in the *Local* environment:

<div class="row">
  <div class="col-sm-8">
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp> Start-Delivery MyApp Release Local

PowerDelivery v3.0.1
Target "Release" started by MYDOMAIN\me
Delivering "MyApp" to "Local" environment...

[----- Building the product
[---------- Compile -> (localhost)

Target "Release" succeeded in 1 sec 857 ms.
{% endhighlight %}
    </div>
  </div>
</div>

<br />

Upon running the command you will see a build log in PowerShell similar to above that shows who ran the build, which targets and environment were selected, and the progress of the roles being applied to each node. If any errors occur you will need to resolve them and try your target again. 

<br />

**Tip:** You may pass PowerShell's *-V* argument if you want to see verbose (detailed) output from the steps of the roles.