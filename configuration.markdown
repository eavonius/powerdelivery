---

layout: page

---

# Configuration Variables

IT products are littered with configuration, but powerdelivery is only concerned with those that change from one [environment](environments.html) to another. For example, the name of the database in a test environment might be different than in production. 

To point to the correct resources during each release without resorting to manual changes, you will record these using variables in PowerShell scripts within the *Configuration* directory of your powerdelivery project. Configuration scripts must return a hash. The values of the variables can be strings, integers, other hashes, or whatever you want to make available to [roles](roles.html) that apply actual changes to nodes in the environment.

## Shared configuration

Every powerdelivery project includes one required configuration script named *_Shared.ps1*. This script contains configuration variables that are available to all environments.

Below is an example. The keys and values here are simply for demonstration purposes.

<div class="row">
	<div class="col-sm-8">
{% highlight powershell %}
param($target)
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
  <div class="filename">MyAppDelivery\Configuration\_Shared.ps1</div>
	</div>
</div>

You'll notice a [$target parameter](reference.html#target_parameter) at the top of the script. This can be used to reference [credentials](credentials.html) or other properties of the current run of the deployment to use in configuration variables.

## Environment configuration

For every environment in your powerdelivery project, you must have a script named the same as the environment in the *Configuration* directory. If you define variables with the same name as those that exist in *Shared.ps1*, these will be **overridden** by the environment definition at deployment time.

Environment scripts declare the [$shared parameter](reference.html#shared_parameter) at the top of the script in addition to $target (which is present in the shared configuration script). Powerdelivery will pass the shared configuration hash as this parameter, allowing you to reference any variables defined in the shared script. Below is an example of the configuration variable script for an environment named *Staging*.

<div class="row">
	<div class="col-sm-8">
{% highlight powershell %}
param($target, $shared)
@{
  # Uses a shared configuration variable
  MySpecialScript = "$($shared.DBScriptsDirectory)\MySpecialScript.sql"

  # Overrides the shared "Departments" variable
  Departments = @('Business Development', 'Product Management');
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Configuration\Staging.ps1</div>
	</div>
</div>

### Tips

* You can write PowerShell code above the hash to generate settings at runtime.
* You must make sure any role that expects a variable has it defined in the shared configuration, or all environments.

<br />

### Next read about [roles](roles.html).