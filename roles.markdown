---

layout: page

---

# Roles

When performing deployment activities with powerdelivery, the real work that applies changes to your nodes happens in roles. These are PowerShell scripts within the *Roles* directory of your project in their own directory named after the role.

## Generating roles

To assist with creating roles, you can use the [New-DeliveryRole](reference.html#new_deliveryrole_cmdlet) cmdlet to generate one for your project. Run this cmdlet in the directory above your powerdelivery project.

<br />

Below is an example of creating a role for installing the <a href="http://www.chocolatey.org" target="_blank">chocolatey</a> package manager:

<div class="row">
	<div class="col-sm-8">
		{% include console_title.html %}
		<div class="console">
{% highlight powershell %}
PS C:\MyApp\MyAppDelivery> New-DeliveryRole Chocolatey
Role created at ".\Roles\Chocolatey"
{% endhighlight %}
		</div>
	</div>
</div>

<br />

After this cmdlet completes it will have added the following to your directory structure:

<div class="row">
  <div class="col-sm-8">
    <pre class="directory-tree">
C:\MyApp\MyAppDelivery\
    |-- Roles\
        |-- Compile\
            |-- Always.ps1
            |-- Migrations\</pre>
  </div>
</div>

<br />

The contents of Always.ps1 as generated looks like this:

<div class="row">
  <div class="col-sm-8">
{% highlight powershell %}
Delivery:Role -Up {
  param($target, $config, $node)

  # Write PowerShell deployment logic here

} -Down {
  param($target, $config, $node)

  # Write PowerShell rollback logic here (if necessary)

}
{% endhighlight %}
  </div>
</div>


## Anatomy of a role script

Every role script must contain the *Delivery:Role* statement. After this statement, an *-Up* block specifies what will happen when a normal deployment occurs applying this role. If specified, a *-Down* block will run when you request a rollback while running the [Start-Delivery](reference.html#start_delivery_cmdlet) cmdlet. The down block is optional, and if you specify just one block without a name, it will be used as the up block.

<br />

The example below shows a script with only the default (up) block:

<div class="row">
  <div class="col-sm-8">
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  # Write PowerShell deployment logic here. 
  # This role doesn't support rollback.
}
{% endhighlight %}
  </div>
</div>

<br />

### Role script parameters

Every block in a role, whether performing an up or down (rollback), must declare three parameters. These are the [$target](reference.html#target_parameter), [$config](reference.html#config_parameter), and [$node](reference.html#node_parameter) parameters. These parameters provide context to where your role is running and will be very useful depending on what you're trying to do.

<br />

## Types of role scripts

There are two types of role scripts, which you can run both of or just one. Read the sections below to decide which makes the most sense for your particular infrastructure and release process.

<br />

### The "Always" role script

Always.ps1 runs, as so aptly named, every time the role is applied. If you are [provisioning nodes at deploy time](environments.html#provisioning_nodes_at_deploy_time) you can put all of your role logic here, as it will be applied to a fresh node every time you deploy; regardless of the target environment.

<br />

### Role migration scripts

If you are deploying to nodes that were provisioned ahead of time and are not to be re-created from scratch on each deployment, consider using role migration scripts. Role migration scripts are similar to data migrations in ruby on rails. They allow you to script a set of changes that will be made to a node and associated with a version, so the node upon which they are run remembers whether it was already applied.

Migration scripts are important because without them, if someone deploys changes to one environment (say, a development server) and then changes the script, the test environment may never get that change applied to it once it is deployed to. With migration scripts, changes are rolled forward in a predictable fashion.

<br />

**Generating a role migration script**

Use the [New-DeliveryRoleMigration](reference.html#new_deliveryrolemigration_cmdlet) cmdlet to add a role migration to an existing role in your project. The role you add the migration to must already have been created by the *New-DeliveryRole* cmdlet. Run this cmdlet in the directory above your powerdelivery project.

<br />

Below is an example of adding a migration script to a role named *Database*:

<div class="row">
  <div class="col-sm-10">
    {% include console_title.html %}
    <div class="console">
{% highlight powershell %}
PS C:\MyApp\MyAppDelivery> New-DeliveryRoleMigration MyApp Database "Truncate Logfile"
Role migration created at ".\MyAppDelivery\Roles\Database\Migrations\20151019_112811_Truncate_Logfile.ps1"
{% endhighlight %}
    </div>
  </div>
</div>

<br />

**Tips:** 

* The content of a role migration script is just like Always.ps1. You can specify just the up block, or both up and down.
* Always.ps1 runs *before* any migration scripts if present during a normal deployment.
* Always.ps1 runs *after* any migration scripts if present when rolling back.

<br />

## Common role tasks

Below are some examples of common tasks you might want to accomplish in roles.

<br />

### Installing dependencies

If a role is set to run on localhost, it may use any of the PowerShell cmdlets installed on a developer or build server computer. However, if a role runs on a remote computer, any PowerShell cmdlets you want to use need to be installed before you can use them. Many PowerShell cmdlets, including powerdelivery itself, are installed with the popular [chocolatey](http://www.chocolatey.org) package manager. 

Lets modify our script we generated at the beginning of this topic by editing the file *Always.ps1* to install chocolatey:

<br />

<div class="row">
  <div class="col-sm-10">
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  if (!(Test-CommandExists choco)) {
    $webClient = New-Object Net.WebClient
    Invoke-Expression $webClient.DownloadString('https://chocolatey.org/install.ps1')
    $path = $env:PATH
    $allUsersProfile = $env:ALLUSERSPROFILE
    $env:PATH = "$path;$allUsersProfile\chocolatey\bin"
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Roles\Chocolatey\Always.ps1</div>
  </div>
</div>

<br />

This role uses the [Test-CommandExists](reference.html#test_commandexists_cmdlet) cmdlet to only execute if chocolatey is not already available. Now if we want any remote node to have chocolatey installed, we can just apply the "Chocolatey" role to any nodes we want in a [target](targets.html) script. We can also add calls to the *choco* command-line client to install packages in this role, or another that is set to run after it in our target.

<br />

**Tip:** You may use the Web Platform Installer, OneGet, npm, rubygems, or whatever you need to install dependencies - chocolatey is just one example.

<a name="releasing_files"></a>

<br />

### Releasing files to a shared location

A commonly needed task is to deploy files to remote nodes for a release. This is two step process, where first you must copy the files from the computer running powerdelivery to a shared location, and then the [remote nodes download them](#downloading_release_files_to_nodes). The role described in this step would target localhost.

The example role below creates a directory named after the powerdelivery project on a shared drive somewhere on your network. It then creates a release directory with the timestamp of the current release where you can copy or download files needed for nodes to it. Depending on your infrastructure, you may wish to release files instead to a Windows Azure storage container, an Amazon Web Services S3 bucket, or DropBox.

The script below demonstrates releasing files:

<br />

<div class="row">
  <div class="col-sm-10">
{% highlight powershell %}
Delivery:Role {
  param($target, $config, $node)

  # An example share path.
  $sharePath = "\\COMPUTERNAME\share"

  # Reference a sub-directory named after the project
  $projectPath = Join-Path $sharePath $target.ProjectName

  # Create a directory for this release
  $thisReleasePath = Join-Path $projectPath $target.StartedAt
  if (!(Test-Path $thisReleasePath)) {
    New-Item $thisReleasePath -ItemType Directory | Out-Null
  }

  # TODO: Copy files from the local computer 
  # into $thisReleasePath here!
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Roles\ReleaseFiles\Always.ps1</div>
  </div>
</div>

<a name="downloading_release_files_to_nodes"></a>

<br />

### Downloading release files to nodes

Once files have been released to a shared location as [described above](#downloading_release_files_to_nodes), nodes that need any of the files should create a directory into which to copy or download them. To support rollback, it is necessary to retain the previous release's files when downloading. This role needs to run on any node that files are being downloaded to.

The example role below creates a directory named after the powerdelivery project within the user's *AppData\Roaming* directory. It then creates a release directory with the timestamp of the current release where you can copy or download files needed on the node. 

At the end of copying any files you'd need, the role links the release directory to a *Current* directory. This allows rollback by linking *Current* to the previous release in the *-Down* block. This role also retains only the previous 5 releases so the drive doesn't get littered with too many releases.

The script below demonstrates creating release directories:

<br />

<div class="row">
  <div class="col-sm-10">
{% highlight powershell %}
Delivery:Role -Up {
  param($target, $config, $node)

  # Get the path to <Drive>:\Users\<User>\AppData\Roaming
  $appData = [Environment]::GetFolderPath("ApplicationData")

  # Reference a sub-directory named after the project
  $projectPath = Join-Path $appData $target.ProjectName

  # Create a directory for this release
  $thisReleasePath = Join-Path $projectPath $target.StartedAt
  if (!(Test-Path $thisReleasePath)) {
    New-Item $thisReleasePath -ItemType Directory | Out-Null
  }

  # TODO: Download files from somewhere else 
  # into $thisReleasePath here!

  # Remove old link to current release
  $currentReleasePath = Join-Path $projectPath "Current"
  if (Test-Path $currentReleasePath) {
    & cmd /c "rmdir ""$currentReleasePath"""
  }

  # Link this release to the current release
  & cmd /c "mklink /J ""$currentReleasePath"" ""$thisReleasePath""" | Out-Null

  # Get releases
  $releases = Get-ChildItem -Directory $projectPath -Exclude "Current"

  # Delete releases older than the last 5
  if ($releases.count -gt 5) {
    $oldReleaseCount = $releases.count - 5
    $releases | 
      Sort-Object -Property LastWriteTime | 
        Select -First $oldReleaseCount | 
          Remove-Item -Force -Recurse | Out-Null
  }
}
{% endhighlight %}
  <div class="filename">MyAppDelivery\Roles\DownloadRelease\Always.ps1</div>
  </div>
</div>

<br />

### Next read about [targets](targets.html).