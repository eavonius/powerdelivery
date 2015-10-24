---
layout: page
---

# Reference
	
This page contains reference for the script parameters and cmdlets included with powerdelivery.

<br />

<div class="row">
	<div class="col-sm-8">
		<div class="panel panel-default">
			<div class="panel-heading">
				<div class="panel-title">Cmdlets</div>
			</div>
			<div class="panel-body">
				<b>Commands</b>
				<ul class="nav">
					<li>
						<a href="#start_delivery_cmdlet">Start-Delivery</a>
					</li>
				</ul>
				<b>Generators</b>
				<ul class="nav">
					<li>
						<a href="#new_deliveryproject_cmdlet">New-DeliveryProject</a>
					</li>
					<li>
						<a href="#new_deliveryrole_cmdlet">New-DeliveryRole</a>
					</li>
					<li>
						<a href="#new_deliveryrolemigration_cmdlet">New-DeliveryRoleMigration</a>
					</li>
				</ul>
				<b>Secrets</b>
				<ul class="nav">
					<li>
						<a href="#new_deliverykey_cmdlet">New-DeliveryKey</a>
					</li>
					<li>
						<a href="#new_deliverycredential_cmdlet">New-DeliveryCredential</a>
					</li>
					<li>
						<a href="#new_deliverysecret_cmdlet">New-DeliverySecret</a>
					</li>
				</ul>
				<b>In Roles</b>
				<ul class="nav">
					<li>
						<a href="#invoke_msbuild_cmdlet">Invoke-MSBuild</a>
					</li>
					<li>
						<a href="#test_commandexists_cmdlet">Test-CommandExists</a>
					</li>
				</ul>
			</div>
		</div>
	</div>
	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading">
				<div class="panel-title">Script parameters</div>
			</div>
			<div class="panel-body">
				<ul class="nav">				
					<li>
						<a href="#shared_parameter">$shared</a>
					</li>
					<li>
						<a href="#config_parameter">$config</a>
					</li>
					<li>
						<a href="#node_parameter">$node</a>
					</li>
					<li>
						<a href="#target_parameter">$target</a>
					</li>
				</ul>
			</div>
		</div>
	</div>
</div>

<a name="Cmdlets"></a>

## Cmdlets

Cmdlets are PowerShell functions included with powerdelivery generate files and run commands within [roles](roles.html).

<hr />

<a name="start_delivery_cmdlet"></a>

<p class="ref-item">Start-Delivery</p>
Starts a run of a [target](targets.html) using powerdelivery. Must be run in the parent directory of your powerdelivery project.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-ProjectName</dt>
	<dd>The required name of the project. Powerdelivery looks for a subdirectory with this name suffixed with "Delivery".</dd>
	<dt>-TargetName</dt>
	<dd>The name of the target to run. Must match the name of a file in the <i>Targets</i> subdirectory of your powerdelivery project without the file extension.</dd>
	<dt>-EnvironmentName</dt>
	<dd>The name of the environment to target during the run. Must match the name of a file in the <i>Environments</i> subdirectory of your powerdelivery project without the file extension.</dd>
	<dt>-Properties</dt>
	<dd>A hash of properties to pass to the target. Typically used to pass information from build servers.</dd>
	<dt>-Rollback</dt>
	<dd>Causes powerdelivery to run the <i>-Down</i> block of roles instead of <i>-Up</i>, performing a rollback.</dd>
</dl>
<p class="ref-upper">Examples</p>

<p>Example of starting delivery of the <i>MyApp</i> project targeting <i>Release</i> to the <i>Production</i> environment.</p>
{% include console_title.html %}
<div class="console">
	{% highlight powershell %}
PS C:\MyApp> Start-Delivery MyApp Release Production
{% endhighlight %}
</div>

<br />

<a name="new_deliveryproject_cmdlet"></a>

<p class="ref-item">New-DeliveryProject</p>
Generates a new powerdelivery project. Typically run at the root of a folder with source code (git, TFS, whatever).

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
PS C:\MyApp> New-DeliveryProject MyApp "Local", "Test", "Production"
{% endhighlight %}
</div>

<br />

<a name="new_deliveryrole_cmdlet"></a>

<p class="ref-item">New-DeliveryRole</p>
Generates a new powerdelivery role. Must be run in the root directory of your powerdelivery project.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-RoleNames</dt>
	<dd>A comma-separated list of one or more names of roles to create.</dd>
</dl>

The role will be created at the path:

<pre>
.\Roles\&lt;RoleName&gt;
</pre>

<p class="ref-upper">Examples</p>

<p>Example of creating a role named <i>DeployDatabase</i>.</p>
{% include console_title.html %}
<div class="console">
	{% highlight powershell %}
PS C:\MyApp\MyAppDelivery> New-DeliveryRole Database
Role created at ".\MyAppDelivery\Roles\Database"
{% endhighlight %}
</div>

<br />

<a name="new_deliveryrolemigration_cmdlet"></a>

<p class="ref-item">New-DeliveryRoleMigration</p>
Generates a new powerdelivery role migration. Must be run in the root directory of your powerdelivery project.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-RoleName</dt>
	<dd>The name of the role to add the migration script to.</dd>
	<dt>-MigrationName</dt>
	<dd>The name of the activity being performed in the migration. Spaces will be replaced with underscores and a timestamp will be added to the prefix of the filename</dd>
</dl>
<p class="ref-upper">Examples</p>

<p>Example of creating migration for a role named <i>Load Balancer</i> that will update a route.</p>
{% include console_title.html %}
<div class="console">
	{% highlight powershell %}
PS C:\MyApp\MyAppDelivery> New-DeliveryRoleMigration LoadBalancer "Update Route"
Role migration created at ".\MyAppDelivery\Roles\LoadBalancer\Migrations\20151019_112811_Update_Route.ps1"
{% endhighlight %}
</div>

<br />

<a name="new_deliverykey_cmdlet"></a>

<p class="ref-item">New-DeliveryKey</p>
Generates a key file used to encrypt [secrets](secrets.html). 

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-KeyName</dt>
	<dd>The name of the key to generate.</dd>
</dl>

The key will be created at the path:

<pre>
&lt;Drive&gt;:\Users\&lt;User&gt;\Documents\PowerDelivery\Keys\&lt;Project&gt;\&lt;KeyName&gt;.key
</pre>

<p class="ref-upper">Examples</p>

<p>Example of creating a key named <i>MyKey</i> for use in encrypting secrets.</p>
{% include console_title.html %}
<div class="console">
{% highlight powershell %}
PS C:\MyApp> New-DeliveryKey MyKey
Key written to "C:\Users\Jayme\Documents\PowerDelivery\Keys\MyApp\MyKey.key"
{% endhighlight %}
</div>

<br />

<a name="new_deliverycredential_cmdlet"></a>

<p class="ref-item">New-DeliveryCredential</p>
Encrypts a set of [credentials](secrets.html#using_secrets_for_credentials) with a key and adds them to a powerdelivery project. Must be run in the root directory of your powerdelivery project.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-KeyName</dt>
	<dd>The name of the key to use for encryption.</dd>
	<dt>-UserName</dt>
	<dd>The username of the account to encrypt the password for.</dd>
</dl>

The credential will be created at the path:

<pre>
.\Secrets\&lt;KeyName&gt;\Credentials\&lt;UserName&gt;.credential
</pre>

<p class="ref-upper">Examples</p>

<p>Example of creating a credential using a key named <i>MyKey</i>.</p>
{% include console_title.html %}
<div class="console">
{% highlight powershell %}
PS C:\MyApp\MyAppDelivery> New-DeliveryCredential MyKey "MYDOMAIN\myuser"
Enter the password for MYDOMAIN\myuser and press ENTER:
**********
Credentials written to ".\Secrets\MyKey\Credentials\MYDOMAIN#myuser.credential"
{% endhighlight %}
</div>

<br />

<a name="new_deliverysecret_cmdlet"></a>

<p class="ref-item">New-DeliverySecret</p>
Encrypts a [secret](secrets.html) with a key and adds it to a powerdelivery project. Must be run in the root directory of your powerdelivery project.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-KeyName</dt>
	<dd>The name of the key to use for encryption.</dd>
	<dt>-SecretName</dt>
	<dd>The name of the secret to encrypt.</dd>
	<dt>-Force</dt>
	<dd>Switch that forces overwrite of any existing secret file if found.</dd>
</dl>

The secret will be created at the path:

<pre>
.\Secrets\&lt;KeyName&gt;\&lt;SecretName&gt;.secret
</pre>

<p class="ref-upper">Examples</p>

<p>Example of creating a secret using a key named <i>MyKey</i>.</p>
{% include console_title.html %}
<div class="console">
{% highlight powershell %}
PS C:\MyApp\MyAppDelivery> New-DeliverySecret MyKey MySecret
Enter the secret value for MySecret and press ENTER:
**********
Secret written to ".\Secrets\MyKey\MySecret.secret"
{% endhighlight %}
</div>

<br />

<a name="invoke_msbuild_cmdlet"></a>

<p class="ref-item">Invoke-MSBuild</p>
Compiles a project using msbuild.exe.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-ProjectFile</dt>
	<dd>A relative path to the directory <i>above</i> your powerdelivery project that specifies an MSBuild project or solution to compile.</dd>
	<dt>-Properties</dt>
	<dd>Optional. A PowerShell hash containing name/value pairs to set as MSBuild properties.</dd>
	<dt>-Target</dt>
	<dd>Optional. The name of the MSBuild target to invoke in the project file. Defaults to the default target specified within the project file.</dd>
	<dt>-ToolsetVersion</dt>
	<dd>Optional. The version of MSBuild to run ("2.0", "3.5", "4.0", etc.). The default is "4.0".</dd>
	<dt>-Verbosity</dt>
	<dd>Optional. The verbosity of this MSBuild compilation. The default is "m".</dd>
	<dt>-BuildConfiguration</dt>
	<dd>Optional. The build configuration (Debug/Release typically) to compile with. Defaults to <i>Release</i>.</dd>
	<dt>-Flavor</dt>
	<dd>Optional. The platform configuration (x86, x64 etc.) of this MSBuild complation. The default is <i>AnyCPU</i>.</dd>
	<dt>-IgnoreProjectExtensions</dt>
	<dd>Optional. A semicolon-delimited list of project extensions (".smproj;.csproj" etc.) of projects in the solution to not compile.</dd>
</dl>
<p class="ref-upper">Examples</p>

<p>Example of invoking msbuild.</p>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  Invoke-MSBuild MyProject/MyProject.csproj -Flavor x64 -properties @{MyCustomProp = SomeValue}
}
{% endhighlight %}

<br />

<a name="test_commandexists_cmdlet"></a>

<p class="ref-item">Test-CommandExists</p>
Tests whether a command (PowerShell or regular command line) is available in the PATH. Returns $true if present, $false if not.

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-CommandName</dt>
	<dd>The name of the command to test for the presence of.</dd>
</dl>
<p class="ref-upper">Examples</p>

<p>Example of testing for the presence of the nodejs package manager.</p>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  if (Test-Command npm) {
    Write-Host "Node package manager is installed!"
  }
}
{% endhighlight %}

<br />

<a name="script_parameters"></a>

## Script Parameters

The scripts you work with in powerdelivery take a number of parameters that help your releases go smoothly.

<hr />

<a name="shared_parameter"></a>

<p class="ref-item">$shared</p>
A hash containing the [variables](variables.html) from the shared variables file, allowing it to be referenced in an environment variables file.

<p class="ref-upper">Examples</p>
<p>Example of a shared configuration script defining a variable.</p>
{% highlight powershell %}
param($target)
@{
  SomeDirectory = "C:\Parent"
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Configuration\_Shared.ps1</div>

<p>Example of a production environment configuration script referencing the shared variable.</p>
{% highlight powershell %}
param($target, $shared)
@{
  # SomeDirectoryChild would be C:\Parent\Child 
  # when targeting the Production environment
  SomeDirectoryChild = "$($shared.SomeDirectory)\Child"
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Configuration\_Production.ps1</div>

<br />

<a name="config_parameter"></a>

<p class="ref-item">$config</p>
A hash containing the [variables](variables.html) of the current run.

<p class="ref-upper">Examples</p>
<p>Example of a configuration script defining two variables.</p>
{% highlight powershell %}
param($target, $config)
@{
  Hello = "Hello";
  World = "World"
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Configuration\Production.ps1</div>

<p>Example of a role script using the $config parameter to reference the configuration above.</p>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  # Prints "Hello World" to the console
  Write-Host "$($config.Hello) $($config.World)"
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Roles\ConfigExample\Role.ps1</div>

<br />

<a name="node_parameter"></a>

<p class="ref-item">$node</p>
The IP address, computer name, domain name, or connection URI of the node in the current [environment](environments.html) which is currently executing a [role](roles.html) script.

<p class="ref-upper">Examples</p>
<p>Example environment script.</p>
{% highlight powershell %}
param($target, $config)
@{
  Databases = @{
    Hosts = "x.x.x.1", "x.x.x.2"
  }
}
{% endhighlight %}

<p>Example of a role script printing the current node to the console.</p>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  # Displays "x.x.x.1" or "x.x.x.2" depending on 
  # which host the role is executing on
  Write-Host $node
}
{% endhighlight %}

<br />

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
	<dt>RequestedBy</dt>
	<dd>The username of the Windows account that started the run.</dd>
	<dt>StartDate</dt>
	<dd>A timestamp of when the run started as a DateTime object.</dd>
	<dt>StartedAt</dt>
	<dd>A timestamp of when the run started in the format yyyyMMdd_hhmmss.</dd>
	<dt>Properties</dt>
	<dd>The hash of properties passed into <a href="#start_delivery_cmdlet">Start-Delivery</a>. Typically used to get information from build servers.</dd>
	<dt>Credentials</dt>
	<dd>A dictionary (hash) containing the <a href="secrets.html#using_secrets_for_credentials">credentials</a> that were loaded at startup. The key of the hash is the username of the credential.</dd>
	<dt>Secrets</dt>
	<dd>A dictionary (hash) containing the <a href="secrets.html">secrets</a> that were loaded during startup. The key of the hash is the name of the secret.
</dl>

<p class="ref-upper">Examples</p>

<p>Example of a role script using the $target parameter.</p>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  # Access run properties using $target and print them to the console
  Write-Host "I'm deploying $($target.ProjectName) started by $($target.RequestedBy)."

  # Lookup credentials using $target
  $opsCredentials = $target.Credentials["DOMAIN\opsuser"]

  # Lookup a secret using $target
  $facebookAPIKey = $target.Secrets.FacebookAPIKey
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Roles\TargetExample\Role.ps1</div>