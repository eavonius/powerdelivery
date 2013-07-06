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
		<a name="invoke_msbuild_cmdlet"><hr></a>
		<h3>Invoke-MSBuild</h3>
		<p>The Invoke-MSBuild cmdlet is used to compile a MSBuild-compatible project or solution. 
		You should always use this cmdlet instead of a direct call to msbuild.exe or existing 
		cmdlets you may have found online when working with powerdelivery.</p>
		<p>This cmdlet provides the following essential continuous delivery features:</p>
		<ol>
			<li>Updates the version of any AssemblyInfo.cs (or AssemblyInfo.vb) files with the current build version. This causes all of your binaries to have the build number. For example, if your build pipeline's version in the script is set to 1.0.2 and this is a build against changeset C234, the version of your assemblies will be set to 1.0.2.234.</li>
			<li>Automatically targets a build configuration matching the environment name ("Commit", "Test", or "Production"). Create build configurations named "Commit", "Test", and "Production" with appropriate settings in your projects for this to work. If you don't want this, you'll have to explicitly pass the configuration as a parameter.</li>
			<li>Reports the status of the compilation back to TFS to be viewed in the build summary. This is important because it allows tests run using mstest.exe to have their run results associated with the compiled assets created using this cmdlet.</li>
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
