---
layout: page
---
<div class="row-fluid">
	<div class="span3 hidden-tablet">
		<ul class="nav nav-list">
			<h5>Article contents</h5>
			<li class="nav-header">
				<a href="#workstation_prep">Prepare your workstation</a>
			</li>
			<li class="nav-header">
				<a href="#add_pipeline">Add a pipeline to a TFS project</a>
			</li>
			<li>
				<a href="#what_created">What gets created</a>
			</li>
			<li class="nav-header">
				<a href="#how_works">How powerdelivery works</a>
			</li>
			<li>
				<a href="#dependencies">Pipeline dependencies</a>
			</li>
			<li class="nav-header">
				<a href="#environment">Environment configuration</a>
			</li>
			<li>
				<a href="#config_how_loaded">How files are loaded</a>
			</li>
			<li>
				<a href="#config_layout">Layout of files</a>
			</li>
			<li>
				<a href="#yaml">YAML best practices</a>
			</li>
			<li>
				<a href="#config_retrieving_values">Retrieving values</a>
			</li>
			<li>
				<a href="#config_structs">Using structures</a>
			</li>
			<li>
				<a href="#config_arrays">Using arrays</a>
			</li>
			<li class="nav-header">
				<a href="#script_blocks">Script blocks</a>
			</li>
			<li>
				<a href="#matrix">Matrix of execution</a>
			</li>
			<li>
				<a href="#optimized_compilation">Optimized compilation</a>
			</li>
			<li>
				<a href="#init_block">Init block</a>
			</li>
			<li>
				<a href="#compile_block">Compile block</a>
			</li>
			<li>
				<a href="#test_units_block">TestUnits block</a>
			</li>
			<li>
				<a href="#setup_environment_block">SetupEnvironment block</a>
			</li>
			<li>
				<a href="#deploy_block">Deploy block</a>
			</li>
			<li>
				<a href="#test_environment_block">TestEnvironment block</a>
			</li>
			<li>
				<a href="#test_acceptance_block">TestAcceptance block</a>
			</li>
			<li>
				<a href="#test_capacity_block">TestCapacity block</a>
			</li>
			<li class="nav-header">
				<a href="#cmdlets">Using cmdlets</a>
			</li>
			<li class="nav-header">
				<a href="#modules">Using delivery modules</a>
			</li>
			<li>
				<a href="#modules_referencing">Referencing modules</a>
			</li>
			<li>
				<a href="#modules_configuring">Configuring modules</a>
			</li>
			<li>
				<a href="#modules_developing">Developing modules</a>
			</li>
		</ul>
	</div>	
	<div class="span9 span12-tablet">
		<h1>Creating deployment pipelines</h1>
		<p>In <a href="https://en.wikipedia.org/wiki/Continuous_delivery" target="_new">continuous delivery</a>, the technology that deploys your software assets to a 
		development, test, and eventually production environment is known as a <b>deployment pipeline</b>. 
		This page will help you use powerdelivery to add a deployment pipeline to your <abbr title="Team Foundation Server">TFS</abbr> 
		project, understand how it works, and guide you in where to place the PowerShell commands that 
		do your automation in your script.</p>

		<a name="workstation_prep"><hr></a>
		<br />
		<h2>Prepare your workstation for development</h2>
		<p>After you've <a href="setup.html">setup your environment</a>, 
		you will want to configure the workstation of anyone who will work on the automation scripts 
		to work with powerdelivery. Follow the directions below on the local computer of any developers, 
		testers, or IT operations personnel who will help to create powerdelivery deployment automation.</p>
		<ol>
			<li><h5>Install PowerShell 3.0 on the local computer</h5></li>
			<p>Open an administrative PowerShell prompt and type the following command:</p>
			{% highlight powershell %}Get-Host{% endhighlight %}
			<p>Look for the <i>Version</i> property and make sure it returns at least <b>3.0</b> or greater. If this 
			number is lower (probably 2.0), then <a href="http://www.microsoft.com/en-us/download/details.aspx?id=34595">download and install PowerShell 3.0</a> before continuing.</p>
			<li><h5>Install Chocolatey on the local computer</h5></li>
			<p>Chocolatey is a package manager for Windows built on <a href="http://www.nuget.org">nuget</a>. It lets you install software on your computer 
			silently from a command prompt (or script) without needing to click through wizards. You can read a blog post 
			from Scott Hanselman about it <a href="http://www.hanselman.com/blog/IsTheWindowsUserReadyForAptget.aspx">here</a>. 
			powerdelivery is distributed through Chocolatey to make it easy to install and update.</p>
			<p>Go to the <a href="http://chocolatey.org/">Chocolatey website</a> and follow the instructions on the front 
			page for installing it via a command prompt.</p>
			<li><h5>Enable Unsigned PowerShell scripts on the local computer</h5></li>
			<p>I am purchasing a certificate to sign the scripts that come with powerdelivery in the near future. Until then, 
			you need to open an Administrative PowerShell console and run the following command:</p>
			{% highlight powershell %}Set-ExecutionPolicy Unrestricted{% endhighlight %}
			<li><h5>Install Powerdelivery on the local computer</h5></li>
			<p>From an Administrative PowerShell console, run the following command to install powerdelivery via chocolatey:</p>
			<p>
				<code>cinst powerdelivery</code>
			</p>
			<p>You should <a href="http://chocolatey.org/packages/PowerDelivery">check the powerdelivery Chocolatey page for updates</a> 
			from time to time. When you find them, update your build agent from an Administrative PowerShell 
			console again with the following command:</p>
			<p>
				<code>cup powerdelivery</code>
			</p>
			<li><h5>Install PowerShell development tools (optional)</h5></li>
			<p>PowerShell 3.0 comes with an <abbr title="Integrated Scripting Environment">ISE</abbr> that works fairly 
			well for scripting, but you may also consider installing the free version of 
			<a href="http://www.powergui.com">PowerGUI</a>. You can install PowerGUI via Chocolatey with the 
			following command:</p>
			<p>
				<code>cinst powergui</code>
			</p>
			<p>You might also consider installing <a href="http://notepad-plus-plus.org/">Notepad++</a> for editing the .yml configuration files used by 
			powerdelivery. Notepad++ has YAML syntax highlighting and you can install it via Chocolatey with the following command:</p>
			<p>
				<code>cinst notepadplusplus</code>
			</p>
		</ol>

		<a name="add_pipeline"><hr></a>
		<br />
		<h2>Add a pipeline to a TFS project</h2>
		<p>You can enable a <abbr title="Team Foundation Server">TFS</abbr> project to use powerdelivery in under 
		a minute using the included <b>Add-Pipeline</b> cmdlet (cmdlets are reusable PowerShell functions). This PowerShell cmdlet 
		does the following:</p>
		<ul>
			<li>Uploads files to your <abbr title="Team Foundation Server">TFS</abbr> project's source control repository used for scripting the automation.</li>
			<li>Creates builds for your <abbr title="Team Foundation Server">TFS</abbr> project that can be triggered to deploy to each environment.</li>
			<li>Creates security groups on <abbr title="Team Foundation Server">TFS</abbr> that users can be placed in to allow them to deploy to your test or production environments.</li>
		</ul>
		<p>Perform the following steps to create a deployment pipeline for your TFS project:</p>
		<ol>
			<li><h5>Determine the TFS project</h5></li>
			<p>Using Team Explorer in Visual Studio, locate the project you want to add powerdelivery to 
			and take a note of its name. You can usually find this in the project collection list, or in the 
			source control browser as the "root" folder (prefixed with a $ character)</p>
			<li><h5>Determine the TFS collection URL</h5></li>
			<p>Using Team Explorer again, find the URL of your project collection. This is the URL to the 
			collection of projects itself, not your project.</p>
			<p>If you had a project named "MyProject", this URL might be:</p>
			<p>
				<code>http://mytfsserver:8080/tfs</code>
			</p>
			<p>And would <b>NOT</b> be:</p>
			<p>
				<code>http://mytfsserver:8080/tfs/MyProject (WRONG!)</code>
			</p>
			<li><h5>Determine the TFS build controller</h5></li>
			<p>When you <a href="setup.html">setup your environment for powerdelivery</a>, you installed 
			PowerShell 3.0, Chocolatey, and powerdelivery on your <b>TFS Build Agent</b> computer. TFS uses 
			another service, the <b>TFS Build Controller</b> to orchestrate builds and call your agent to 
			kick one off. You need to find out the name of this computer. If you have the agent and controller 
			installed on the same computer (which many installations of TFS do) this will be the same.</p>
			<li><h5>Determine the UNC path to drop build output into</h5></li>
			<p>When builds run using TFS, they copy the output (.dll files, test results, etc.) into a 
			"drop folder" which is a UNC network share that has write permissions assigned to it by the 
			Active Directory account under which the TFS Build Agent service runs. You need to determine 
			this UNC network share path so that your builds have a place to put their output.</p>
			<li><h5>Pick a pipeline name</h5></li>
			<p>You should select a name that your PowerShell script, the builds created in TFS, and the 
			security groups created in TFS will have. <b>Do not use spaces</b> and it's often best to just 
			use the name of the TFS project.</p>
			<li><h5>Run the Add-Pipeline cmdlet</h5></li>
			<p>Now you have all the information you need to create your pipeline. Open an Administrative 
			PowerShell console and run the <b>Add-Pipeline</b> cmdlet. You can type the following command for help:</p>
			{% highlight powershell %}Get-Help Add-Pipeline -Detailed{% endhighlight %}
			<br/>
			<p>As an example, if you gathered the following information during the steps above:</p>
			<ul>
				<li>TFS project: MyProject</li>
				<li>TFS collection: http://myserver:8080/tfs</li>
				<li>TFS controller: MYBUILDCONTROLLER.mydomain.com</li>
				<li>UNC drop folder: \\MYSERVER\MyDrops</li>
				<li>Chosen pipeline name: MyProject</li>
			</ul>
			<br />
			<p>Based on the settings above you would add a deployment pipeline to the project using the PowerShell command below:</p>
			{% highlight powershell %}Add-Pipeline -Project "MyProject" `
             -Collection "http://myserver:8080/tfs" `
             -Controller "MYBUILDCONTROLLER.mydomain.com" `
             -DropFolder "\\MYSERVER\MyDrops" `
             -Name "MyProject"{% endhighlight %}
		</ol>

		<a name="what_created"><hr></a>
		<br />
		<h3>What gets created</h3>
		<p>When you add a pipeline to your TFS project, a number of files and artifacts are created. 
		Assuming the example settings above, the following will be created in TFS:</p>
		<h4>Source control files</h4>
		<p>The following files will be added to your TFS source control.</p>
		<p>The PowerShell script to put your deployment automation code in:</p>
		<pre>$/MyProject/MyProject.ps1</pre>
		<p>The YAML files to put your environment configuration in:</p>
		<pre>
$/MyProject/MyProjectCapacityTestEnvironment.yml
$/MyProject/MyProjectCommitEnvironment.yml
$/MyProject/MyProjectTestEnvironment.yml
$/MyProject/MyProjectProductionEnvironment.yml
$/MyProject/MyProjectModules.yml</pre>
		<p>The TFS Build Process Templates. These are Windows Workflow Foundation files that 
		TFS uses to call a powerdelivery script. You should not need to open or understand 
		anything about these files to use powerdelivery and please <b>do not modify these files</b>:</p>
		<pre>
$/MyProject/BuildProcessTemplates/PowerDeliveryTemplate.xaml
$/MyProject/BuildProcessTemplates/PowerDeliveryTemplate.11.xaml
$/MyProject/BuildProcessTemplates/PowerDeliveryChangeSetTemplate.xaml
$/MyProject/BuildProcessTemplates/PowerDeliveryChangeSetTemplate.11.xaml</pre>
		<h4>TFS Builds</h4>
		<p>The following builds will be created for you:</p>
		<pre>
MyProject - Capacity Test
MyProject - Commit
MyProject - Production
MyProject - Test</pre>
		<p>The Commit build will trigger automatically whenever changes are checked-in to 
		the TFS project containing the builds. The rest of the builds must be explicitly 
		triggered manually.</p>
		<h4>TFS Security Groups</h4>
		<p>The following security groups are created for you:</p>
		<pre>
MyProject Test Builders
MyProject CapacityTest Builders
MyProject Production Builders</pre>
		<p>Only users who are added to the above groups will be permitted to trigger 
		builds targeting those environments.</p>

		<a name="how_works"><hr></a>
		<br />
		<h2>How powerdelivery works</h2>
		<p>At its core, powerdelivery simply runs a PowerShell script. You can choose to run 
		that script on your own computer and it will run a <a href="#local_builds">Local</a> build. When you trigger 
		a build on <abbr title="Team Foundation Server">TFS</abbr>, some extra parameters 
		are passed to the script so that it runs a build against the appropriate target 
		environment (Development, Test, Production etc.).</p>
		<p>The top of every powerdelivery script declares the name of the deployment 
		pipeline as well as a version. The name was specified when you 
		<a href="#add_pipeline">added powerdelivery to your TFS project</a> and the 
		version can be incremented as necessary. Here is an example of a pipeline declaration, 
		present at the top of every powerdelivery script:</p> 
		{% highlight powershell %}Pipeline 'MyProduct' -Version '1.0.3'{% endhighlight %}
		<p>As your build runs, it goes through a <a href="#matrix">specific sequence</a> of calling named script blocks 
		where you should do common delivery activities (compile, deploy, setup the environment, 
		test etc.). You can use the <a href="#cmdlets">cmdlets</a> (reusable PowerShell functions) included with 
		powerdelivery within those script blocks to do work. You can also use 
		<a href="#modules">delivery modules</a> as necessary.</p>
		
		<a name="dependencies"><hr></a>
		<br>
		<h3>Dependencies between deployment pipelines</h3>
		<p>You should always use a 3-part version in your pipeline declaration. This allows you 
		to control your release of change into other deployment pipelines (products or software 
		projects) that are dependent on yours.	An example would be where you have one TFS 
		project that delivers a reusable class library, using powerdelivery, as its output. 
		There are other TFS projects that consume this reusable library. You may have written your 
		build so that it drops the library into a UNC path somewhere or perhaps <a href="http://www.nuget.org" target="_blank">nuget</a> as its <a href="#production_builds">production</a> 
		build "deployment".</p>
		<p>When the other TFS projects that want to reuse this asset reference it, they should 
		pull versions that are tied to the 3 part name, so for instance they are designed to work 
		with version 1.0.3 <i>or greater</i> of your library. This way, when new versions of your files are released 
		as 1.0.3.100 or 1.0.3.500 you are telling the consuming applications that the <i>interface</i> 
		to that file hasn't changed. If it does change, you can then update the version at the top 
		of the script to 1.0.4 and those downstream applications can choose to integrate the new 
		changes only when they are ready.</p>
		<p>Powerdelivery automatically creates a 
		version number with the changeset appended to the end on each build so that you 
		can version your files appropriately. See the <a href="reference.html#invoke_msbuild_cmdlet">Invoke-MSBuild</a> 
		cmdlet for more information about versioning files.</p>

		<a name="environment"><hr></a>
		<br />
		<h2>Environment configuration</h2>
		<p>The key principle of Continuous Delivery with respect to powerdelivery itself is 
		releasing more frequently, and to do this with confidence requires making sure the 
		automation that happens during deployment in your development and test environment is 
		as close as possible as to what will happen in production.</p>
		<p>Powerdelivery requires you to use simple environment configuration files to capture 
		the differences between environments. See the <a href="setup.html">setup</a> page for 
		more information about planning your infrastructure so you know what information to put 
		into these files.</p>

		<a name="config_how_loaded"><hr></a>
		<br />
		<h3>How configuration files are loaded</h3>
		<p>When your build script starts, prior to your code being run, powerdelivery 
		looks in the same directory as your script for a file with the following pattern:</p>
		<p>
			<code>[ScriptName][EnvironmentName]Environment.yml</code>
		</p>
		<p>where <i>ScriptName</i> is the name of the build script (ending in .ps1) and <i>EnvironmentName</i> 
		is "Local", "Test", or "Production" for example, depending on the target build environment.</p>
		<p>For example, if your script was named "RecipeManager", powerdelivery would expect to find the following environment configuration files:</p>
		<pre>RecipeManagerLocalEnvironment.yml
RecipeManagerCommitEnvironment.yml
RecipeManagerTestEnvironment.yml
RecipeManagerCapacityTestEnvironment.yml
RecipeManagerProductionEnvironment.yml</pre>

		<a name="config_layout"><hr></a>
		<br />
		<h3>Layout of your configuration files</h3>
		<p>Configuration files use <a href="https://en.wikipedia.org/wiki/YAML" target="_blank">YAML</a> syntax and most of the settings you use will probably be 
		name/value pairs. Remember that these files are only meant to contain settings that are 
		<i>different</i> between your environments.</p>
		<p>Below is an example of three settings in a build that could deploy a website and a 
		database. These are just example settings and the names of the settings do not mean anything 
		special. Your settings can be named whatever you want.</p>
		{% highlight yaml %}WebServer: MyServer
DatabaseServer: MyDbServer
DatabaseName: MyDatabase{% endhighlight %}
		<p>This is just an example of the settings in one file. You will have these same setting names, 
		but with different <i>values</i>, in all of your environment configuration files. So if we were 
		using the example build name of "RecipeManager" (where our build script is named RecipeManager.ps1) 
		we might have the following contents for our environment configuration files:</p>
		<p><b>RecipeManagerCommitEnvironment.yml</b></p>
		{% highlight yaml %}WebServer: MyDevServer
DatabaseServer: MyDevDbServer
DatabaseName: MyDatabase{% endhighlight %}
		<p><b>RecipeManagerTestEnvironment.yml</b></p>
		{% highlight yaml %}WebServer: MyTestServer
DatabaseServer: MyTestDbServer
DatabaseName: MyDatabase{% endhighlight %}
		<p><b>RecipeManagerProductionEnvironment.yml</b></p>
		{% highlight yaml %}WebServer: MyProdServer
DatabaseServer: MyProdDbServer
DatabaseName: MyDatabase{% endhighlight %}

		<a name="yaml"><hr></a>
		<br />
		<h3>YAML best practices</h3>
		<p>Because <a href="https://en.wikipedia.org/wiki/YAML" target="_blank">YAML</a> strings are interpreted as PowerShell strings when loaded by powerdelivery, 
		you need to be a little careful to avoid some gotchas you may run into. Here are the considerations 
		you should take into account.</p>
		<ul>
			<li><b>Tabs</b> - Do not use tabs to indent your YAML settings. Use two spaces. This 
			requirement is part of the YAML specification.</li>
			<br>
			<li><b>Backslashes</b> - When you do NOT have quotes around your string, these will 
			be interpreted exactly as you type them. When you do, a single backslash will not appear 
			at all, and a double backslash will appear as a single one.</li>
			<br>
			<li><b>Reserved characters</b> - A list of them can be seen at the 
			<a href="http://ss64.com/ps/syntax-esc.html" target="_blank">top of this page</a>. If you put one of 
			these reserved characters (the character prefixed by a tick character) into a YAML 
			value WITHOUT quotes, you will get an error when loading the YAML file. You must 
			surround your value with quotes to use a reserved character.</li>
		</ul>
		<p>An interactive YAML parser is available online <a href="https://yaml-online-parser.appspot.com/" target="_blank">here</a> and 
		may be helpful in learning the markup syntax initially if you have questions.</p>
		
		<a name="config_retrieving_values"><hr></a>
		<br />
		<h3>Retrieving values from configuration files</h3>
		<p>There is a cmdlet (PowerShell function) included with powerdelivery that you should call in 
		the <a href="#init_block">Init</a> block of your script (blocks are described in the next section). This cmdlet is 
		called <a href="reference.html#get_buildsetting_cmdlet">Get-BuildSetting</a> and takes the name of your setting as its only parameter, and 
		returns the value of that setting from the configuration file appropriate for the target environment 
		your build is running against. The idea is to read in these settings that are specific to the environment 
		as variables and then use them elsewhere in the script to deploy correctly.</p>
		<p>Using our example settings above, we would retrieve these in the <a href="#init_block">Init</a> block of the script 
		for use throughout our script and set them as variables as follows. Prefixing a variable with <i>script:</i> 
		makes it available not only to that PowerShell script block, but throughout the entire script:</p>
		{% highlight powershell %}Init {
  $script:WebServer = Get-BuildSetting WebServer
  $script:DatabaseServer = Get-BuildSetting DatabaseServer
  $script:DatabaseName = Get-BuildSetting DatabaseName
}{% endhighlight %}

		<a name="config_structs"><hr></a>
		<br />
		<h3>Using structures in configuration settings</h3>
		<p>YAML is a flexible format for storing settings. You can also use nested 
		name/value pairs to provide more structure to your settings if desired. If we have 
		the following settings in our configuration file:</p>
		{% highlight yaml %}WebSite:
  Server: MyWebServer
  Port: MyWebPort
Database:
  Server: MyDbServer
  Database: MyDatabase{% endhighlight %}
		<p>We can retrieve their values instead this way:</p>
		{% highlight powershell %}Init {
  $webSiteSettings = Get-BuildSetting WebSite
  $databaseSettings = Get-BuildSetting Database
		
  $script:WebServer = $webSiteSettings.Server
  $script:WebPort = $webSiteSettings.Port
		
  $script:DatabaseServer = $databaseSettings.Server
  $script:DatabaseName = $databaseSettings.Database
}{% endhighlight %}

		<a name="config_arrays"><hr></a>
		<br />
		<h3>Using arrays in configuration settings</h3>
		<p>Arrays are a powerful way to store configuration when you want to 
		allow your build to do the same work multiple times driven by configuration. 
		If we have the following settings in our configuration file:</p>
		{% highlight yaml %}WebSites:
  Site1:
    Server: MyWebServer1
    Port: 80
  Site2:
    Server: MyWebServer2
    Port: 80
  Site3:
    Server: MyWebServer3
    Port: 8080{% endhighlight %}
		<p>We can retrieve and loop through their values this way:</p>
		{% highlight powershell %}Init {
  $webSiteSettings = Get-BuildSetting WebSites
}
Deploy {
  $webSiteSettings.Keys | % {
    $webSite = $webSiteSettings[$_]	
    $server = $webSite.Server
    $port = $webSite.Port	
    "The web site server is $server and port is $port"
  }
}{% endhighlight %}
		<p>This trivial example simply prints out to the build log the name and port of the 
		web servers and ports. In a more useful build you might deploy to each web site the 
		same set of files in a farm for example.</p>

		<a name="script_blocks"><hr></a>
		<h2>Script blocks</h2>
		<p>Once you have <a href="#environment">configured your environment</a>, 
		you can begin the task of writing the actual automation PowerShell statements that will do the 
		work. These go into script blocks with specific names that represent the phases of a Continuous 
		Delivery deployment pipeline.</p>

		<a name="matrix"><hr></a>
		<br />
		<h3>Matrix of script blocks</h3>
		<p>These script blocks are always called in the same order, but depending on the environment 
		the build is targeting, some will be skipped over. The table below shows a matrix of the order of execution 
		of these blocks (from top to bottom) and which are called in each environment.</p>
		<table class="table">
			<tr>
				<th></th>
				<th colspan="5"><div style="text-align: center">Target Build Environment</div></th>
			</tr>
			<tr>
				<th style="text-align: center">PowerShell Script Block</th>
				<th><a href="#local_builds">Local</a></th>
				<th><a href="#commit_builds">Commit</a></th>
				<th><a href="#test_builds">Test</a></th>
				<th><a href="#capacity_test_builds">CapacityTest</a></th>
				<th><a href="#production_builds">Production</a></th>
			</tr>
			<tr>
				<td style="text-align: right"><a href="#init_block">Init</a></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td>  
			</tr>
			<tr>
				<td style="text-align: right"><a href="#compile_block">Compile</a></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"></td><td style="text-align: center"></td><td style="text-align: center"></td>  
			</tr>
			<tr>
				<td style="text-align: right"><a href="#test_units_block">TestUnits</a></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"></td><td style="text-align: center"></td><td style="text-align: center"></td>
			</tr>
			<tr>
				<td style="text-align: right"><a href="#setup_environment_block">SetupEnvironment</a></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td>
			</tr>
			<tr>
				<td style="text-align: right"><a href="#deploy_block">Deploy</a></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td>
			</tr>
			<tr>
				<td style="text-align: right"><a href="#test_environment_block">TestEnvironment</a></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"><i class="icon-ok"></i></td>
			</tr>
			<tr>
				<td style="text-align: right"><a href="#test_acceptance_block">TestAcceptance</a></td><td style="text-align: center"></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"></td><td style="text-align: center"></td><td style="text-align: center"></td>
			</tr>
			<tr>
				<td style="text-align: right"><a href="#test_capacity_block">TestCapacity</a></td><td style="text-align: center"></td><td style="text-align: center"></td><td style="text-align: center"></td><td style="text-align: center"><i class="icon-ok"></i></td><td style="text-align: center"></td>
			</tr>
		</table>
		<p>All blocks are optional and you may choose which to include in your pipeline script depending on 
		what features you'd like to support.</p>
		
		<a name="optimized_compilation"><hr></a>
		<br />
		<h3>Optimized compilation</h3>
		<p>To confidently promote builds from one environment to another, we want to prevent different compiled 
		assets from making their way into an environment than have already been evaluated in another. To prevent 
		this, the <a href="#compile_build">Compile</a> block is only called for <a href="#local_build">Local</a> 
		and <a href="#commit_build">Commit</a> builds.</p>
		<p>Because of this, any files that are required for the <a href="#setup_environment_block">SetupEnvironment</a> 
		block or beyond in other environments must be copied to the drop location during <a href="#compile_block">Compile</a>. Do this by 
		using the <a href="reference.html#publish_buildassets">Publish-BuildAssets</a> cmdlet before the Compile 
		block ends.</p>
		
		<a name="init_block"><hr></a>
		<br>
		<h3>Init block</h3>
		<p>This is the first block called in your build pipeline script. You should do things 
		that must happen before the build starts that will run on all environments. My 
		suggestion is to only use this block to get environment configuration using the 
		<a href="reference.html#get_buildsetting_cmdlet">Get-BuildSetting</a> cmdlet, and 
		set them as script scoped variables. This will make the settings available to all 
		blocks of your pipeline script.</p>
		<p>Another common use of this block is to setup paths as variables needed by the 
		rest of your script.</p>
		<h4>Example</h4>
		{% highlight powershell %}Init {
  $script:currentDirectory = Get-Location
  $script:myDatabase = Get-BuildSetting MyDatabase
  $script:myWebServer = Get-BuildSetting MyWebServer
}{% endhighlight %}
		
		<a name="compile_block"><hr></a>
		<br>
		<h3>Compile block</h3>
		<p>This block is only called on <a href="#commit_build">Commit</a> or <a href="#local_build">Local</a> builds. You should run any tools 
		or compilers necessary to create the software assets you will deploy to your environments.</p>
		<p>Any files you need to do deployment that are part of your source must be copied to the 
		drop location. You can get this directory (a UNC path) from calling the 
		<a href="reference.html#get_builddroplocation_cmdlet">Get-BuildDropLocation</a> function.</p>
		<h4>Example</h4>
		<p>In the example deployment pipeline script below, any files output from the 
		"MyProject" solution after compilation (like .dll, .exe, or other files) are 
		copied to the the "Binaries" subdirectory of the drop location for deployment.</p>
		{% highlight powershell %}Init {
  $script:currentDirectory = Get-Location
  $script:dropLocation     = Get-BuildDropLocation
  $script:environment      = Get-BuildEnvironment

  $script:binDropDir = Join-Path $dropLocation Binaries

  mkdir $binDropDir
}

Compile {
  Invoke-MSBuild MyProject.sln

  copy "MyProject\bin\$environment\*.*" $binDropDir
}{% endhighlight %}

		<a name="test_units_block"><hr></a>
		<br>
		<h3>TestUnits block</h3>
		<p>Here you should run any automated unit test commands such as MSTest.exe 
		with the included <a href="reference.html#invoke_mstest_cmdlet">Invoke-MSTest</a>
		cmdlet. These tests run after compilation but prior to deployment.</p>
		
		<a name="setup_environment_block"><hr></a>
		<br>
		<h3>SetupEnvironment block</h3>
		<p>Here is where you will make changes to the target environment nodes (computers, 
		virtual machines, cloud hosted nodes etc.) to support deployment of your software 
		assets.	This follows the practice of Continuous Delivery where you should no longer 
		allow people to login to the environments and instead use automation to modify them. 
		This is where you do it.</p>
		<p>Try to setup the environment nodes with a base OS image with just the 
		middleware you'd need that takes a long time to install (for instance, SQL server) 
		pre-installed and use the script to configure and install everything else.</p>
		<h4>Example</h4>
		<p>This example sets an environment variable on a target computer. It is just an 
		example of what you might need to do to support your deployment.</p>
		{% highlight powershell %}Init {
  $script:myEnvVarValue = Get-BuildSetting -Name MyEnvVarValue
  $script:myServer      = Get-BuildSetting -Name MyServer
}

SetupEnvironment {
  Invoke-Command -ComputerName $myServer {
    [Environment]::SetEnvironmentVariable('MyEnvVar', '$using:myEnvVarValue', 'Machine')
  }
}{% endhighlight %}

		<a name="deploy_block"><hr></a>
		<br>
		<h3>Deploy block</h3>
		<p>This script block runs in all environments and should take the assets in your 
		build (compiled .dll or .exe files, SSIS packages, etc.) and install them on the 
		target environment nodes (physical computers, virtual machines, devices, cloud nodes etc.).</p>
		<p>Because powerdelivery supports <a href="#optimized_compilation">optimized compilation</a>, 
		remember that any files you need to use for deployment must be published using the 
		<a href="reference.html#publish_buildassets_cmdlet">Publish-BuildAssets</a> 
		cmdlet in the <a href="#compile_block">Compile</a> block to the UNC network share located at the path returned from calling the 
		<a href="reference.html#get_builddroplocation_cmdlet">Get-BuildDropLocation</a> 
		cmdlet prior to deploying them.</p>

		<a name="test_environment_block"><hr></a>
		<br>
		<h3>TestEnvironment block</h3>
		<p>Here you should run any smoke test commands that can be used to make sure the 
		environment was setup successfully. You might ping web servers or services, try 
		accessing a load balancer, or verify anything else that was modified during 
		the <a href="#setup_environment_block">SetupEnvironment</a> block.</p>
		
		<a name="test_acceptance_block"><hr></a>
		<br>
		<h3>TestAcceptance block</h3>
		<p>Here you should run any automated acceptance test commands such as MSTest.exe 
		with the included <a href="reference.html#invoke_mstest_cmdlet">Invoke-MSTest</a> 
		cmdlet. These tests run after the <a href="#deploy_block">Deploy</a> block gets 
		called and so can interact with anything that was setup during deployment.</p>
		
		<a name="test_capacity_block"><hr></a>
		<br>
		<h3>TestCapacity block</h3>
		<p>Here you should run any automated performance tests that verify that a 
		capacity test environment being deployed to is suitable for the audience the 
		software assets will be serving. Your capacity test environment should be 
		identical to production in hardware capability, or as close as possible. 
		Computing resources do not scale in a linear fashion so assuming your quad 
		core production server will support twice the load of a capacity-tested 
		dual core is false.</p>
		
		<a name="cmdlets"><hr></a>
		<br />
		<h2>Using cmdlets</h2>
		<p>Refer to the <a href="reference.html#cmdlets">cmdlet reference</a> 
		to see what reusable commands are built in to powerdelivery that you can use in your script blocks. 
		There are many powerful commands that will save you significant time and coding but remember, 
		you can also use any PowerShell scripts or modules you find along with powerdelivery.</p>
		<p>Though they don't force you to, many of the included cmdlets are meant to be called within 
		specific blocks of your script. For example, the <a href="reference.html#get_buildsettings_cmdlet">Get-BuildSettings</a> 
		cmdlet should be called in the <a href="#init_block">Init</a> block. The <a href="reference.html#invoke_msbuild_cmdlet">Invoke-MSBuild</a> 
		cmdlet should be called in the <a href="#compile_block">Compile</a> block. The <a href="reference.html#invoke_roundhouse_cmdlet">Invoke-Roundhouse</a> 
		cmdlet should be called in the <a href="#deploy_block">Deploy</a> block.</p>

		<a name="modules"><hr></a>
		<br />
		<h2>Using delivery modules</h2>
		<p>The reusable cmdlets included with powerdelivery are easy to use and you just choose a <a href="#matrix">script block</a> 
		(Init, Compile, Deploy etc.) to call them from. However, there are times when you might want to package 
		up some reusable PowerShell code that does work across more than one of these script blocks. For example, 
		to setup a website, you might want to enable the target environment to use <a href="http://www.iis.net/downloads/microsoft/web-deploy" target="_blank">Microsoft Web Deploy</a> in the 
		<a href="#setup_environment_block">SetupEnvironment</a> block, and then do the actual deployment in the 
		<a href="#deploy_block">Deploy</a> block. To enable this, powerdelivery allows for the use of <b>Delivery Modules</b>.</p>

		<a name="modules_referencing"><hr></a>
		<br />
		<h3>Referencing modules</h3>
		<p>Before you can begin to use a delivery module, you must add a reference to one in your build script. 
		This is done by calling the <a href="reference.html#import_deliverymodule_cmdlet">Import-DeliveryModule</a> 
		cmdlet at the top of your script (outside of a block). If you are familiar with the C# programming language, 
		this is analagous to putting a "using" statement at the top of a class file.</p>
		<p>Below is an example of importing the <a href="reference.html#webdeploy_module">WebDeploy</a> module 
		included with powerdelivery. See the <a href="reference.html#modules">module reference</a> for details of 
		which modules are included with powerdelivery.</p>
		{% highlight powershell %}Pipeline 'MyProduct' -Version '1.0.0'

Import-DeliveryModule WebDeploy{% endhighlight %}

		<a name="modules_configuring"><hr></a>
		<br />
		<h3>Configuring modules</h3>
		<p>Once you've referenced a module using the <a href="reference.html#import_delivery_module_cmdlet">Import-DeliveryModule</a> 
		cmdlet, you must configure it for the module to do any work. When you <a href="#add_pipeline">added a deployment pipeline</a> to your TFS project, 
		an additional configuration file was added that is used to store the configuration of the modules you use in your script. 
		This file follows the naming convention:</p>
		<p>
			<code>[ScriptName]Modules.yml</code>
		</p>
		<p>Following our example, if our pipeline was named "RecipeManager" (and thus the build script is named 
		RecipeManager.ps1), the module configuration file would be:</p>
		<p>
			<code>RecipeManagerModules.yml</code>
		</p>
		<p>Each delivery module you import has a YAML section name under which its settings should be placed. 
		You will need to refer to the <a href="reference.html#modules">delivery module reference</a> for each 
		module to find this information. Below this section name you must add another named section for each 
		set of settings you want to pass to the module to do work. This section can be named anything you want.</p>
		<p>As an example, if our script referenced the <a href="reference.html#msbuild_module">MSBuild</a> delivery module 
		we might have 3 projects we want to have compiled when our script runs. Using the delivery module, we no longer 
		use a call to the <a href="reference.html#invoke_msbuild_cmdlet">Invoke-MSBuild</a> cmdlet in our script, but instead 
		place settings below an <b>MSBuild</b> settings section in the module configuration file. Here is an example 
		of the contents of the module configuration file in our example:</p>
		{% highlight yaml %}MSBuild:
  Project1:
    ProjectFile: Project1/Project1.csproj
  Project2:
    ProjectFile: Project2/Project2.csproj
    Flavor: x64
  Project3:
    ProjectFile: Project3/Project3.csproj
    Properties:
      Property1: 1
      Property2: 2{% endhighlight %}
		<p>When the script runs (and just prior to when the <a href="#compile_block">Compile</a> block executes), 
		the MSBuild module will see these settings and attempt to compile these three projects using the settings 
		that were configured. Refer to the <a href="reference.html#modules">delivery module reference</a> 
		for each module to find out during which script blocks in the delivery pipeline's execution lifecycle
		that your settings will actually do work if you need to coordinate this with other work you do in your script.</p>
	</div>
</div>