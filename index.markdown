---
layout: page
title: Devops-friendly Windows releases on-premise or in the cloud.
---

<div id="corner-cloud-text">Devops-friendly<br/>Windows releases<br/>on-premise or<br/>in the cloud.</div>
<img id="corner-cloud" src="img/corner_cloud.png" />

<div class="row" style="margin-top: 80px">
	<div class="col-sm-12">
		<h1 id="site-title"><span style="color: firebrick">goodbye</span>, manual releases.</h1>
		<p style="font-size: 20px; line-height: 1.7">Inspired by tools like <a href="http://www.ansible.com" target="_blank">ansible</a>, <a href="https://www.chef.io" target="_blank">chef</a>, and <a href="https://www.puppetlabs.com" target="_blank">puppet</a>; powerdelivery is a simple framework for continuous deployment. It organizes everything Windows Powershell can do into a secure, convention-based framework so you can stop being jealous of your linux friends when you deploy to Windows.</p>
	</div>
</div>

<h1 style="font-weight: normal">a birds-eye view</h1>

Before you read the docs, see some code.

## Install
<div class="row">
  <div class="col-sm-8">
    <div class="console">{% highlight powershell %}choco install powerdelivery{% endhighlight %}</div>
  </div>
</div>
	
## Create a project
<div class="row">
  <div class="col-sm-8">
    <div class="console">{% highlight powershell %}pow:new 'MyApp' @('Local', 'Production'){% endhighlight %}</div>
  </div>
</div>

## Configure environments
<p class="small" align="right">MyAppDelivery\Environments\Local.ps1</p>
{% highlight powershell %}
@{
  Build = ('localhost');
  Database = ('localhost');
  Website = ('localhost')
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Environments\Production.ps1</p>
{% highlight powershell %}
@{
  Build = ('localhost');
  Database = ('x.x.x.2');
  Website = ('x.x.x.3','x.x.x.4')
}
{% endhighlight %}

## Configure variables
<p class="small" align="right">MyAppDelivery\Configuration\_Shared.ps1</p>
{% highlight powershell %}
@{
  ReleasesPath = '\\x.x.x.6\MyProduct\Releases'
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Configuration\Local.ps1</p>
{% highlight powershell %}
param($shared)
@{
  DatabaseName = "MyApp_Development";
  SiteURL = "http://myapp.cloudapp.net";
  ReleasesPath = 'Releases'
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Configuration\Production.ps1</p>
{% highlight powershell %}
param($shared)
@{
  DatabaseName = "MyApp";
  SiteURL = "http://www.myapp.com"
}
{% endhighlight %}

## Create roles
<p class="small" align="right">MyAppDelivery\Roles\Compile\Build.ps1</p>
{% highlight powershell %}
pow:role {
  param($target, $config, $node)

  # Compile a Visual Studio solution
  invoke-msbuild myapp.sln

  # Copy compiled assets to a network drive
  # that the remote nodes can access
  copy . $releasePath -filter "*.dll;*.pdb;*.xml;*.config;*.sql" -recurse
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Roles\Database\Role.ps1</p>
{% highlight powershell %}
pow:role {
  param($target, $config, $node)

  $appDataDir = [environment]::getfolderpath("ApplicationData") 
  $releasePath = "$($config.ReleasesPath)\MyApp\$($target.StartedAt)\MyAppDatabase\bin\Release\"
  $localPath = "$AppDataDir\MyApp\Scripts\$($target.StartedAt)"

  # Copy sql scripts to a sub-directory of the 
  # current user's ApplicationData directory
  copy $releasePath $localPath -filter *.* -recurse

  # Run some SQL scripts
  gci $localPath | % { iex "sqlcmd -E -d $($config.DatabaseName) -i $_" }
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Roles\Website\Role.ps1</p>
{% highlight powershell %}
pow:role {
  param($target, $config, $node)

  $appDataDir = [environment]::getfolderpath("ApplicationData")
  $releasePath = "$($config.ReleasesPath)\MyApp\$($target.StartedAt)\MyApp\publish\"
  $localPath = "$AppDataDir\MyApp\Site\$($target.StartedAt)"

  # Copy web content to a sub-directory of the 
  # current user's ApplicationData directory
  copy $releasePath $localPath -filter *.* -recurse

  add-pssnapin webadministration

  # Create the web application
  new-webapplication $config.Website MyApp $localPath -force
}
{% endhighlight %}

## Configure target
<p class="small" align="right">MyAppDelivery\Targets\Release.ps1</p>
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
  "Deploy the website" = @{
    Roles = ('Website');
    Nodes = ('Website')
  }
}
{% endhighlight %}

<div class="row">
  <div class="col-sm-6">
    <h2>Release locally</h2>
    <div class="console">
{% highlight powershell %}
pow myapp release local

powerdelivery v3.0.1 started by MYDOMAIN\me
Running target "release" in "local" environment...

[----- Building the product
[--------- Build -> (localhost)
[----- Deploying databases
[--------- Database -> (localhost)
[----- Deploying the website
[--------- Website -> (localhost)

powerdelivery build succeeded in 18 sec 453 ms
{% endhighlight %}</div>
  </div>
  <div class="col-sm-6">
    <h2>Release to production</h2>
    <div class="console">
{% highlight powershell %}
pow myapp release production -as 'MYDOMAIN\opsuser'

powerdelivery v3.0.1 started by MYDOMAIN\opsuser
Running target "release" in "production" environment...

[----- Building the product
[--------- Build -> (localhost)
[----- Deploying databases
[--------- Database -> (x.x.x.2)
[----- Deploying the website
[--------- Website -> (x.x.x.3)
[--------- Website -> (x.x.x.4)

powerdelivery build succeeded in 1m 43 sec 56 ms
{% endhighlight %}
</div>
  </div>
</div>

<br />

## Now [get started](getting-started.html) automating your own releases!