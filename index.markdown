---
layout: page
title: Devops-friendly Windows releases on-premise or in the cloud.
---

<div id="corner-cloud-text">Devops-friendly<br/>Windows releases<br/>on-premise or<br/>in the cloud.</div>
<img id="corner-cloud" src="img/corner_cloud.png" />

<div class="row" style="margin-top: 80px">
	<div class="col-sm-12">
		<h1 id="site-title"><span style="color: firebrick">Goodbye,</span> manual releases.</h1>
		<p id="site-summary">Inspired by <a href="http://www.ansible.com" target="_blank">ansible</a> and <a href="http://rubyonrails.org" target="_blank">rails</a>, powerdelivery organizes everything Windows PowerShell can do within a secure, convention-based framework so you can stop being jealous of your linux friends when you deploy to Windows.</p>
	</div>
</div>

<h1 style="font-weight: normal">A birds-eye view</h1>

Before you read the docs, see some code.

## Creating a project
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp> New-DeliveryProject MyApp "Local", "Production"
Project successfully created at ".\MyAppDelivery"
{% endhighlight %}
</div>
  </div>
</div>

## Configuring [variables](variables.html)
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target) {
@{
  ReleasesPath = "\\MyShare\MyProduct\Releases"
}
{% endhighlight %}
    <div class="filename">MyAppDelivery\Configuration\_Shared.ps1</div>
  </div>
</div>
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $shared)
@{
  DatabaseName = "MyApp_Development";
  SiteURL = "http://myapp.cloudapp.net";
  ReleasesPath = "Releases"
}
{% endhighlight %}
    <div class="filename">MyAppDelivery\Configuration\Local.ps1</div>
  </div>
</div>
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $shared)
@{
  DatabaseName = "MyApp";
  SiteURL = "http://www.myapp.com"
}
{% endhighlight %}
    <div class="filename">MyAppDelivery\Configuration\Production.ps1</div>
  </div>
</div>

## Configuring [environments](environments.html)
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Build = @{
    Hosts = "localhost"
  };
  Database = @{
    Hosts = "localhost"
  };
  Website = @{
    Hosts = "localhost"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Local.ps1</div>
  </div>
</div>
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Build = @{
    Hosts = "localhost"
  };
  Database = @{
    Hosts = "x.x.x.2"
  };
  Website = @{
    Hosts = "x.x.x.3", "x.x.x.4"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Production.ps1</div>
  </div>
</div>

## Creating [roles](roles.html)
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
<div class="filename">MyAppDelivery\Roles\Compile\Always.ps1</div>
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
<div class="filename">MyAppDelivery\Roles\Database\Always.ps1</div>
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
<div class="filename">MyAppDelivery\Roles\Website\Always.ps1</div>

## Configuring a [target](targets.html)

{% highlight powershell %}
[ordered]@{
  "Building the product" = @{
    Roles = "Build";
    Nodes = "Build"
  };
  "Deploying databases" = @{
    Roles = "Database";
    Nodes = "Database"
  };
  "Deploying the website" = @{
    Roles = "Website";
    Nodes = "Website"
  }
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Targets\Release.ps1</div>

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
    <h2>Delivering locally</h2>
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp> Start-Delivery MyApp Release Local

PowerDelivery v3.0.1
Target "Release" started by MYDOMAIN\me
Delivering "MyApp" to "Local" environment...

[----- Building the product
[--------- Build -> (localhost)
[----- Deploying databases
[--------- Database -> (localhost)
[----- Deploying the website
[--------- Website -> (localhost)

Target "Release" succeeded in 10 sec 453 ms.
{% endhighlight %}
    </div>
  </div>
</div>

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
    <h2>Delivering to production</h2>
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp> Start-Delivery MyApp Release Production -As "MYDOMAIN\opsuser"

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

Target "Release" succeeded in 1m 13 sec 56 ms.
{% endhighlight %}
    </div>
  </div>
</div>

<br />

## Now [get started](getting-started.html) automating your own releases!