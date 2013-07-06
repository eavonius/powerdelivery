---
layout: page
---
<div class="row-fluid">
	<div class="span3">
		<h5>Article contents</h5>
		<ul class="nav nav-list">
			<li class="nav-header">
				<a href="#cmdlets">PowerShell cmdlets</a>
			</li>
			<li>
				<a href="#disable_sqljobs_cmdlet">Disable-SqlJobs</a>
			</li>
			<li>
				<a href="#enable_sqljobs_cmdlet">Enable-SqlJobs</a>
			</li>
			<li>
				<a href="#enable_webdeploy_cmdlet">Enable-WebDeploy</a>
			</li>
			<li>
				<a href="#get_buildappversion_cmdlet">Get-BuildAppVersion</a>
			</li>
			<li>
				<a href="#get_buildassemblyversion_cmdlet">Get-BuildAssemblyVersion</a>
			</li>
			<li>
				<a href="#get_buildassets_cmdlet">Get-BuildAssets</a>
			</li>
			<li>
				<a href="#get_buildchangeset_cmdlet">Get-BuildChangeset</a>
			</li>
			<li>
				<a href="#get_buildcollectionuri_cmdlet">Get-BuildCollectionUri</a>
			</li>
			<li>
				<a href="#get_builddroplocation_cmdlet">Get-BuildDropLocation</a>
			</li>
			<li>
				<a href="#get_buildenvironment_cmdlet">Get-BuildEnvironment</a>
			</li>
			<li>
				<a href="#get_buildmoduleconfig_cmdlet">Get-BuildModuleConfig</a>
			</li>
			<li>
				<a href="#invoke_msbuild_cmdlet">Invoke-MSBuild</a>
			</li>
			<li class="nav-header">
				<a href="#modules">Delivery modules</a>
			</li>
		</ul>
	</div>
	<div class="span9">
		<h1>Reference</h1>
		<p>This page contains details of all the included reusable assets in 
		powerdelivery you can use to do automation work. Refer to this page 
		to learn more about what powerdelivery can do "out of the box". Many 
		of these features will save you significant time over rolling your own 
		solution.</p>
		<a name="cmdlets"><hr></a>
		<br />
		<h2>PowerShell cmdlets</h2>
		<p>This section includes the reference for all the included powerdelivery 
		cmdlets. See the <a href="/create.html#cmdlets">using cmdlets</a> 
		topic from the <a href="/create.html">creating deployment pipelines</a> article 
		for an overview of the philosophy behind using these cmdlets.</p>
		
		<a name="disable_sqljobs_cmdlet"><hr></a>
		<h3>Disable-SqlJobs</h3>
		<p>This cmdlet can disable one or more sql jobs who's name(s) match the pattern provided.</p>
		<p>If any job is found to be running, it will remain enabled and any other disabled services will be re-enabled.</p>
		<h4>Example</h4>
		{% highlight powershell %}Disable-SqlJobs -serverName MyServer -jobs "Purchasing*"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>serverName</h5>
		<p>string - The SQL server name of the SQL instance to disable jobs on.</p>
		<h5>jobs</h5>
		<p>string - The name of the job(s) to disable. You can use wildcards or a single name.</p>
		
		<a name="enable_sqljobs_cmdlet"><hr></a>
		<h3>Enable-SqlJobs</h3>
		<p>This cmdlet can enable one or more sql jobs who's name(s) match the pattern provided.</p>
		<h4>Example</h4>
		{% highlight powershell %}Enable-SqlJobs -serverName MyServer -jobs "Purchasing*"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>serverName</h5>
		<p>string - The SQL server name of the SQL instance to enable jobs on.</p>
		<h5>jobs</h5>
		<p>string - The name of the job(s) to enable. You can use wildcards or a single name.</p>
		
		<a name="enable_webdeploy_cmdlet"><hr></a>
		<h3>Enable-WebDeploy</h3>
		<p>This cmdlet is used to configure an IIS website for deployment.</p>
		<h4>Example</h4>
		{% highlight powershell %}Enable-WebDeploy -webComputer 'MyWebServer' -webDeployDir 'C:\Program Files\Microsoft Web Deploy v3' -webSite 'MySite' -webPort '8080' -webPassword '3F#g&jKl'{% endhighlight %}
		<h4>Parameters</h4>
		<h5>webComputer</h5>
		<p>The name of the computer to enable web deployment for. Must be Windows Server running IIS 7 or greater, with Web Deploy 3.0 and "Recommended Host Configuration" setup using Microsoft Platform Installer.</p>
		<h5>webDeployDir</h5>
		<p>The directory on the web server computer into which Web Deploy 3 is installed. You can use a remote powershell command to read this out of the registry of the remote computer if your different enviroments have installed it in different locations.</p>
		<h5>webSite</h5>
		<p>The name of the website to create. A corresponding application pool with the same name will also be created.</p>
		<h5>webPort</h5>
		<p>The port the website should run on. Must not be an existing port in use on the server.</p>
		<h5>webPassword</h5>
		<p>A user account will be created on the server that will allow deployment to it named after the website. This paramter specifies the password of that account.</p>
		<h5>runtimeVersion</h5>
		<p>Optional. The version of .NET the application pool should be created with. Defaults to '4.0'.</p>
		
		<a name="get_buildappversion_cmdlet"><hr></a>
		<h3>Get-BuildAppVersion</h3>
		<p>Returns the version of the application. Should be used to version assets so they match the build changeset.</p>
		<h4>Example</h4>
		{% highlight powershell %}$appVersion = Get-BuildAppversion{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The version of the application with the 4th segment being the TFS changeset number.</p>
		
		<a name="get_buildassemblyversion_cmdlet"><hr></a>
		<h3>Get-BuildAssemblyVersion</h3>
		<p>Returns the version of the application. Should be used to version assemblies so they match the build version.</p>
		<h4>Example</h4>
		{% highlight powershell %}$assemblyVersion = Get-BuildAssemblyVersion{% endhighlight %}
		<h4>Outputs</h4>
		<p>The version of the application as specified when declaring the Pipeline at the top of your delivery pipeline script.</p>
		
		<a name="get_buildassets_cmdlet"><hr></a>
		<h3>Get-BuildAssets</h3>
		<p>Copies build assets from the drop location to the build working directory. You should specify relative paths for this command.</p>
		<h4>Example</h4>
		{% highlight powershell %}Get-BuildAssets "SomeDir\SomeFiles" "SomeDir" -Filter *.*{% endhighlight %}
		<h4>Parameters</h4>
		<h5>path</h5>
		<p>The relative remote path of assets at the drop location that should be copied locally.</p>
		<h5>destination</h5>
		<p>The relative local path to copy the assets to.</p>
		<h5>filter</h5>
		<p>Optional. A filter for the file extensions that should be included.</p>
		
		<a name="get_buildchangeset_cmdlet"><hr></a>
		<h3>Get-BuildChangeset</h3>
		<p>Gets the TFS changeset of the source code being built.</p>
		<h4>Example</h4>
		{% highlight powershell %}$changeSet = Get-BuildChangeSet{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The changeset of the TFS checkin being built (for example, C45 for changeset 46).</p>
		
		<a name="get_buildcollectionuri_cmdlet"><hr></a>
		<h3>Get-BuildCollectionUri</h3>
		<p>Gets the Uri of the TFS project collection containing the project being built.</p>
		<h4>Example</h4>
		{% highlight powershell %}$collectionUri = Get-BuildCollectionUri{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The Uri of the TFS project collection containing the project being built.</p>

		<a name="get_builddroplocation_cmdlet"><hr></a>
		<h3>Get-BuildDropLocation</h3>
		<p>Gets the remote UNC path into which build assets should be placed. You can use the 
		<a href="#publish_buildassets_cmdlet">Publish-BuildAssets</a> and 
		<a href="#get_buildassets_cmdlet">Get-BuildAssets</a> cmdlets to push and pull files between 
		the local directory and the one returned by calling this function.</p>
		<h4>Example</h4>
		{% highlight powershell %}$dropLocation = Get-BuildDropLocation{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The remote UNC path into which build assets should be placed.</p>

		<a name="get_buildenvironment_cmdlet"><hr></a>
		<h3>Get-BuildEnvironment</h3>
		<p>Gets the environment the currently executing build is targeting. Should be "Local", "Commit", "Test", "CapacityTest", or "Production".</p>
		<h4>Example</h4>
		{% highlight powershell %}$environment = Get-BuildEnvironment{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The environment the currently executing build is targeting for deployment.</p>
		
		<a name="get_buildmoduleconfig_cmdlet"><hr></a>
		<h3>Get-BuildModuleConfig</h3>
		<p>Gets the Module configuration file used for the build. You should not call this 
		cmdlet in your script directly. Use it from a <a href="#modules">delivery module</a>.</p>
		<h4>Example</h4>
		{% highlight powershell %}$moduleConfig = Get-BuildModuleConfig{% endhighlight %}
		<h4>Outputs</h4>
		<p>YAML - The YAML configuration object used by delivery modules to get settings.</p>
		
		<a name="invoke_msbuild_cmdlet"><hr></a>
		<h3>Invoke-MSBuild</h3>
		<p>This cmdlet is used to compile a MSBuild-compatible project or solution. 
		You should always use this cmdlet instead of a direct call to msbuild.exe or existing 
		cmdlets you may have found online when working with powerdelivery.</p>
		<p>This cmdlet provides the following essential continuous delivery features:</p>
		<ol>
			<li>Updates the version of any AssemblyInfo.cs (or AssemblyInfo.vb) files with the current build version. This causes all of your binary files to have the build number. For example, if your build pipeline's version in the script is set to 1.0.2 and this is a build against changeset C234, the version of your assemblies will be set to 1.0.2.234. The assembly version will still have the version specified in the build without the changeset appended (3 part versioning).</li>
			<li>Reports warnings and errors encountered back to TFS for viewing on the build summary page.</li>
			<li>Reports the status of the compilation back to TFS for viewing on the build summary page.</li>
		</ol>
		<h4>Example</h4>
		{% highlight powershell %}Invoke-MSBuild MyProject/MySolution.sln -properties  @{MyCustomProp = SomeValue}{% endhighlight %}
		<h4>Parameters</h4>
		<h5>projectFile</h5>
		<p>string - A relative path at or below the script directory that contains an MSBuild project or solution to compile.</p>
		<h5>target</h5>
		<p>string - Optional. The name of the MSBuild target to invoke in the project file. Defaults to the default target specified within the project file.</p>
		<h5>properties</h5>
		<p>hash - Optional. A PowerShell hash containing name/value pairs to set as MSBuild properties.</p>
		<h5>toolsVersion</h5>
		<p>string - Optional. The version of MSBuild to run ("2.0", "3.5", "4.0", etc.). The default is "4.0".</p>
		<h5>verbosity</h5>
		<p>string - Optional. The verbosity of this MSBuild compilation. The default is "m".</p>
		<h5>buildConfiguration</h5>
		<p>string - Optional. The default is to use the same as the environment name. Create build configurations named "Commit", "Test", and "Production" with appropriate settings in your projects.</p>
		<h5>flavor</h5>
		<p>string - Optional. The platform configuration (x86, x64 etc.) of this MSBuild complation. The default is "AnyCPU".</p>
		<h5>ignoreProjectExtensions</h5>
		<p>string - Optional. A semicolon-delimited list of project extensions (".smproj;.csproj" etc.) of projects in the solution to not compile.</p>
		<h5>dotNetVersion</h5>
		<p>string - Optional. The .NET version to use for compilation. Defaults to the version specified in the project file(s) being built.</p>
		<a name="modules"><hr></a>
		<br />
		<h2>Delivery modules</h2>
		<p>This section includes the reference for all the included powerdelivery 
		delivery modules. See the <a href="/create.html#modules">using delivery modules</a> 
		topic from the <a href="/create.html">creating deployment pipelines</a> article 
		for an overview of the usage and philosophy behind using these modules. You can also 
		create your own.</p>
		<a name="modules"><hr></a>
	</div>
</div>
