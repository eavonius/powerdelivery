---
layout: page
title: Devops-friendly Windows releases on-premise or in the cloud.
---

<div id="corner-cloud-text">Devops-friendly<br/>Windows releases<br/>on-premise or<br/>in the cloud.</div>
<img id="corner-cloud" src="img/corner_cloud.png" />

<div class="row" style="margin-top: 80px">
	<div class="col-sm-12">
		<h1 id="site-title"><span style="color: firebrick">Goodbye</span>, manual releases.</h1>
		<p style="font-size: 20px; line-height: 1.7">Inspired by tools like <a href="http://www.ansible.com" target="_blank">ansible</a>, <a href="https://www.chef.io" target="_blank">chef</a>, and <a href="https://www.puppetlabs.com" target="_blank">puppet</a>; powerdelivery is a simple framework for continuous deployment. It organizes everything Windows Powershell can do into a secure, convention-based framework so you can stop being jealous of your linux friends when you deploy to Windows.</p>
	</div>
</div>

<h1 style="font-weight: normal">A birds-eye view</h1>

Before you read the docs, see some code.

## Create a project
<div class="row">
  <div class="col-sm-8">
    {% include console_title.html %}
    <div class="console">{% highlight powershell %}PS> New-DeliveryProject 'MyApp' @('Local', 'Production'){% endhighlight %}</div>
  </div>
</div>

## Configure [environments](environments.html)
<div class="row">
  <div class="col-sm-8">
  <div class="filename">MyAppDelivery\Environments\Local.ps1</div>
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
  <div class="filename">MyAppDelivery\Environments\Production.ps1</div>
{% highlight powershell %}
@{
  Build = ('localhost');
  Database = ('x.x.x.2');
  Website = ('x.x.x.3','x.x.x.4')
}
{% endhighlight %}
  </div>
</div>

## Configure [variables](configuration.html)
<div class="filename">MyAppDelivery\Configuration\_Shared.ps1</div>
{% highlight powershell %}
@{
  ReleasesPath = '\\x.x.x.6\MyProduct\Releases'
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Configuration\Local.ps1</div>
{% highlight powershell %}
param($shared)
@{
  DatabaseName = "MyApp_Development";
  SiteURL = "http://myapp.cloudapp.net";
  ReleasesPath = 'Releases'
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Configuration\Production.ps1</div>
{% highlight powershell %}
param($shared)
@{
  DatabaseName = "MyApp";
  SiteURL = "http://www.myapp.com"
}
{% endhighlight %}

## Create [roles](roles.html)
<div class="filename">MyAppDelivery\Roles\Compile\Build.ps1</div>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  # Compile a Visual Studio solution
  Invoke-MSBuild MyApp.sln

  # Copy compiled assets to a network drive, 
  # S3 bucket, or wherever the remote nodes can access
  Copy-Item . $releasePath -Filter "*.dll;*.pdb;*.xml;*.config;*.sql" -Recurse
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Roles\Database\Role.ps1</div>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  $appDataDir = [Environment]::GetFolderPath("ApplicationData") 
  $releasePath = "$($config.ReleasesPath)\MyApp\$($target.StartedAt)\MyAppDatabase\bin\Release\"
  $localPath = "$AppDataDir\MyApp\Scripts\$($target.StartedAt)"

  # Copy sql scripts from the network drive to the database node
  Copy-Item $releasePath $localPath -Filter *.* -Recurse

  # Run some SQL scripts
  foreach ($script in (Get-ChildItem $localPath)) {
    Invoke-Expression "sqlcmd -E -d $($config.DatabaseName) -i $script"
  }
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Roles\Website\Role.ps1</div>
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  $appDataDir = [environment]::GetFolderPath("ApplicationData")
  $releasePath = "$($config.ReleasesPath)\MyApp\$($target.StartedAt)\MyApp\publish\"
  $localPath = "$AppDataDir\MyApp\Site\$($target.StartedAt)"

  # Copy web content from the network drive to the database node
  Copy-Item $releasePath $localPath -Filter *.* -Recurse

  Add-PSSnapin WebAdministration

  # Create the web application
  New-WebApplication $config.Website MyApp $localPath -Force
}
{% endhighlight %}

## Configure a [target](targets.html)
<div class="filename">MyAppDelivery\Targets\Release.ps1</div>
{% highlight powershell %}
[ordered]@{
  "Building the product" = @{
    Roles = ('Build');
    Nodes = ('Build')
  };
  "Deploying databases" = @{
    Roles = ('Database');
    Nodes = ('Database')
  };
  "Deploying the website" = @{
    Roles = ('Website');
    Nodes = ('Website')
  }
}
{% endhighlight %}

<div class="row">
  <div class="col-sm-8">
    <h2>Release locally</h2>
    <div class="console">
{% highlight powershell %}
Start-Delivery MyApp Release Local

PowerDelivery v3.0.1
Target "Release" started by MYDOMAIN\me
Delivering "MyApp" to "Local" environment...

[----- Building the product
[--------- Build -> (localhost)
[----- Deploying databases
[--------- Database -> (localhost)
[----- Deploying the website
[--------- Website -> (localhost)

Target "Release" succeeded in 18 sec 453 ms.
{% endhighlight %}
    </div>
  </div>
</div>

<div class="row">
  <div class="col-sm-8">
    <h2>Release to production</h2>
    <div class="console">
{% highlight powershell %}
Start-Delivery MyApp Release Production -As 'MYDOMAIN\opsuser'

PowerDelivery v3.0.1
Target "Release" started by MYDOMAIN\opsuser
Delivering "MyApp" to "Production" environment...

[----- Building the product
[--------- Build -> (localhost)
[----- Deploying databases
[--------- Database -> (x.x.x.2)
[----- Deploying the website
[--------- Website -> (x.x.x.3)
[--------- Website -> (x.x.x.4)

Target "Release" succeeded in 1m 43 sec 56 ms.
{% endhighlight %}
    </div>
  </div>
</div>

<br />

## Now [get started](getting-started.html) automating your own releases!