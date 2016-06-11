---
layout: page
title: Devops-friendly Windows releases on-premise or in the cloud.
---

<div id="corner-cloud-text">Devops-friendly<br/>Windows releases<br/>on-premise or<br/>in the cloud.</div>
<img id="corner-cloud" src="img/corner_cloud.png" />

<div class="row" style="margin-top: 80px">
	<div class="col-sm-12">
		<h1 id="site-title"><span style="color: firebrick">Goodbye,</span> manual releases.</h1>
		<p id="site-summary">Inspired by <a href="http://www.ansible.com" target="_blank">ansible</a> and <a href="http://rubyonrails.org" target="_blank">rails</a>, powerdelivery organizes everything Windows PowerShell can do within a secure, convention-based framework so you can stop being jealous of your linux friends when you release to Windows.</p>
	</div>
</div>

<p id="features">pure powershell | rollback-capable | encrypts secrets | open source</p>

<p align="center">To discuss powerdelivery 
<a href="https://gitter.im/eavonius/powerdelivery?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge&amp;utm_content=body_badge"><img src="https://camo.githubusercontent.com/5ad685a80908a009eddac405ba0d83ef18bfd4dd/68747470733a2f2f6261646765732e6769747465722e696d2f6561766f6e6975732f706f77657264656c69766572792e737667" alt="Gitter" style="max-width:100%;"></a>
anyone can join!
<br />
</p>

<h1 style="font-weight: normal">A birds-eye view</h1>

Before you read the docs, see some code.

## Create a project
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

## Set [variables](variables.html)
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $shared)
@{
  SiteURL = "http://myapp.cloudapp.net";
  ReleasesPath = ".\Releases"
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
  SiteURL = "http://www.myapp.com";
  ReleasesPath = "\\MyShare\MyProduct\Releases"
}
{% endhighlight %}
    <div class="filename">MyAppDelivery\Configuration\Production.ps1</div>
  </div>
</div>

## Configure [environments](environments.html)
<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
param($target, $config)
@{
  Build = @{
    Hosts = "localhost"
  };
  Web = @{
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
  Web = @{
    Hosts = "x.x.x.3", "x.x.x.4";
    Credential = "MYDOMAIN\ops"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Environments\Production.ps1</div>
  </div>
</div>

## Create [roles](roles.html)

<div class="row">
  <div class="col-sm-8">
{% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp\MyAppDelivery> New-DeliveryRole "Compile", "Webapp"
Role created at ".\Roles\Compile"
Role created at ".\Roles\Webapp"
{% endhighlight %}
    </div>
  </div>
</div>

## Script [roles](roles.html)

{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  # Publish website into a directory
  Invoke-MSBuild MyApp.sln -properties @{DeployOnBuild = "true"; PublishProfile = "MyApp"}

  # \\SHARE\<ProjectName>\<StartedAt>
  $remotePath = "$($config.ReleasesPath)\$($target.ProjectName)\$($target.StartedAt)"

  # Copy website to a network drive, S3 bucket, 
  # or wherever the remote nodes can access
  Copy-Item "MyApp\bin\publish" $remotePath -Recurse
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Roles\Compile\Always.ps1</div>
{% highlight powershell %}
Delivery:Role -Up { 
  param($target, $config, $node)

  Import-Module PowerDeliveryNode
  Add-PSSnapin WebAdministration

  # \\SHARE\<ProjectName>\<StartedAt>
  $remotePath = "$($config.ReleasesPath)\$($target.ProjectName)\$($target.StartedAt)"

  # AppData\Roaming\MyApp\Current
  # (symlinked to AppData\Roaming\MyApp\yyyyMMdd_HHmmss)
  $appDataDir = [Environment]::GetFolderPath("ApplicationData")
  $releasePath = New-DeliveryReleasePath $target $appDataDir
  
  # Copy web content from the network drive to the current release
  Copy-Item $remotePath $releasePath -Filter *.* -Recurse

  # Create the web application
  New-WebApplication $config.SiteURL MyApp $releasePath -Force

} -Down { 
  param($target, $config, $node)
  
  Import-Module PowerDeliveryNode

  # Rollback AppData\Roaming\MyApp\Current to previous release
  $appDataDir = [Environment]::GetFolderPath("ApplicationData")
  Undo-DeliveryReleasePath $target $appDataDir
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Roles\Webapp\Always.ps1</div>

## Configure a [target](targets.html)

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
{% highlight powershell %}
[ordered]@{
  "Building the product" = @{
    Roles = "Compile";
    Nodes = "Build"
  };
  "Deploying the website" = @{
    Roles = "Webapp";
    Nodes = "Web"
  }
}
{% endhighlight %}
    <div class="filename">MyAppDelivery\Targets\Release.ps1</div>
  </div>
</div>

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
    <h2>Release locally</h2>
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp> Start-Delivery MyApp Release Local

PowerDelivery v3.0.1
Target "Release" started by MYDOMAIN\dev
Delivering "MyApp" to "Local" environment...

[----- Building the product
[--------- Compile -> (localhost)
[----- Deploying the website
[--------- Webapp -> (localhost)

Target "Release" succeeded in 10 sec 453 ms.
{% endhighlight %}
    </div>
  </div>
</div>

<div class="row">
  <div class="col-lg-8 col-md-10 col-sm-12">
    <h2>Release to production</h2>
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp> Start-Delivery MyApp Release Production

PowerDelivery v3.0.1
Target "Release" started by MYDOMAIN\ops
Delivering "MyApp" to "Production" environment...

[----- Building the product
[--------- Compile -> (localhost)
[----- Deploying the website
[--------- Webapp -> (x.x.x.3)
[--------- Webapp -> (x.x.x.4)

Target "Release" succeeded in 1m 13 sec 56 ms.
{% endhighlight %}
    </div>
  </div>
</div>

<br />

## Now [get started](getting-started.html) automating your own releases!