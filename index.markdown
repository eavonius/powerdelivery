---

layout: page

---

<div id="corner-cloud-text">Devops-friendly<br/>Windows releases<br/>on-premise or<br/>in the cloud.</div>
<img id="corner-cloud" src="img/corner_cloud.png" />

<div class="row" style="margin-top: 80px">
	<div class="col-sm-12">
		<h1 align="center" style="border-bottom: 0px; font-size: 60px"><span style="color: firebrick">goodbye</span>, manual releases.</h1>
		<p style="font-size: 20px; line-height: 1.7">Inspired by tools like <a href="http://www.ansible.com" target="_blank">ansible</a>, <a href="https://www.chef.io" target="_blank">chef</a>, and <a href="https://www.puppetlabs.com" target="_blank">puppet</a> - powerdelivery is a simple framework for continuous deployment. It orchestrates everything Windows Powershell does within a secure, convention-based framework so you can stop being jealous of your linux friends when you deploy to Windows.</p>
	</div>
</div>

<h1 style="font-weight: normal">on-premise website at a glance</h1>

## Install
<div class="row">
  <div class="col-sm-8">
    <div class="console">{% highlight powershell %}choco install powerdelivery{% endhighlight %}</div>
  </div>
</div>
	
## Create a project
<div class="row">
  <div class="col-sm-8">
    <div class="console">{% highlight powershell %}pow:New 'MyApp' @('Local', 'Production'){% endhighlight %}</div>
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
  Website = ('x.x.x.3','x.x.x.4','x.x.x.5')
}
{% endhighlight %}

## Configure variables
<p class="small" align="right">MyAppDelivery\Configuration\_Shared.ps1</p>
{% highlight powershell %}
@{
  SourceCodeRoot = '..\';
  ReleasesPath = '\\x.x.x.6\MyProduct\Releases'
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Configuration\Local.ps1</p>
{% highlight powershell %}
@{
  DatabaseName = "MyApp_Development";
  SiteURL = "http://myapp.cloudapp.net";
  ReleasesPath = 'Releases'
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Configuration\Production.ps1</p>
{% highlight powershell %}
@{
  DatabaseName = "MyApp";
  SiteURL = "http://www.myapp.com"
}
{% endhighlight %}

## Create roles
<p class="small" align="right">MyAppDelivery\Roles\Compile\Tasks.ps1</p>
{% highlight powershell %}
pow:Role {
  param($Target, $Config, $Node)

  Invoke-MSBuild -ProjectFile "$($Config.SourceCodeRoot)MyApp.sln"
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Roles\Package\Tasks.ps1</p>
{% highlight powershell %}
pow:Role {
  param($Target, $Config, $Node)

  $StartedAt = $Target.StartedAt
  $ReleasesPath = $Config.ReleasesPath

  # Push compiled assets to a network drive
  # that the database and webservers can access
  Copy-Item -Path $Config.SourceCodeRoot `
            -Filter "*.dll;*.pdb;*.xml;*.config;*.sql" `
            -Destination "$ReleasesPath\MyApp\$StartedAt" `
            -Recurse
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Roles\Database\Tasks.ps1</p>
{% highlight powershell %}
pow:Role {
  param($Target, $Config, $Node)

  $StartedAt = $Target.StartedAt
  $ReleasesPath = $Config.ReleasesPath
  $AppDataDir = [Environment]::GetFolderPath("ApplicationData")
  $RemoteScriptsPath = "$AppDataDir\MyApp\Scripts\$StartedAt"

  # Copy sql scripts to a sub-directory of the 
  # current user's ApplicationData directory
  Copy-Item -Path "$ReleasesPath\MyApp\$StartedAt\MyAppDatabase\bin\Release\" `
            -Destination $RemoteScriptsPath

  # Run pending SQL migration scripts
  osql -E $Config.DatabaseName -I $RemoteScriptsPath
}
{% endhighlight %}
<p class="small" align="right">MyAppDelivery\Roles\Website\Tasks.ps1</p>
{% highlight powershell %}
pow:Role {
  param($Target, $Config, $Node)

  $StartedAt = $Target.StartedAt
  $ReleasesPath = $Config.ReleasesPath
  $AppDataDir = [Environment]::GetFolderPath("ApplicationData")
  $RemoteSitePath = "$AppDataDir\MyApp\Site\$StartedAt"

  # Copy web content to a sub-directory of the 
  # current user's ApplicationData directory
  Copy-Item -Path "$ReleasesPath\MyApp\$StartedAt\MyApp\bin\Release\" `
            -Destination $RemoteSitePath

  Add-PSSnapin WebAdministration

  $ExistingSite = Get-Website -Name 'MyApp'

  # Remove the existing site if it exists
  if ($ExistingSite) {
    Remove-WebApplication -Name 'MyApp' -Site 'MyApp'
  }

  # Create the web application
  New-WebApplication -Site 'MyApp' `
                     -Name 'MyApp' `
                     -PhysicalPath $RemoteSitePath `
                     -Force
}
{% endhighlight %}

## Configure target
<p class="small" align="right">MyAppDelivery\Targets\Release.ps1</p>
{% highlight powershell %}
[ordered]@{
  BuildProduct = @{
    Roles = ('Compile','Package');
    Nodes = ('Build')
  };
  DeployDatabase = @{
    Roles = ('Database');
    Nodes = ('Database')
  };
  DeployWebsite = @{
    Roles = ('Website');
    Nodes = ('Website')
  }
}
{% endhighlight %}

<div class="row">
  <div class="col-sm-6">
    <h2>Release locally</h2>
    <div class="console">{% highlight powershell %}pow Release Local{% endhighlight %}</div>
  </div>
  <div class="col-sm-6">
    <h2>Release to production</h2>
    <div class="console">{% highlight powershell %}pow Release Production `
    -As MYDOMAIN\opsuser{% endhighlight %}</div>
  </div>
</div>

<br />

## Now [get started](getting-started.html) with your own release!