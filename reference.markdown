---
layout: page
---

# Reference
	
This page contains reference for the script parameters and cmdlets included with powerdelivery.

<a name="script_parameters"></a>

## Script Parameters

The scripts you work with in powerdelivery take a number of parameters that help your releases go smoothly.

<hr />

<a name="target_parameter"></a>

<p class="ref-item">$target</p>
References the current run of the [target](targets.html). The target parameter is a hash that provides a number of properties that can be used in scripts.

<p class="ref-upper">Properties</p>
<dl>
	<dt>ProjectName</dt>
	<dd>The name of the project.</dd>
	<dt>TargetName</dt>
	<dd>The name of the target during this run.</dd>
	<dt>EnvironmentName</dt>
	<dd>The name of the environment during this run.</dd>
	<dt>Revision</dt>
	<dd>Optional. The name of the revision of this run, when specified.</dd>
	<dt>RequestedBy</dt>
	<dd>The username of the Windows account that started the run.</dd>
	<dt>StartDate</dt>
	<dd>A timestamp as a DateTime of when the run started.</dd>
	<dt>StartedAt</dt>
	<dd>A timestamp in the format yyyyMMdd_hhmmss of when the run started.</dd>
	<dt>Credentials</dt>
	<dd>A dictionary (hash) containing the usernames of credentials as the key, and <a href="https://msdn.microsoft.com/en-us/library/system.management.automation.pscredential(v=vs.85).aspx" target="_blank">PowerShell Credentials</a> that were loaded at startup (see <a href="credentials.html">credentials</a>) as their value.</dd>
</dl>

<p class="ref-upper">Examples</p>

<p>Example of a role script using the $target parameter.</p>
{% highlight powershell %}
param($target, $config, $node)
Delivery:Role {

  # Access run properties using $target and print them to the console
  Write-Host "I'm deploying $($target.ProjectName) started by $($target.RequestedBy)."

  # Lookup credentials using $target
  $opsCredentials = $target.Credentials['DOMAIN\opsuser']
}
{% endhighlight %}

<br />

<a name="config_parameter"></a>

<p class="ref-item">$config</p>
A hash containing the [configuration](configuration.html) of the current run.

<p class="ref-upper">Examples</p>
<p>Example of a configuration script defining two variables.</p>
{% highlight powershell %}
param($target, $config)
@{
  Hello = "Hello";
  World = "World"
}
{% endhighlight %}

<p>Example of a role script using the $config parameter to reference the configuration above.</p>
{% highlight powershell %}
param($target, $config, $node)
Delivery:Role {

  # Prints "Hello World" to the console
  Write-Host "$($config.Hello) $($config.World)"
}
{% endhighlight %}

<br />

<a name="node_parameter"></a>

<p class="ref-item">$node</p>
The IP address or computer name of the node of the current [environment](environments.html) currently executing a [role](roles.html) script.

<p class="ref-upper">Examples</p>
<p>Example environment script.</p>
{% highlight powershell %}
param($target, $config)
@{
  Databases = @('x.x.x.1', 'x.x.x.2')
}
{% endhighlight %}

<p>Example of a role script printing the current node to the console.</p>
{% highlight powershell %}
param($target, $config, $node)
Delivery:Role {

  # Displays "x.x.x.1" or "x.x.x.2" depending on 
  # which node the role is executing on
  Write-Host $node
}
{% endhighlight %}

<a name="Cmdlets"></a>

## Cmdlets

Cmdlets are Powershell functions included with powerdelivery generate files and run commands within [roles](roles.html).

<hr />

<a name="new_deliveryproject_cmdlet"></a>

<p class="ref-item">New-DeliveryProject</p>
Generates a new powerdelivery project. Typicall run at the root of a folder with source code (git, TFS, whatever).

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-ProjectName</dt>
	<dd>The required name of the project. A folder with this name suffixed with "Delivery" will be created containing the project.</dd>
	<dt>-Environments</dt>
	<dd>An optional array of strings with the names of the environments.</dd>
</dl>
<p class="ref-upper">Examples</p>

<p>Example of creating a project named <i>MyApp</i> with three environments.</p>
{% include console_title.html %}
<div class="console">
	{% highlight powershell %}
PS> New-DeliveryProject MyApp @('Local', 'Test', 'Production')
{% endhighlight %}
</div>

<br />

<a name="start_delivery_cmdlet"></a>

<p class="ref-item">Start-Delivery</p>
Starts a run of a [target](targets.html) using powerdelivery. Must be run at the directory above your powerdelivery project.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-ProjectName</dt>
	<dd>The required name of the project. Powerdelivery looks for a subdirectory with this name suffixed with "Delivery".</dd>
	<dt>-TargetName</dt>
	<dd>The name of the target to run. Must match the name of a file in the <i>Targets</i> subdirectory of your powerdelivery project without the file extension.</dd>
	<dt>-EnvironmentName</dt>
	<dd>The name of the environment to target during the run. Must match the name of a file in the <i>Environments</i> subdirectory of your powerdelivery project without the file extension.</dd>
	<dt>-As</dt>
	<dd>The username of a Windows account to run remote <a href="roles.html">roles</a> as. You will be prompted for the password.</dd>
	<dt>-UseCredentials</dt>
	<dd>The username of a Windows account to run remote <a href="roles.html">roles</a> as. Powerdelivery will look for encrypted <a href="credentials.html">credentials</a> in the *Credentials* subdirectory of your powerdelivery project, and a key file matching the subdirectory the credentials are in.</dd>
</dl>
<p class="ref-upper">Examples</p>

<p>Example of starting delivery of the <i>MyApp</i> project targeting <i>Release</i> to the <i>Production</i> environment as the <i>DOMAIN\opsuser</i> Windows user account.</p>
{% include console_title.html %}
<div class="console">
	{% highlight powershell %}
PS> Start-Delivery MyApp Release Production -As 'DOMAIN\opsuser'
{% endhighlight %}
</div>