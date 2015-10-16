---

layout: page

---

# Configuration Variables

IT products are littered with configuration, but powerdelivery is only concerned with those that change from one [environment](environments.html) to another. For example, the name of the database in a test environment might be different than in production. To point to the correct resources during each release without resorting to manual changes, you will record these using variables in Powershell scripts within the **Configuration** directory of your powerdelivery project.

## Shared configuration

Every powerdelivery project includes one required configuration script named *_Shared.ps1*. This script contains configuration variables that are available to every environment. Configuration files are Powershell scripts that must return a hash. The values of the variables can be strings, integers, other hashes, or whatever you want to make available to [roles](roles.html) that apply actual changes to nodes in the environment.

Below is an example shared configuration file. The *SourceCodeRoot* variable is not required but often useful to set the working directory for roles relative to the root of the source code, which will be one directory up from where your run powerdelivery. The keys and values here are simply for demonstration purposes.

<p class="small" align="center">MyAppDelivery\Configuration\_Shared.ps1</p>
<div class="row">
	<div class="col-sm-8">
{% highlight powershell %}
@{
  DBScriptsDirectory = 'MyApp\Scripts';
  GitRepo = 'https://myhost/somerepo.git';
  ShareDirectory = '\\x.x.x.x\SomeFolder';
  Departments = @('Marketing', 'Sales', 'IT', 'Support');
  Approvers = @{
    DaveSmith = 'jsmith@acme.com';
    MaryJane = 'mjane@acme.com';
    TomJones = 'tjones@acme.com'
  }
}
{% endhighlight %}
	</div>
</div>

## Environment configuration

For every environment in your powerdelivery project, you must also have a script named the same as the environment but in the Configuration directory. If you define variables with the same name as those that exist in *Shared.ps1*, these will be **overridden** by the environment definition.

Environment scripts also must declare a **$Config variable** as a parameter at the top of the script. Powerdelivery will pass the shared configuration to this script, so you may reference any variables defined in the shared script. Below is an example of the configuration variable script for an environment named *Staging*.

<p class="small" align="center">MyAppDelivery\Configuration\Staging.ps1</p>
<div class="row">
	<div class="col-sm-8">
{% highlight powershell %}
param($Shared)

@{
  # Uses a shared configuration variable
  MySpecialScript = "$($Shared.DBScriptsDirectory)\MySpecialScript.sql"

  # Overrides the shared "Departments" variable
  Departments = @('Business Development', 'Product Management');
}
{% endhighlight %}
	</div>
</div>

### Tips

* You can write Powershell code above the hash to generate settings at runtime.
* You must make sure any role that expects a variable has it defined in the shared configuration, or all environments.

<br />

### Next read about [roles](roles.html).