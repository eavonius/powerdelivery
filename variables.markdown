---

layout: page

---

# Configuration Variables

IT products are littered with configuration, but powerdelivery is only concerned with those that change from one [environment](environments.html) to another. For example, the name of the database in a test environment might be different than in production. 

To point to the correct resources during each release without resorting to manual changes, you will record these using variables in PowerShell scripts within the *Configuration* directory of your powerdelivery project. Configuration variable scripts must return a hash. The values of the variables can be strings, integers, other hashes, or whatever you want to make available to [roles](roles.html) that apply actual changes to nodes in the environment.

## Shared variables

Every powerdelivery project includes one required variable script named *_Shared.ps1*. This script contains configuration variables that are available to all environments.

<br />

Below is an example. The keys and values here are simply for demonstration purposes.

<div class="row">
	<div class="col-sm-8">
{% highlight powershell %}
param($target)
@{
  DBScriptsDirectory = "MyApp\Scripts";
  GitRepo = "https://myhost/somerepo.git";
  ShareDirectory = "\\x.x.x.x\SomeFolder";
  Departments = "Marketing", "Sales", "IT", "Support";
  Approvers = @{
    DaveSmith = "dsmith@acme.com";
    MaryJane = "mjane@acme.com";
    TomJones = "tjones@acme.com"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Configuration\_Shared.ps1</div>
	</div>
</div>

You'll notice a [$target](reference.html#target_parameter) parameter in the script. This can be used to reference [secrets](secrets.html) or other properties of the current run of the deployment to use in shared configuration variables.

## Environment-specific variables

For every environment in your powerdelivery project, you must have a script named the same as the environment in the *Configuration* directory. If you define variables with the same name as those that exist in *Shared.ps1*, these will be **overridden** by the environment-specific definition at deployment time.

Environment-specific variable scripts declare the [$shared](reference.html#shared_parameter) parameter in addition to $target (which is present in the shared configuration script). Powerdelivery will pass the shared configuration variables hash as this parameter, allowing you to reference them. 

<br />

Below is an example of the configuration variable script for an environment named *Staging*.

<div class="row">
	<div class="col-sm-8">
{% highlight powershell %}
param($target, $shared)
@{
  # Uses a shared configuration variable
  MySpecialScript = "$($shared.DBScriptsDirectory)\MySpecialScript.sql"

  # Overrides the shared "Departments" variable
  Departments = "Business Development", "Product Management";
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Configuration\Staging.ps1</div>
	</div>
</div>

### Tips

* You can write PowerShell code above the hash to generate variables at runtime.
* You must ensure any role that expects a variable has it defined as a shared variable, or in all environments.

<br />

### Next read about [roles](roles.html).