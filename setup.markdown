---
layout: page
---
<div class="row-fluid">
	<div class="span3">
		<h5>Article contents</h5>
		<ul class="nav nav-list">
			<li class="nav-header">
				<a href="#tfs_setup">Setting up Team Foundation Server</a>
			</li>
			<li class="nav-header">
				<a href="#environment_use">How powerdelivery uses your environments</a>
			</li>
			<li>
				<a href="#environment_development">Development</a>
			</li>
			<li>
				<a href="#environment_test">Test</a>
			</li>
			<li>
				<a href="#environment_production">Production</a>
			</li>
			<li>
				<a href="#environment_capacity_test">Capacity test</a>
			</li>
			<li class="nav-header">
				<a href="#enabling_deployment">Enabling deployment to an environment node</a>
			</li>
		</ul>
	</div>
	<div class="span9">
		
		<h1>Setting up your infrastructure</h1>
		<p>To use powerdelivery, you will need at least 3 separate environments to run 
		your software or features in. These can be on the same computer or separate computers 
		(or virtual machines) and will depend on your unique deployment requirements.</p>

		<p>Most teams create software and test it out on their own computers. When a team member has 
		tested changes ready to submit, they "check-in" these changes and a server process 
		picks these up and kicks off a build. This is known as <b>continuous integration</b>. </p>

		<a name="tfs_setup"><hr></a>
		<br />
		<h2>Setting up Team Foundation Server</h2>

		<p>The software product for your team that performs this continuous integration is 
		Microsoft Team Foundation Server (TFS). Before you can use TFS with powerdelivery, 
		you need to gather information about your build environment.</p>
		
		<ol>
			<li><h5>Install Team Build service</h5></li>
			<p>For you to use the automated build features of TFS, you must have installed the 
			<b>Team Build service</b>. If you haven't done this already, you can read about how to do it below.</p>
			<ul>
				<li><a href="http://msdn.microsoft.com/en-us/library/vstudio/ee259687(v=vs.100).aspx">Installing Team Build Service (TFS 2010)</a></li>
				<li><a href="http://msdn.microsoft.com/en-us/library/vstudio/ee259687.aspx">Installing Team Build Service (TFS 2012)</a></li>
			</ul>
			<li><h5>Gather TFS Build details</h5></li>
			<p>To continue setting up powerdelivery, you need 2 essential pieces of information that will 
			be unique to how you setup the TFS build service:</p>
			<ul>
				<li>The name of the <b>Build Agent</b> computer or VM that will run builds for your software features</li>
				<li>The name of the <b>Active Directory account you set the TFS Build Agent Service to run under</b> when you installed TFS Build service</li>
			</ul>
			<li><h5>Login to the Build Agent</h5></li>
			<p>Use <a href="https://en.wikipedia.org/wiki/Remote_desktop_software">remote desktop software</a> to login to the Build Agent computer you gathered the details of above.</p>
			<li><h5>Install PowerShell 3.0 on the Build Agent</h5></li>
			<p>Open an administrative PowerShell prompt and type the following command:</p>
			{% highlight powershell %}Get-Host{% endhighlight %}
			<p>Look for the <i>Version</i> property and make sure it returns at least <b>3.0</b> or greater. If this 
			number is lower (probably 2.0), then <a href="http://www.microsoft.com/en-us/download/details.aspx?id=34595">download and install PowerShell 3.0</a> before continuing.</p>
			<li><h5>Install Chocolatey on the Build Agent</h5></li>
			<p>Chocolatey is a package manager for Windows built on <a href="http://www.nuget.org">nuget</a>. It lets you install software on your computer 
			silently from a command prompt (or script) without needing to click through wizards. You can read a blog post 
			from Scott Hanselman about it <a href="http://www.hanselman.com/blog/IsTheWindowsUserReadyForAptget.aspx">here</a>. 
			powerdelivery is distributed through Chocolatey to make it easy to install and update.</p>
			<p>Go to the <a href="http://chocolatey.org/">Chocolatey website</a> and follow the instructions on the front 
			page for installing it via a command prompt.</p>
			<li><h5>Enable Unsigned PowerShell scripts on the Build Agent</h5></li>
			<p>I am purchasing a certificate to sign the scripts that come with powerdelivery in the near future. Until then, 
			you need to open an Administrative PowerShell console and run the following command:</p>
			{% highlight powershell %}Set-ExecutionPolicy Unrestricted{% endhighlight %}
			<li><h5>Install Powerdelivery on the Build Agent</h5></li>
			<p>From an Administrative PowerShell console, run the following command to install powerdelivery via chocolatey:</p>
			{% highlight powershell %}cinst powerdelivery{% endhighlight %}
			<p>You should <a href="http://chocolatey.org/packages/PowerDelivery">check the powerdelivery Chocolatey page for updates</a> 
			from time to time. When you find them, update your build agent from an Administrative PowerShell 
			console again with the following command:</p>
			{% highlight powershell %}cup powerdelivery{% endhighlight %}
		</ol>
		
		<p>If you followed the steps above, your TFS Build Agent is now ready for 
		you to <a href="create.html">Add powerdelivery to to a TFS project</a>. Before you do that 
		however, continue to follow the next steps to prepare the target environments 
		of your builds.</p>

		<a name="environment_use"><hr></a>
		<br />
		<h2>How powerdelivery uses your environments</h2>

		<p>This section describes the different environments your software will be propagated through 
		to eventually be delivered to your customers.</p>

		<a name="environment_development"><hr></a>
		<br />
		<h4>The Development environment</h4>
		<p>When you automate the deployment of your software features, this automation might 
		compile code, change databases, setup a router or load balancer, or maybe deploy a website. 
		The goal is to have this 
		"build" do everything needed to automate the setup of your software in a single environment. 
		This first environment is known as <b>Development</b> and is deployed to when you submit changes 
		to a source control project in TFS that you've setup with powerdelivery. powerdelivery calls 
		the build that deploys your Development environment a <b>Commit</b> 
		build. The Development environment changes all the time and because of this, it's a bad 
		place to send <abbr title="Quality Assurance">QA</abbr> people to look at the state of the 
		software that is under development.</p>

		<a name="environment_test"><hr></a>
		<br />
		<h4>The Test or User Acceptance Test (UAT) environment</h4>
		<p>When a build succeeds in the Development environment and looks ready for test, the team can 
		kickoff a <b>Test</b> build which performs identical steps as far as deployment is concerned, 
		but this time the target will be a different environment. Again, this depends on your needs and 
		could be a different computer, database, or virtual machine - or perhaps just a different one 
		on the same computer if you want to keep costs low. If using the same computer you'll need to 
		be careful you avoid naming collisions and use unique names for your websites for example.</p>
		
		<a name="environment_production"><hr></a>
		<br />
		<h4>The Production environment</h4>
		<p>Once people responsible for making sure a Test build is suitable for release have evaluated it 
		in that environment, it's ready to go to production. At this point a <b>Production</b> build is 
		kicked off and once again we perform identical deployment steps as Test but this time the target 
		is unique. This environment is the one your customers will use to access the software features.</p>
		
		<a name="environment_capacity_test"><hr></a>
		<br />
		<h4>The Capacity Test environment</h4>
		<p>Teams may also want to deploy a build to an environment where it will execute long-running tests 
		against hardware that is identical to production to evaluate the capacity of the system. This is an 
		optional build that can be kicked off using a Commit build (a build that successfully deployed to your 
		Development environment). Teams will typically use the Test environment to perform any manual review 
		of the software for functional acceptance, and the Capacity Test environment to review the performance 
		and when both are adequate, only then promote the build to production.</p>
		
		<a name="enabling_deployment"><hr></a>
		<br />
		<h2>Enabling deployment to an environment node</h2>
		
		<p>Once you have identified the physical computers or virtual machines that will host the 
		Development, Test, and Production environment for your software, you need to configure them 
		so that they will allow remote PowerShell commands to be sent to them. This is what powerdelivery 
		uses to automate deployment of your software and its environment.</p>
		<p>Powerdelivery includes a PowerShell script to run that will setup this configuration for you. 
		It is important to note that this script keeps your environment locked down tightly from a security 
		standpoint, in that it only allows remote PowerShell commands to be sent from the TFS Build Agent 
		computer you setup at the top of the page to the computer you run it on, and only from a specific 
		account.</p>
		<p>To enable build deployment on a node:</p>
		
		<ol>
			<li><h5>Login to the node</h5></li>
			<p>Use <a href="https://en.wikipedia.org/wiki/Remote_desktop_software">remote desktop software</a> to login to the computer 
			that runs the web server, database, load balancer, or other infrastructure asset that will be deployed to.</p>
			<li><h5>Install PowerShell 3.0 on the node</h5></li>
			<p>Open an administrative PowerShell prompt and type the following command:</p>
			{% highlight powershell %}Get-Host{% endhighlight %}
			<p>Look for the <i>Version</i> property and make sure it returns at least <b>3.0</b> or greater. If this 
			number is lower (probably 2.0), then <a href="http://www.microsoft.com/en-us/download/details.aspx?id=34595">download and install PowerShell 3.0</a> before continuing.</p>
			<li><h5>Enable Unsigned PowerShell scripts on the node</h5></li>
			<p>I am purchasing a certificate to sign the scripts that come with powerdelivery in the near future. Until then, 
			you need to open an Administrative PowerShell console and run the following command:</p>
			{% highlight powershell %}Set-ExecutionPolicy Unrestricted{% endhighlight %}
			<li><h5>Download the Deployment-Enabling Script</h5></li>
			<p>Open a browser and <a target="_new" href="https://raw.github.com/eavonius/powerdelivery/master/enable-buildDeployment.ps1">download the file found here</a> to the node. You may be forced to 
			save it as a .txt file and have to rename it to a .ps1 file afterwards.</p>
			<li><h5>Run the Deployment-Enabling Script</h5></li>
			<p>Open a PowerShell Administrative prompt and change directory into wherever you downloaded the file. 
			For example if your username on the node is "myprofile" and you downloaded it to the Downloads folder:</p>
			{% highlight powershell %}Set-Location "C:\Users\myprofile\Downloads"{% endhighlight %}
			<p>Run the following command:</p>
			{% highlight powershell %}.\enable-buildDeployment.ps1{% endhighlight %}
			<p>You will be prompted for 3 pieces of information:</p>
			<ul>
				<li><b>buildAgentComputer</b></li>
				<p>This is the name of the computer running the TFS Build Agent service you setup at the 
				top of the page.</p>
				<li><b>buildUserName</b></li>
				<p>This is the username (without the domain prefix) of the Active Directory account that 
				the TFS Build Agent is set to run under. You can use the <i>Services</i> control panel applet on 
				the computer running your TFS Build Agent to look for <b>Visual Studio Team Foundation Build Service Host</b>. 
				Look at the username listed on the <i>Log On</i> tab of the dialog that appears when you click that service.</p>
				<li><b>buildUserDomain</b></li>
				<p>This is the domain name of the account that the TFS Build Agent is set to run under.</p>
			</ul>
			<p>You can optionally call the script by passing all three parameters to skip the prompts. An example might be:</p>
			{% highlight powershell %}.\enableBuildDeployment.ps1 -buildAgentComputer MYAGENT -buildUserName MYACCOUNT -buildUserDomain MYDOMAIN{% endhighlight %}
		</ol>
		<p>If you've followed the steps above, the node should be enabled for deployment to from the TFS Build Agent 
		for continuous delivery. You may want to double-check that the TFS Build Agent account you specified in the 
		last step is now a member of the <b>Administrators</b> group on that node using the <i>Local Users and Groups</i> 
		control panel applet.</p>
		<hr />
	
		Next you should read about how to <a href="create.html">create powerdelivery builds</a>.
		
	</div>
</div>