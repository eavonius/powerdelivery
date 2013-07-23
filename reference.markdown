---
layout: page
---
<div class="row-fluid">
	<div class="span3 hidden-tablet">
		<ul class="nav nav-list">
			<h5>Article contents</h5>
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
				<a href="#get_buildconfig_cmdlet">Get-BuildConfig</a>
			</li>
			<li>
				<a href="#get_builddroplocation_cmdlet">Get-BuildDropLocation</a>
			</li>
			<li>
				<a href="#get_buildenvironment_cmdlet">Get-BuildEnvironment</a>
			</li>
			<li>
				<a href="#get_buildname_cmdlet">Get-BuildName</a>
			</li>
			<li>
				<a href="#get_buildnumber_cmdlet">Get-BuildNumber</a>
			</li>
			<li>
				<a href="#get_buildonserver_cmdlet">Get-BuildOnServer</a>
			</li>
			<li>
				<a href="#get_buildrequestedby_cmdlet">Get-BuildRequestedBy</a>
			</li>
			<li>
				<a href="#get_buildsetting_cmdlet">Get-BuildSetting</a>
			</li>
			<li>
				<a href="#get_buildteamproject_cmdlet">Get-BuildTeamProject</a>
			</li>
			<li>
				<a href="#get_builduri_cmdlet">Get-BuildUri</a>
			</li>
			<li>
				<a href="#get_buildworkspacename_cmdlet">Get-BuildWorkspaceName</a>
			</li>
			<li>
				<a href="#import_deliverymodule_cmdlet">Import-DeliveryModule</a>
			</li>
			<li>
				<a href="#invoke_buildconfigsection_cmdlet">Invoke-BuildConfigSection</a>
			</li>
			<li>
				<a href="#invoke_buildconfigsections_cmdlet">Invoke-BuildConfigSections</a>
			</li>
			<li>
				<a href="#invoke_msbuild_cmdlet">Invoke-MSBuild</a>
			</li>
			<li>
				<a href="#invoke_mstest_cmdlet">Invoke-MSTest</a>
			</li>
			<li>
				<a href="#invoke_powerdelivery_cmdlet">Invoke-PowerDelivery</a>
			</li>
			<li>
				<a href="#invoke_roundhouse_cmdlet">Invoke-Roundhouse</a>
			</li>
			<li>
				<a href="#invoke_ssispackage_cmdlet">Invoke-SSISPackage</a>
			</li>
			<li>
				<a href="#publish_buildassets_cmdlet">Publish-BuildAssets</a>
			</li>
			<li>
				<a href="#publish_ssas_cmdlet">Publish-SSAS</a>
			</li>
			<li>
				<a href="#publish_webdeploy_cmdlet">Publish-WebDeploy</a>
			</li>
			<li>
				<a href="#register_deliverymodulehook_cmdlet">Register-DeliveryModuleHook</a>
			</li>
			<li>
				<a href="#set_ssasconnection_cmdlet">Set-SSASConnection</a>
			</li>
			<li>
				<a href="#start_sqljobs_cmdlet">Start-SqlJobs</a>
			</li>
			<li>
				<a href="#write_buildsummarymessage_cmdlet">Write-BuildSummaryMessage</a>
			</li>
			<li class="nav-header">
				<a href="#modules">Delivery modules</a>
			</li>
			<li>
				<a href="#msbuild_module">MSBuild</a>
			</li>
			<li>
				<a href="#mstest_module">MSTest</a>
			</li>
			<li>
				<a href="#roundhouse_module">Roundhouse</a>
			</li>
			<li>
				<a href="#webdeploy_module">WebDeploy</a>
			</li>
		</ul>
	</div>
	<div class="span9 span12-tablet">
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
		cmdlets. See the <a href="create.html#cmdlets">using cmdlets</a> 
		topic from the <a href="create.html">creating deployment pipelines</a> article 
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

		<a name="get_buildconfig_cmdlet"><hr></a>
		<h3>Get-BuildConfig</h3>
		<p>Gets the configuration used for the build. This object contains the results of merging the 
		shared and environment-specific configuration files for the target environment being deployed to. 
		The <a href="get_buildsetting_cmdlet">Get-BuildSetting</a> cmdlet provides the same functionality 
		as this one, however that cmdlet will throw an exception of the requested setting is not found. 
		You can use this cmdlet to retrieve the entire top-level configuration and check for the presence 
		of a section, if you know a section may not be present at build time.</p>
		<h4>Example</h4>
		{% highlight powershell %}$config = Get-BuildConfig

if ($config.MySetting) {
  $mySetting = $config.MySetting
}{% endhighlight %}
		<h4>Outputs</h4>
		<p>hash - A combined hash that is the result of merging the shared and environment-specific configuration 
		file, appropriate for the target environment being built to.</p>

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
		
		<a name="get_buildname_cmdlet"><hr></a>
		<h3>Get-BuildName</h3>
		<p>Gets the name of the currently executing build. This value will match the name of the build as viewed in TFS and must be used to call some TFS APIs.</p>
		<h4>Example</h4>
		{% highlight powershell %}$name = Get-BuildName{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The name of the currently executing build.</p>
		
		<a name="get_buildnumber_cmdlet"><hr></a>
		<h3>Get-BuildNumber</h3>
		<p>Gets the number of the currently executing build. This value must be used to call some TFS APIs.</p>
		<h4>Example</h4>
		{% highlight powershell %}$number = Get-BuildNumber{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The number of the currently executing build.</p>
		
		<a name="get_buildonserver_cmdlet"><hr></a>
		<h3>Get-BuildOnServer</h3>
		<p>Gets whether the build is executing on the build server or not.</p>
		<h4>Example</h4>
		{% highlight powershell %}$onServer = Get-BuildOnServer{% endhighlight %}
		<h4>Outputs</h4>
		<p>bool - Whether the build is executing on the build server or not.</p>
		
		<a name="get_buildrequestedby_cmdlet"><hr></a>
		<h3>Get-BuildRequestedBy</h3>
		<p>Gets the account name of the user who requested the build.</p>
		<h4>Example</h4>
		{% highlight powershell %}$requestedBy = Get-BuildRequestedBy{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The account name of the user who requested the build.</p>
		
		<a name="get_buildsetting_cmdlet"><hr></a>
		<h3>Get-BuildSetting</h3>
		<p>Gets a environment setting from the combined result of merging the shared and environment-specific 
		.yml configuration files, using the environment the currently executing build is targeting.</p>
		<h4>Example</h4>
		{% highlight powershell %}$webServerName = Get-BuildSetting WebServerName{% endhighlight %}
		<h4>Parameters</h4>
		<h5>name</h5>
		<p>The name of the setting from the .yml file to get.</p>
		<h4>Outputs</h4>
		<p>string or hash - The value of the setting from the .yml file for the setting that was requested. 
		If the value is a simple name/value pair a string will be returned, otherwise a hash of the nested 
		settings below the requested section.</p>
		
		<a name="get_buildteamproject_cmdlet"><hr></a>
		<h3>Get-BuildTeamProject</h3>
		<p>Gets the name of the TFS project the build is delivering assets for.</p>
		<h4>Example</h4>
		{% highlight powershell %}$teamProject = Get-BuildTeamProject{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The name of the TFS project the build is delivering assets for.</p>
		
		<a name="get_builduri_cmdlet"><hr></a>
		<h3>Get-BuildUri</h3>
		<p>Gets the URI the build when running on TFS. This URI is required to 
		make some calls to the TFS API and should not be necessary for you 
		to use for most operations.</p>
		<h4>Example</h4>
		{% highlight powershell %}$uri = Get-BuildUri{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The URI of the build when running on TFS.</p>
		
		<a name="get_buildworkspacename_cmdlet"><hr></a>
		<h3>Get-BuildWorkspaceName</h3>
		<p>Gets the name of the TFS source control workspace name used to get a copy of the source code to compile.</p>
		<h4>Example</h4>
		{% highlight powershell %}$workspaceName = Get-BuildWorkspaceName{% endhighlight %}
		<h4>Outputs</h4>
		<p>string - The name of the TFS source control workspace name used to get a copy of the source code to compile.</p>
		
		<a name="import_deliverymodule_cmdlet"><hr></a>
		<h3>Import-DeliveryModule</h3>
		<p>Imports a <a href="#modules">delivery module</a> for use by a delivery pipeline.</p>
		<h4>Example</h4>
		{% highlight powershell %}Import-DeliveryModule MSBuild{% endhighlight %}
		<h4>Parameters</h4>
		<h5>name</h5>
		<p>string - The name of the delivery module to import functions for.</p>
		
		<a name="invoke_buildconfigsection_cmdlet"><hr></a>
		<h3>Invoke-BuildConfigSection</h3>
		<p>Invokes a PowerShell cmdlet passing a section of YAML from the build 
		<a href="create.html#environment">environment configuration</a> 
		as arguments to it.</p>
		<h4>Example</h4>
		<p>In the example below, there is a YAML configuration section named "Database" 
		with settings that match the arguments of the "Invoke-Roundhouse" cmdlet.</p>
		{% highlight powershell %}$databaseSection = Get-BuildSetting Database
Invoke-BuildConfigSection $databaseSection "Invoke-Roundhouse"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>section</h5>
		<p>hash - Each value of the hash will be passed to the cmdlet as arguments.</p>
		<h5>cmdlet</h5>
		<p>string - The name of the cmdlet to invoke.</p>

		<a name="invoke_buildconfigsections_cmdlet"><hr></a>
		<h3>Invoke-BuildConfigSections</h3>
		<p>Calls the <a href="#invoke_buildconfigsection_cmdlet">Invoke-BuildConfigSection</a> 
		cmdlet once for each entry in a hash. Use this to do work on all nested entries in a section of YAML 
		from the build <a href="create.html#environment">environment configuration</a>.</p>
		<h4>Example</h4>
		<p>In th example below, there is a YAML configuration section named "MSBuild" 
		with YAML sections below it. Each entry below it has settings that match the 
		arguments of the "Invoke-MSBuild" cmdlet.</p>
		{% highlight powershell %}$msBuildSection = Get-BuildSetting MSBuild
Invoke-BuildConfigSections $msBuildSection "Invoke-MSBuild"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>section</h5>
		<p>hash - Each value of the hash will be passed to <a href="#invoke_buildconfigsection_cmdlet">Invoke-BuildConfigSection</a> cmdlet.</p>
		<h5>cmdlet</h5>
		<p>string - The name of the cmdlet to invoke.</p>

		<a name="invoke_msbuild_cmdlet"><hr></a>
		<h3>Invoke-MSBuild</h3>
		<p>This cmdlet is used to compile a MSBuild-compatible project or solution. 
		You should always use this cmdlet instead of a direct call to msbuild.exe or existing 
		cmdlets you may have found online when working with powerdelivery.</p>
		<p>This cmdlet provides the following essential continuous delivery features:</p>
		<ul>
			<li>Updates the version of any AssemblyInfo.cs (or AssemblyInfo.vb) files 
			with the current build version. This causes all of your binary files to 
			have the build number. For example, if your build pipeline's version 
			in the script is set to 1.0.2 and this is a build against changeset C234, 
			the assembly version of your files will be set to 1.0.2 and the file version will 
			be set to 1.0.2.234.</li>
			<li>Reports warnings and errors encountered back to TFS for viewing on the build summary page.</li>
			<li>Reports the status of the compilation back to TFS for viewing on the build summary page.</li>
		</ul>
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

		<a name="invoke_mstest_cmdlet"><hr></a>
		<h3>Invoke-MSTest</h3>
		<p>The Invoke-MSTest cmdlet is used to run unit or acceptance tests using mstest.exe. You should always use this cmdlet instead of a direct call to mstest.exe or existing cmdlets you may have found online when working with powerdelivery.</p>
		<p>This cmdlet reports the results of the test run back to TFS to be viewed in the build summary.</p>
		<p>IMPORTANT: You most only call Invoke-MSTest in the 
		<a href="create.html#test_units_block">TestUnits</a> or <a href="create.html#test_acceptance_block">TestAcceptance</a> blocks.</p>
		<h4>Example</h4>
		{% highlight powershell %}Invoke-MSTest -file MyTests.dll -results MyTestResults.trx -category AllTests{% endhighlight %}
		<h4>Parameters</h4>
		<h5>file</h5>
		<p>string - The path to a file containing MSTest unit tests.</p>
		<h5>results</h5>
		<p>string - A path relative to the drop location (retrieved via Get-BuildDropLocation) of a test run results file (.trx) to store results in.</p>
		<h5>category</h5>
		<p>string - Runs tests found in the file referenced by the <b>file</b> parameter on any classes found with the [TestCategory] attribute present set to this value.</p>
		<h5>platform</h5>
		<p>string - Optional. The platform configuration (x86, x64 etc.) of this MSBuild compilation. The default is "AnyCPU".</p>
		<h5>buildConfiguration</h5>
		<p>string - Optional. The default is to use the Release configuration.</p>
		
		<a name="invoke_powerdelivery_cmdlet"><hr></a>
		<h3>Invoke-PowerDelivery</h3>
		<p>Runs a continuous delivery build script using powerdelivery. If you run the PowerShell 
		<b>get-help</b> cmdlet against Invoke-PowerDelivery you will notice there are other parameters 
		available to pass here. However, you should only ever specify the <b>buildScript</b> 
		parameter when running this function on your own computer. All other parameters are used 
		by the TFS server and require the script running as part of a TFS build.</p>
		<h4>Example</h4>
		{% highlight powershell %}Invoke-PowerDelivery .\MyProduct.ps1{% endhighlight %}
		<h4>Parameters</h4>
		<h5>buildScript</h5>
		<p>string - The relative path to to a local powerdelivery build script to run.</p>
		
		<a name="invoke_roundhouse_cmdlet"><hr></a>
		<h3>Invoke-Roundhouse</h3>
		<p>This cmdlet will run migration scripts on a database using the 
		<a href="https://code.google.com/p/roundhouse/" target="_blank">RoundhousE</a> database migration tool.</p>
		<p>In the <a href="create.html#compile_block">Compile</a> block of your build, 
		you should copy the directory containing your RoundhousE scripts to a subdirectory 
		of the drop location named "Databases". For example, if you had a database named 
		"MyDatabase" you'd have the following directory in TFS with your scripts:</p>
		<p>
			<code>$/MyProject/Databases/MyDatabase</code>
		</p>
		<p>You should copy them in Compile to here:</p>
		<p>
			<code>\DropLocation\Databases\MyDatabase</code>
		</p>
		<p>where <i>DropLocation</i> above is the result of a call to the 
		<a href="#get_builddroplocation_cmdlet">Get-BuildDropLocation</a> cmdlet.</p>
		<p>Because RoundhousE cannot use UNC paths, you will need to copy those 
		scripts in the Deploy block back to a local directory using the <a href="#get_buildassets">Get-BuildAssets</a> 
		cmdlet so you can pass their local location as the <b>scriptsDir</b> parameter.</p>
		<p>Additionally, powerdelivery passes the name of the environment returned by a call to the 
		<a href="#get_buildenvironment_cmdlet">Get-BuildEnvironment</a> cmdlet 
		to RoundhouseE to allow your scripts to take advantage of 
		<a href="https://github.com/chucknorris/roundhouse/wiki/EnvironmentScripts" target="_blank">environment scripts</a>.</p>
		<p><b>IMPORTANT</b>: Only call Invoke-Roundhouse in the <a href="create.html#deploy_block">Deploy</a> block.</p>
		<h4>Example</h4>
		<p>The example below restores from a production backup before running database migrations. You can 
		choose to only do this in production builds, or eliminate it altogether by omitting the <b>restorePath</b> 
		and <b>restoreOptions</b> parameters.</p>
		{% highlight powershell %}Init {
  $script:dbServer = Get-BuildSetting DatabaseServer
  $script:dbName   = Get-BuildSetting DatabaseName

  $script:dbDir     = Join-Path $currentDirectory Databases
  $script:dbDropDir = Join-Path $dropLocation Databases

  $script:productionBackup = D:\Backups\MyDatabase_Latest.mdf
  $script:dataDir = "C:\Program Files\Microsoft SQL Server10\MSAS11.MSSQLSERVER\MSSQL\Data"
}

Compile {
  copy -Recurse -Filter *.* $dbDir $dropLocation
}

Deploy {
  Invoke-Roundhouse -server $dbServer `
                    -database $dbName `
                    -scriptsDir "$dbDropDir\MyDatabase" `
                    -restorePath $productionBackup `
                    -restoreOptions "MOVE 'MyDatabase' TO '$($dataDir)\$($dbName).mdf', MOVE 'MyDatabase_log' TO '$($dataDir)\$($dbName).ldf', REPLACE, RECOVERY"
}{% endhighlight %}
		<h4>Parameters</h4>
		<h5>scriptsDir</h5>
		<p>string - Path to the directory containing RoundhousE migration scripts to run. Should be a subdirectory of your build's drop location.</p>
		<h5>database</h5>
		<p>string - The name of the database to run scripts against.</p>
		<h5>server</h5>
		<p>string - Optional. The name of the SQL server to run scripts against. Use this or the connectionString parameter.</p>
		<h5>connectionString</h5>
		<p>string - Optional. The connection string to the database. Use this or the server parameter.</p>
		<h5>restorePath</h5>
		<p>string - Optional. Path to a .mdf file (backup) of a database file to restore. Until you have a database in production don't specify this property in your build. Once you have a database in production, if you specify the path to your latest production backup file, this be restored prior to running migration scripts. This allows you to test the changes exactly as they would be applied were the current build released to production.</p>
		<h5>restoreOptions</h5>
		<p>string - Optional. A string of options to pass to the RESTORE T-SQL statement performed. Use this to specify for instance the .sql and .log file paths that should be used instead of the ones contained within the backup file.</p>
		
		<a name="invoke_ssispackage_cmdlet"><hr></a>
		<h3>Invoke-SSISPackage</h3>
		<p>Executes a Microsoft <a href="http://msdn.microsoft.com/en-us/library/ms141026.aspx" target="_blank">SQL Server Integration Services</a> (SSIS) package. This cmdlet runs <a href="http://msdn.microsoft.com/en-us/library/ms162810(v=sql.105).aspx" target="_blank">dtexec.exe</a> on a remote computer.</p>
		<p>Copy your .dtsx packages to a UNC network share within the <a href="create.html#deploy_block">Deploy</a> block of your script onto each computer you wish to run packages on.</p>
		<h4>Example</h4>
		{% highlight powershell %}$dtExecPath = "C:\Program Files\Microsoft SQL Server\110\Dts\Binn\dtexec.exe"
		
Invoke-SSIS -package MyPackage.dtsx -server MyServer -dtExecPath $dtExecPath{% endhighlight %}
		<h4>Parameters</h4>
		<h5>package</h5>
		<p>string - A path local to the remote server the package is being executed on. If you had a UNC share on that server "\\MyServer\MyShare" and it was mapped to "D:\Somepath", use "D:\Somepath" here.</p>
		<h5>server</h5>
		<p>string - The computer name onto which to execute the package. This computer must have PowerShell 3.0 with WinRM installed, and allow execution of commands from the TFS build server and the account under which the build agent service is running.</p>
		<h5>dtExecPath</h5>
		<p>string - The path to dtexec.exe on the server to run the command.</p>
		<h5>packageArgs</h5>
		<p>Optional. A PowerShell hash containing name/value pairs to set as package arguments to dtexec.</p>
		
		<a name="publish_buildassets_cmdlet"><hr></a>
		<h3>Publish-BuildAssets</h3>
		<p>Copies build assets from the build working directory to the remote UNC drop location. You should specify relative paths for this command.</p>
		<h4>Example</h4>
		{% highlight powershell %}Publish-BuildAssets "SomeDir\SomeFiles\*.*" SomeDir{% endhighlight %}
		<h4>Parameters</h4>
		<h5>path</h5>
		<p>string - The relative local path of assets in the current directory that should be copied remotely.</p>
		<h5>destination</h5>
		<p>string - The relative remote path to copy the assets to.</p>
		<h5>filter</h5>
		<p>string - Optional. A filter for the file extensions that should be included.</p>
		<h5>recurse</h5>
		<p>bool - Optional. Specifies whether to recursively copy all files in subdirectories of the path specified by the <b>path</b> parameter.</p>
		
		<a name="publish_ssas_cmdlet"><hr></a>
		<h3>Publish-SSAS</h3>
		<p>The Publish-SSAS cmdlet will deploy a <a href="http://msdn.microsoft.com/en-us/library/ms175609(v=sql.90).aspx" target="_blank">Microsoft SQL Server Analysis Services</a> (SSAS) .asdatabase file to a server.</p>
		<p>Before you call the cmdlet, copy the .asdatabase to a computer that has the <a href="http://msdn.microsoft.com/en-us/library/ms162758.aspx" target="_blank">SQL Server Analysis Services Deployment Utility</a> installed.</p>
		<h4>Example</h4>
		{% highlight powershell %}Publish-SSAS -computer MyServer -tabularServer "MyServer\INSTANCE" -asDatabase "Cubes\MyModel.asdatabase"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>computer</h5>
		<p>string - The computer to run the SSAS deployment utility on.</p>
		<h5>asDatabase</h5>
		<p>string - The .asdatabase file to deploy. This is a path local to the computer specified by the <b>computer</b> parameter.</p>
		<h5>tabularServer</h5>
		<p>string - The server name of the SSAS instance. In a SQL cluster this will be the cluster name.</p>
		<h5>cubeName</h5>
		<p>string - Optional. The name to deploy the cube as. Can only be omitted if only one cube (model) is included in the asdatabase package.</p>
		<h5>sqlVersion</h5>
		<p>string - Optional. The version of SQL to use. Default is "11.0"</p>
		<h5>deploymentUtilityPath</h5>
		<p>string - Optional. The full path to the Microsoft.AnalysisServices.DeploymentUtility.exe command-line tool on the computer specified by the <b>computer</b> parameter.</p>
		
		<a name="register_deliverymodulehook_cmdlet"><hr></a>
		<h3>Register-DeliveryModuleHook</h3>
		<p>Use this cmdlet in a powerdelivery <a href="#modules">delivery module</a> to register a function 
		so that it gets called before or after a <a href="create.html#script_blocks">script block</a> in a delivery build script 
		that has imported it with the <a href="#import_deliverymodule_cmdlet">Import-DeliveryModule</a> cmdlet.</p>
		<p>For example, you can write code in a delivery module that runs before the <a href="create.html#compile_block">Compile</a> block 
		in the importing script.</p>
		<h4>Example</h4>
		<p>Below is an example from the <a href="#msbuild_module">MSBuild delivery module</a>. It causes 
		code to run prior to the <a href="create.html#compile_block">Compile</a> block in the importing script.</p>
		{% highlight powershell %}function Initialize-MSBuildDeliveryModule {
  Register-DeliveryModuleHook 'PreCompile' {
    // Put code here to run before the Compile block
  }
}{% endhighlight %}
		<h4>Parameters</h4>
		<h5>function</h5>
		<p>string - The name of a <a href="create.html#script_blocks">script block</a> to "hook" prefixed with "Pre" or "Post" to have the 
		module hook code run before or after the importing script's function respectively.</p>
		<p><b>function</b> can be one of the following values:</p>
		<ul>
			<li>PreInit</li>
			<li>PostInit</li>
			<li>PreCompile</li>
			<li>PostCompile</li>
			<li>PreSetupEnvironment</li>
			<li>PostSetupEnvironment</li>
			<li>PreTestEnvironment</li>
			<li>PostTestEnvironment</li>
			<li>PreDeploy</li>
			<li>PostDeploy</li>
			<li>PreTestAcceptance</li>
			<li>PostTestAcceptance</li>
			<li>PreTestUnits</li>
			<li>PostTestUnits</li>
			<li>PreTestCapacity</li>
			<li>PostTestCapacity</li>
		</ul>

		<a name="set_ssasconnection_cmdlet"><hr></a>
		<h3>Set-SSASConnection</h3>
		<p>Sets a connection string on a deployed <a href="http://msdn.microsoft.com/en-us/library/ms175609(v=sql.90).aspx" target="_blank">Microsoft SQL Server Analysis Services</a> (SSAS) cube.</p>
		<h4>Example</h4>
		{% highlight powershell %}Set-SSASConnection -computer MyServer -tabularServer MyServer\TABULAR -databaseName MyCube -datasourceID "{4CC0937D-61D3-421E-B607-B3E36D1D09B5}" -connectionString "Initial Catalog=MyDB;Server=localhost;Trusted Connection=yes"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>computer</h5>
		<p>string - The computer to which the SSAS cube was deployed.</p>
		<h5>tabularServer</h5>
		<p>string - The instance of the SSAS server to change the connection on.</p>
		<h5>databaseName</h5>
		<p>string - The name of the SSAS database/cube to change the connection on.</p>
		<h5>datasourceID</h5>
		<p>string - The GUID of the connection to change. Use SQL Server Management Studio to browse the 
		cube deployed locally or remotely and open the properties dialog on the connection to change. The ID 
		will be listed there. This value does not change between deployments but is a required parameter here.</p>
		<h5>connectionName</h5>
		<p>The name of the connection to change.</p>
		<h5>connectionString</h5>
		<p>The value to change the connection to.</p>

		<a name="start_sqljobs_cmdlet"><hr></a>
		<h3>Start-SqlJobs</h3>
		<p>This cmdlet can start one or more sql jobs who's name(s) match the pattern provided.</p>
		<h4>Example</h4>
		{% highlight powershell %}Start-SqlJobs -serverName MyServer -jobs "Purchasing*"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>serverName</h5>
		<p>string - The SQL server name of the SQL instance to start jobs on.</p>
		<h5>jobs</h5>
		<p>string - The name of the job(s) to start. You can use wildcards or a single name.</p>
		
		<a name="write_buildsummarymessage_cmdlet"><hr></a>
		<h3>Write-BuildSummaryMessage</h3>
		<p>Writes a message to a section to the <a href="use.html#build_summary">build summary</a>. Specify as the <b>name</b> parameter 
		the name of a <a href="create.html#script_blocks">script block</a> from your delivery pipeline script. 
		For example, pass "Compile" to have your message appear under that section of the build summary.</p>
		<p><b>NOTE</b>: This function will output a warning and not do anything on TFS versions prior to 2012.</p>
		<h4>Example</h4>
		{% highlight powershell %}Write-BuildSummaryMessage "Compile" "Compilations" "My Message"{% endhighlight %}
		<h4>Parameters</h4>
		<h5>name</h5>
		<p>string - The name of the section to write the message to.</p>
		<h5>header</h5>
		<p>string - The text of the section to display (ignored if any other message was already written to this section).</p>
		<h5>message</h5>
		<p>string - The message to add to the section specified.</p>
		
		<a name="modules"><hr></a>
		<br />
		<h2>Delivery modules</h2>
		<p>This section includes the reference for all the included powerdelivery 
		delivery modules. See the <a href="create.html#modules">using delivery modules</a> 
		topic from the <a href="create.html">creating deployment pipelines</a> article 
		for an overview of the usage and philosophy behind using these modules. You can also 
		create your own.</p>
		
		<a name="msbuild_module"></hr></a>
		<br />
		<h3>MSBuild Module</h3>
		<p>This module will compile MSBuild projects by calling the <a href="#invoke_msbuild_cmdlet">Invoke-MSBuild</a> cmdlet. 
		It provides identical functionality to that cmdlet, and should be easier to use than the cmdlet by itself if you don't need to have 
		compilations occur in a specific order. If that is the case, you should use the cmdlet since you can place logic around calls to it 
		and also control the order relative to other PowerShell code in the <a href="create.html#compile_block">Compile</a> block.</p>
		<br />
		<h4>Referencing the module</h4>
		<p>Add the following to the top of your delivery pipeline script:</p>
		<p>
			<code>Import-Module MSBuild</code>
		</p>
		<br />
		<h4>When it runs</h4>
		<p>The compilation of any MSBuild projects configured using this module will occur just <b>before</b> the 
		<a href="create.html#compile_block">Compile</a> block of your script is called for those build environments 
		to which that block applies.</p>
		<br />
		<h4>Configuring the module</h4>
		<p>Add a section named <b>MSBuild</b> to an <a href="create.html#environment">environment configuration file</a> with a 
		YAML section below it for each deployment you wish to occur during your build. Each section you define must have the following settings:</p>
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
		<br/>
		<h4>Example configuration</h4>
		{% highlight yaml %}MSBuild:
  MySolution:
    ProjectFile: MySolutionFolder/MySolution.sln
  MyOtherProject:
    ProjectFile: MyOtherProject/MyOtherProject.csproj
    Target: Build
    Flavor: x64
    Properties:
      SomeProperty: 1
      SomeOtherProperty: 2{% endhighlight %}
	  
		<a name="mstest_module"></hr></a>
		<br />
		<h3>MSTest Module</h3>
		<p>This module will run tests using the <a href="#invoke_mstest_cmdlet">Invoke-MSTest</a> cmdlet. 
		It provides identical functionality to that cmdlet, and should be easier to use than the cmdlet by itself if you don't need to have 
		test projects executed in a specific order. If that is the case, you should use the cmdlet since you can place logic around calls to it 
		and also control the order relative to other PowerShell code in the <a href="create.html#test_units_block">TestUnits</a> (for unit tests) 
		or <a href="create.html#test_acceptance_block">TestAcceptance</a> (for acceptance tests) blocks.</p>
		<br />
		<h4>Referencing the module</h4>
		<p>Add the following to the top of your delivery pipeline script:</p>
		<p>
			<code>Import-Module MSTest</code>
		</p>
		<br />
		<h4>When it runs</h4>
		<p>The execution of any libraries containing tests configured using this module will occur just <b>before</b> the 
		<a href="create.html#test_units_block">TestUnits</a> block of your script, or just <b>before</b> the 
		<a href="create.html#test_acceptance_block">TestAcceptance</a> block when those blocks are called for those build environments 
		to which that block applies.</p>
		<br />
		<h4>Configuring the module</h4>
		<p>Add a section named <b>MSTest</b> to your <a href="create.html#environment">environment configuration file</a> with a 
		section named <b>UnitTests</b> or <b>AcceptanceTests</b> below it containing 
		YAML sections below them for each set of tests you wish to run during your build. You can include unit tests and acceptance tests, 
		or just one type by choosing to include or omit those sections. Each section you define must have the following settings:</p>
		<h5>file</h5>
		<p>string - The path to a file containing MSTest unit tests.</p>
		<h5>results</h5>
		<p>string - A path relative to the drop location (retrieved via Get-BuildDropLocation) of a test run results file (.trx) to store results in.</p>
		<h5>category</h5>
		<p>string - Runs tests found in the file referenced by the file parameter on any classes found with the [TestCategory] attribute present set to this value.</p>
		<h5>platform</h5>
		<p>string - Optional. The platform configuration (x86, x64 etc.) of this MSBuild compilation. The default is "AnyCPU".</p>
		<h5>buildConfiguration</h5>
		<p>string - Optional. The default is to use the Release configuration.</p>
		<br/>
		<h4>Example configuration</h4>
		{% highlight yaml %}MSTest:
  UnitTests:
    MyUnitTests: 
      File: UnitTests/MyUnitTestLibrary.dll
      Results: UnitTestsMyUnitTestResults.trx
      Category: MyTestCategory
  AcceptanceTests:
    MyAcceptanceTests:
      File: AcceptanceTests/MyAcceptanceTestLibrary.dll
      Results: AcceptanceTestResults.trx
      Category: MyTestCategory{% endhighlight %}
	  
		<a name="roundhouse_module"></hr></a>
		<br />
		<h3>Roundhouse Module</h3>
		<p>This module will run database migrations using the <a href="#invoke_roundhouse_cmdlet">Invoke-Roundhouse</a> cmdlet. 
		It provides identical functionality to that cmdlet, and should be easier to use than the cmdlet by itself if you don't need to have 
		database deployments executed in a specific order. If that is the case, you should use the cmdlet since you can place logic around calls to it 
		and also control the order relative to other PowerShell code in the <a href="create.html#deploy_block">Deploy</a> block.</p>
		<br />
		<h4>Referencing the module</h4>
		<p>Add the following to the top of your delivery pipeline script:</p>
		<p>
			<code>Import-Module Roundhouse</code>
		</p>
		<br />
		<h4>When it runs</h4>
		<p>The execution of any libraries containing tests configured using this module will occur just <b>after</b> the 
		<a href="deploy.html#deploy_block">Deploy</a> block of your script when those blocks are called for those build environments 
		to which that block applies.</p>
		<br />
		<h4>Configuring the module</h4>
		<p>Add a section named <b>Roundhouse</b> to your <a href="create.html#environment">environment configuration file</a> with a 
		YAML section below it for each database you wish to migrate changes to during your build. Each section you define must have the following settings:</p>
		<h5>scriptsDir</h5>
		<p>string - Path to the directory containing RoundhousE migration scripts to run. Should be a subdirectory of your build's drop location.</p>
		<h5>database</h5>
		<p>string - The name of the database to run scripts against.</p>
		<h5>server</h5>
		<p>string - Optional. The name of the SQL server to run scripts against. Use this or the connectionString parameter.</p>
		<h5>connectionString</h5>
		<p>string - Optional. The connection string to the database. Use this or the server parameter.</p>
		<h5>restorePath</h5>
		<p>string - Optional. Path to a .mdf file (backup) of a database file to restore. Until you have a database in production don't specify this property in your build. Once you have a database in production, if you specify the path to your latest production backup file, this be restored prior to running migration scripts. This allows you to test the changes exactly as they would be applied were the current build released to production.</p>
		<h5>restoreOptions</h5>
		<p>string - Optional. A string of options to pass to the RESTORE T-SQL statement performed. Use this to specify for instance the .sql and .log file paths that should be used instead of the ones contained within the backup file.</p>
		<br/>
		<h4>Example configuration</h4>
		{% highlight yaml %}Roundhouse:
  DatabaseOne:
    ScriptsDir: Databases\DatabaseOne
    Server: MyServer
    Database: DatabaseOne
  DatabaseTwo:
    ScriptsDir: Databases\DatabaseTwo
    Server: MyServer
    Database: DatabaseTwo{% endhighlight %}
		
		<a name="webdeploy_module"></hr></a>
		<br />
		<h3>WebDeploy Module</h3>
		<p>This module can be used to deploy a web application using <a href="http://www.iis.net/downloads/microsoft/web-deploy" target="_blank">Microsoft Web Deploy 3.0</a>. 
		Use the <a href="#invoke_msbuild_cmdlet">Invoke-MSBuild</a> cmdlet to compile a project so that the web deploy package (.zip file) you want to deploy is created.</p>
		<p>You will also want to use the <a href="http://www.microsoft.com/web/downloads/platform.aspx" target="_blank">Microsoft Web Platform Installer</a> on the web server to which you will deploy. Select "Recommended Configuration for Hosting Providers" 
		from the feature list. This will install Web Deploy 3.0 and appropriate security settings for this module to work. See 
		<a href="http://www.iis.net/learn/install/installing-publishing-technologies/installing-and-configuring-web-deploy" target="_blank">this article from Microsoft</a> 
		for an overview as well as troubleshooting relating to setting up a server for web deploy.</p>
		<br />
		<h4>Referencing the module</h4>
		<p>Add the following to the top of your delivery pipeline script:</p>
		<p>
			<code>Import-Module WebDeploy</code>
		</p>
		<br />
		<h4>When it runs</h4>
		<p>The web deployment for any sites configured using this module will occur just <b>before</b> the 
		<a href="create.html#deploy_block">Deploy</a> block of your script is called for those build environments 
		to which that block applies.</p>
		<br />
		<h4>Configuring the module</h4>
		<p>Add a section named <b>WebDeploy</b> to your <a href="create.html#environment">environment configuration file</a> with a 
		YAML section below it for each deployment you wish to occur during your build. Each section you define must have the following settings:</p>
		<h5>WebComputer</h5>
		<p>string - The computer to deploy to.</p>
		<h5>WebPort</h5>
		<p>int - The HTTP/HTTPS port to create the web site on.</p>
		<h5>WebSite</h5>
		<p>string - The name of the virtual directory to create the web site within. A folder will also be created below the <i>Inetpub</i> directory on the target server with this name containing your web application's files.</p>
		<h5>WebPassword</h5>
		<p>string - A password that meets the strength requirements of the destination computer that deployment will occur on. A user will be created with the 
		same name as the <b>WebSite</b> property and this account, combined with this password, will control the ability to perform deployments.</p>
		<h5>WebURL</h5>
		<p>string - The URL, including the port, that users will use to access the site.</p>
		<h5>Package</h5>
		<p>string - The path to the web deployment zip file containing the package to deploy.</p>
		<h5>Parameters</h5>
		<p>hash - Optional. Nested YAML settings for parameters that will be passed during web deployment. See the parameters.xml file inside your web deployment zip file for possible options for your specific deployment.</p>
		<h5>BringOffline</h5>
		<p>bool - Optional. Must be true or false. If present, takes the web application <a href="http://www.iis.net/learn/publish/deploying-application-packages/taking-an-application-offline-before-publishing" target="_blank">offline</a> during publishing.</p>
		<br/>
		<h4>Example configuration</h4>
		{% highlight yaml %}WebDeploy:
  MySite:
    WebComputer: MyComputer
    WebPort: 8080
    WebSite: www.somewhere.com
    WebPassword: gh#1@42*
    WebURL: http://www.somewhere.com:8080
    Package: WebSites/MySite.zip
    BringOffline: true
    Parameters:
      DatabaseName: MyDatabase
      SomeOtherParameter: SomeValue{% endhighlight %}
	</div>
</div>