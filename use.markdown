---
layout: page
---
<div class="row-fluid">
	<div class="span3 hidden-tablet">
		<ul class="nav nav-list">
			<h5>Article contents</h5>
			<li class="nav-header">
				<a href="#continuous_delivery_sprints">Sprints with Continuous Delivery</a>
			</li>
			<li>
				<a href="#seed_the_backlog">Seed the backlog</a>
			</li>
			<li>
				<a href="#prioritize">Prioritize</a>
			</li>
			<li>
				<a href="#plan">Plan</a>
			</li>
			<li>
				<a href="#execute">Execute</a>
			</li>
			<li>
				<a href="#review">Review</a>
			</li>
			<li>
				<a href="#retrospective">Retrospective</a>
			</li>
			<li class="nav-header">
				<a href="#environment_use">How builds promote through environments</a>
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
				<a href="#using_builds">Using builds</a>
			</li>
			<li>
				<a href="#queueing_builds">Queueing builds</a>
			</li>
			<li>
				<a href="#build_summary">The build summary</a>
			</li>
			<li>
				<a href="#build_log">The build log</a>
			</li>
			<li class="nav-header">
				<a href="#controlling_builds">Controlling who can build</a>
			</li>
		</ul>
	</div>
	<div class="span9 span12-tablet">
		<h1>Using powerdelivery on your team</h1>
		<p>Before diving into all of its features, become familiar with the information in this article 
		to understand how to use powerdelivery in the context of 
		your team or organization's delivery (release) process. While there will be specific things you'll 
		have to accommodate due to customer or regulatory needs, if you understand the spirit with which 
		powerdelivery was designed to help you narrow in on customer value and deliver faster, you'll 
		aim yourself towards the joyful path of continued success as you establish a rhythm of quality releases.</p>
		
		<a name="continuous_delivery_sprints"><hr></a>
		<br/>
		<h2>Sprints with Continuous Delivery</h2>
		<p>On most teams that follow Agile/<a href="http://www.scrum.org" target="_blank">SCRUM</a> development methodologies, several sprints worth of functionality is built before it is actually released into 
		<a href="#environment_production">Production</a>. Rather than waiting until you are about to release a complete 
		vision of everything you think users want in terms of features, 
		codify the process you'll use to release your software using powerdelivery 
		as a primary output of your team's first sprint. This puts you in the position to release small 
		increments of your ideas and adjust as you get feedback.</p>
		<p>If you are going to do regular two week releases of your software (and eventually move 
		to daily or intra-daily releases) the release process must cease to be an <i>event</i> which 
		requires signoffs, drama, stress, and overtime. Instead it must become repeatable, confident, 
		and <b>fast</b>.</p>
		
		<a name="seed_the_backlog"><hr></a>
		<br/>
		<h3>Seeding the backlog</h3>
		<p>Before you start using powerdelivery, get with your customers and find out what 
		their needs are. Capture these needs as <b>user stories</b>. You can use Microsoft 
		Team Foundation Server, an Excel spreadsheet, or whatever you desire to keep track of 
		these stories. This list you will use to keep track of the stories is known as a <b>backlog</b>. 
		If you've already got a backlog, make sure it is at the appropriate level of detail for 
		Continuous Delivery.</p>
		<p>The goal of user stories is to describe just enough about a desired <b>capability</b> 
		for a given <b>role</b> that provides some <b>business value</b> that it can be prioritized by the 
		IT organization. A user story's goal is NOT to describe the requirements or acceptance criteria for 
		an idea or need from the customer. This happens later during <a href="#plan">sprint planning</a>. User stories are usually written in the following format:</p>
		<p class="lead">As a <b>role</b> I need <b>capability</b> so I can <b>some business value</b>.</p>
		<p>If you attempt to take the content in a traditional requirements document and represent it as 
		detailed user stories, you will fail to recognize the agility that comes from following SCRUM. Rather, 
		tell stories at a level of detail that allows the development team to offer a <b>relative cost estimate</b> 
		suitable for prioritization but without locking the design into specifics yet. You want to about how many 
		degrees of magnitude in difficulty an idea would be to implement without knowing all the specifics. This is just to help
		the business a feel for whether their choice of making an idea a higher priority might cost more or less than another idea under consideration.</p>
		<p>If you can't resist the temptation to get more detailed at this stage, your are resisting the 
		ability for users to influence your product's design, and you might as well just do <a href="https://en.wikipedia.org/wiki/Waterfall_model" target="_blank">Waterfall.</a> 
		As you do more releases, 
		you will break these ideas, known as <b>epic user stories</b> into smaller stories that can 
		be estimated and completed in one release.</p>
		
		<a name="prioritize"><hr></a>
		<br/>
		<h3>Prioritizing the backlog</h3>
		<p>Prior to starting a sprint following SCRUM, prioritize the user stories from top to bottom with the topmost 
		ones being of the most importance to the business. These will be worked on first. Again, do not go to 
		the trouble of coming up with acceptance criteria and detailed requirements for any of the user 
		stories prior to the <a href="#plan">sprint planning meeting</a> as this simply wastes time and assumes that 
		the design of the product will match your original vision, and you will get it all done in one sprint. 
		The whole reason to do SCRUM is to get 
		feedback and continually refactor the design to arrive at a product that best meets the needs of 
		our users. This will not match our vision since we learn about what the user needs every time we 
		release to them and get feedback.</p>
		<h3>Example backlog</h3>
		<p>Below is an example of what might be in your backlog prior to starting the first sprint. Our 
		ficticious project will be to produce a product that customers use to purchase bikes:</p>
		<table class="table">
			<thead>
				<tr>
					<th>Rank</th>
					<th>Story</th>
					<th>Relative cost estimate</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>1</td>
					<td>As a <i>developer</i> I need to <i>checkin code changes</i> so that <b>an automated build compiles the code</b>.</td>
					<td>4 hrs</td>
				</tr>
				<tr>
					<td>2</td>
					<td>As an <i>operations engineer</i> I need to <i>checkin deployment scripts</i> so that <b>the environment is configured properly to support running the software</b>.</td>
					<td>4 hrs</td>
				</tr>
				<tr>
					<td>3</td>
					<td>As a <i>development team member</i> I need <i>access to a development, test, and production website</i> so that <b>I can use the product</b>.</td>
					<td>16 hrs</td>
				</tr>
				<tr>
					<td>4</td>
					<td>As a <i>quality assurance engineer</i> I need to <i>checkin automated acceptance tests</i> so <b>I can automatically verify that the features the team has built meet the acceptance criteria</b>.</td>
					<td>16 hrs</td>
				</tr>
				<tr>
					<td>5</td>
					<td>As a <i>customer</i> I need to <i>browse available bicycles</i> so <b>I can select a bicycle to view the details of</b>.</td>
					<td>16 hrs</td>
				</tr>
				<tr>
					<td>6</td>
					<td>As a <i>customer</i> I need to <i>view the details of a bicycle</i> so <b>I can decide if I would like to buy one</b>.</td>
					<td>24 hrs</td>
				</tr>
				<tr>
					<td>7</td>
					<td>As a <i>customer</i> I need to <i>add a bicycle to my shopping cart</i> so <b>I can place an order for a bicycle</b>.</td>
					<td>24 hrs</td>
				</tr>
				<tr>
					<td>8</td>
					<td>As a <i>customer</i> I need to <i>provide my billing details</i> so <b>I can place an order for the items in my cart</b>.</td>
					<td>16 hrs</td>
				</tr>
				<tr>
					<td>9</td>
					<td>As a <i>customer</i> I need to <i>place an order</i> so <b>I can know whether my billing details were valid and the order was placed successfully</b>.</td>
					<td>24 hrs</td>
				</tr>
				<tr>
					<td>10</td>
					<td>As a <i>customer</i> I need to <i>check the status of an existing order</i> so <b>I can know whether it has shipped</b>.</td>
					<td>8 hrs</td>
				</tr>
				<tr>
					<td>11</td>
					<td>As a <i>customer</i> I need to <i>create an account</i> so <b>I can place orders without having to provide my billing details again</b>.</td>
					<td>32 hrs</td>
				</tr>
				<tr>
					<td>12</td>
					<td>As a <i>customer</i> I need to <i>login to my account</i> so <b>I can get access to my existing orders</b>.</td>
					<td>8 hrs</td>
				</tr>		
			</tbody>
		</table>
		<p>Notice that the highest priority items (rank 1-4) are related to setting up the <b>delivery environment</b>. If you use powerdelivery, 
		you can quickly deliver these features with appropriate quality gates in place to keep the software you build over future sprints 
		releasing smoothly, and with high quality.</p>
		<p>You will use the <a href="reference.html#invoke_msbuild_cmdlet">Invoke-MSBuild</a> cmdlet to compile Visual Studio projects 
		(or run other compilers) to finish the first backlog idea. You will configure your environment computers as described in the 
		<a href="setup.html#enabling_deployment">enabling deployment</a> topic to satisfy the second backlog idea. For the third backlog idea, 
		you might use the <a href="reference.html#webdeploy_module">WebDeploy</a> module. Lastly, to implement the fourth backlog idea, 
		you might use the <a href="reference.html#invoke_mstest_cmdlet">Invoke-MSTest</a> cmdlet to run unit and/or acceptance tests.</p>
		<p>These are just example powerdelivery activities and will depend 
		on your project. Should you be deliverying a Business Intelligence solution or a class library, the deployment tasks will be different. 
		Either way, concentrate on getting everything setup for a minimal automated deployment, with testing, to all of your environments as a first priority.</p>
		
		<a name="plan"><hr></a>
		<br/>
		<h3>Planning the sprint</h3>
		<p>Get the customer, a person who controls the production operations environment, a developer, and a QA engineer together and hold the 
		<b>sprint planning meeting</b>.</p>
		<ol>
			<li>Take each user story off the backlog and discuss it until you arrive at <a href="#acceptance_criteria">acceptance criteria</a>. Acceptance criteria is a set of steps that 
			describes how the development team will demonstrate that the story is complete at the end of the sprint. It's also the blueprint for your 
			automated acceptance tests, and any manual testing that might be done if you have no technology available to automatically verify it.</li>
			<br>
			<li>Have a developer estimate the effort to create the software feature and any accompanying unit tests.</li>
			<br>
			<li>Have a QA or user acceptance resource estimate the 
			effort to create automated tests and run them to consider the feature complete.</li>
			<br>
			<li>Have the operations or development resource who will write PowerShell code in powerdelivery to support deployment 
			of the new features estimate that effort.</li>
			<br>
			<li>Combine the above estimates and determine whether that effort can be completed within the time available in the sprint. If it is 
			too large, break up the existing user story into smaller stories that complete that work in stages. This will require you to update 
			the backlog with the updated user stories and their priority.</li>
			<br>
			<li>Repeat step #1 until the team has enough work allocated to take up their capacity in the sprint. At this point sprint planning is complete and 
			the team can begin to work on implementing the release.</li>
		</ol>
		<p><b>IMPORTANT</b>: Regardless of whether you must do some manual testing or it is fully automated, teams should not wait to complete user acceptance 
		testing	until after the <a href="#review">sprint review</a>. Instead, functional deliverables, acceptance tests, and any deployment scripting all must be completed for a story 
		to be considered <a href="#done">done</a> when doing <a href="http://www.continuousdelivery.com">Continuous Delivery</a>. If this isn't the case, 
		you lose the ability to release your software changes upon completion of the sprint.</p>
		<p>This situation leads to the team psychologically relaxing their standard for what constitutes being <a href="#done">done</a> before the end of 
		a sprint, since it potentially won't be released anyway. It is far more important that the team learns when they have underestimated and can resolve this 
		as an opportunity for improvement in the <a href="#retrospective">retrospective</a> than hiding the truth.</p>
		<a name="acceptance_criteria"><hr></a>
		<br />
		<h4>Acceptance criteria example</h4>
		<ol>
			<li>Open the browser to the website</li>
			<li>Login as MYDOMAIN\charles</li>
			<li>The list of products should appear.</li>
			<li>The product list must contain "Bike 1", "Bike 2", and "Bike 3"</li>
		</ol>
		<p>Note that in the example above, there may be data needed in your environment to support the tests. It is important to write your 
		acceptance criteria this way so there is no vague definition of whether the requirements were met. Once you have enough code working that 
		you can demonstrate this feature, and an accompanying automated acceptance test, and your delivery environment can deploy it so that 
		someone can use it, you are done!</p>
		<h5>Alternate paths and feature hiding</h5>
		<p>In more traditional requirements approaches with fixed designs, an attempt would be taken to exhaustively document all possible 
		outcomes for a feature (for instance business rules and validation logic) using a <b>use case</b>. Use cases are great for business 
		analysts to read because they include a complete picture of a feature. But they are a detriment to the emergent product design and 
		agility Continuous Delivery and SCRUM enable. Instead, describe just what you know and can deliver in a sprint in acceptance criteria. 
		You can choose to hide that feature when it is not ready for customer in production until it's ready. See the concept of 
		<b>feature hiding</b> in Jez Humble's book on Continuous Delivery.</p>
		<p>The team comes up with additional 
		user stories that describe acceptance criteria that deliver additional aspects and outcomes of a feature in future sprints, as the project 
		progresses. Following this simple principle will be difficult, but it frees team members from the emotional attachment that comes from 
		detailed planning of an entire feature before users have had a chance to inspect it and provide feedback. This results in team members being 
		more likely to plan for immediate changes to the design to meet customer's needs.</p>
		
		<a name="execution"><hr></a>
		<br/>
		<h3>Executing the sprint</h3>
		<p>As developers submit code changes, they may be using <a href="https://en.wikipedia.org/wiki/Test-driven_development" target="_blank">test-driven development</a> 
		or writing tests afterwards; or there may be separate QA 
		personnel available to help write acceptance tests. Either way, the team works together to build unit tests as needed to exercise the individual 
		components they build work independently. These unit tests run in the <a href="#environment_development">Development</a> environment. 
		When an entire feature for which acceptance criteria was established is ready for QA personnel to inspect completeness, a build is 
		promoted to the <a href="#environment_test">Test</a> environment. 
		There it is acceptance tested, either manually or through automated tests. When a build has been deemed complete enough of and of suitable 
		quality to release, it is ready for the <a href="#review">sprint review</a>.</p>
		
		<a name="done"><hr></a>
		<br>
		<h4>The importance of being "done"</h4>
		<p>Powerdelivery can make it easier to release software, but if teams fail to use acceptance criteria to establish a contract on 
		exactly what they are going to deliver over the sprint, the product will eventually have many untested and incomplete paths due to 
		a misrepresentation of completeness. The only way to avoid this is for teams to commit to writing 
		automated acceptance tests you meet the definition of done referred to in <a href="http://www.continuousdelivery.com" target="_blank">Continuous Delivery</a>. 
		That definition is that that <b>a completed feature is in production and has passing acceptance tests for all its acceptance criteria</b>.</p>
		
		<a name="review"><hr></a>
		<br/>
		<h3>Reviewing the sprint</h3>
		<p>Get the same people together that met during the <a href="#plan">sprint planning</a> meeting and review the deliverables of the sprint. 
		The goal is to show what was completed and get feedback from the customer. This feedback will be considered as both additional backlog ideas 
		for new functionality, or changes.</p>
		<p>If the time is coming close to the scheduled sprint review meeting and the team is behind, it is important to reschedule the sprint 
		review meeting, or to push incomplete features to the backlog. Either way, <b>keep anything unfinished hidden or still in a releaseable state</b> 
		to enable to business to decide if they want to release to customers. It is perfectly normal for teams new to Continuous Delivery to be off 
		in their estimation during the first few sprints until they learn what the true velocity of how much work they can get done in two weeks looks like 
		now that testing and deployment are requirements to be considered done.</p>
		<p>At the end of the sprint review meeting, if the business decides they would like to release, promote the build that was demonstrated in 
		the <a href="#environment_test">Test</a> environment to <a href="#environment_production">Production</a> using powerdelivery.</p>
		
		<a name="retrospective"><hr></a>
		<br/>
		<h3>The sprint retrospective</h3>
		<p>Get the same people together that met for the <a href="#review">sprint review</a>, excluding the customer, and discuss how the sprint went. 
		Record a list of what went well, and what didn't. Make an action list for things to improve in the next sprint. This step should never be 
		excluded as it is where honesty exposes the truth about your process and allows for continuous improvement.</p>
		
		<a name="environment_use"><hr></a>
		<br />
		<h2>How builds promote through environments</h2>
		<p>This section describes how the software features your team builds will be escalated through 
		various environments for inspection and eventually delivered to your customers by powerdelivery.</p>

		<a name="environment_development"><hr></a>
		<br />
		<h4>The Development environment</h4>
		<p>During sprints, the team needs a place where they may evaluate the software 
		features they're building as though they were released using the latest code 
		checked into their TFS source control project. But this place needs to be in isolation 
		of the live, running, production copy of software that your customers see.</p>
		<p>During the first sprint, the team will 
		<a href="create.html#add_pipeline">setup a source control project to use powerdelivery</a>. 
		Powerdelivery can 
		compile code, change databases, setup a router or load balancer, 
		deploy a website, or whatever else is necessary to get this isolated environment running. 
		This environment is where the software's quality should be verified by automated unit tests.</p>
		<p>This first environment where your software assets will be deployed is known as <b>Development</b>. 
		The Development environment is re-deployed to every time someone submits changes to TFS source control, 
		and so changes frequently. 
		Due to this fact, it is a bad place to send <abbr title="Quality Assurance">QA</abbr> people to spend any time evaluating 
		whether a build is suitable for release while development of that build's features are still ongoing.</p>
		<p>When anyone on your team checks-in changes to the TFS source control project, 
		powerdelivery automatically <a href="#queueing_builds">queues a Commit</a> build on your Team Foundation Server, 
		and calls your PowerShell script. This script does everything needed to 
		put the software assets into the state they need to be in to use them. It also runs 
		automated unit tests to determine whether it is sufficient for promotion to the 
		<a href="#environment_test">Test</a> environment.</p>

		<a name="environment_test"><hr></a>
		<br />
		<h4>The Test or User Acceptance Test (UAT) environment</h4>
		<p>When any Commit build has succeeds in deploying to the Development and is passing any unit tests created, 
		a team member can <a href="#queuing_builds">queue a Test build</a> and specify a specific build to promote 
		into an environment to be used for user acceptance testing. Powerdelievery runs the same deployment process 
		that version of the Commit build used to deploy the software features, but targeting a different environment.</p>
		<p>How you will separate these environments depends on your needs and 
		could be a different computer, database, or virtual machine - or perhaps just running multiple copies of your 
		software on the same computer using naming conventions to avoid collision if you want to keep costs low. 
		If using the same computer (or a virtual machine node) you'll need to be careful you avoid naming collisions 
		and use unique names for your websites for example.</p>
		
		<a name="environment_production"><hr></a>
		<br />
		<h4>The Production environment</h4>
		<p>Once those folks on your team that are responsible for making sure a Test build is suitable for release have evaluated it, 
		they can <a href="#queuing_builds">queue a Production build</a> and specify a specific build to promote from 
		the Test environment into the one that that your customers use to access the software's features. 
		Your team can wait until the <a href="#review">sprint review</a> to do this, or if you've got 
		things down, at any time when you are confident the changes in that build are tested well enough to release.</p>
		
		<a name="environment_capacity_test"><hr></a>
		<br />
		<h4>The Capacity Test environment</h4>
		<p>Teams may also want to deploy a build into an environment where it will execute long-running tests 
		against hardware that is identical to production to evaluate the capacity of the system. This is an 
		optional step in using powerdelivery but can be done by <a href="#queueing_builds">queueing a CapacityTest build</a>.
		Your QA personnel should then evaluate the build in both the CapacityTest (for performance/capacity testing) and 
		Test (for functional testing) environments to verify that both functional acceptance, and performance requirements are met. 
		Only when both conditions are met will they promote the build into Production.</p>
		
		<a name="using_builds"><hr></a>
		<br/>
		<h2>Using builds of your software features</h2>
		<p>As you <a href="create.html">create your automated deployment pipeline</a> for the software you are delivering, 
		you will need to use Microsoft Team Foundation Server to promote builds through your environments.</p>
		
		<a name="queueing_builds"><hr></a>
		<br/>
		<h3>Queueing powerdelivery builds</h3>
		<p>The process for queueing a build depends on the environment being targeted.</p>
		
		<a name="commit_build"><hr></a>
		<br/>
		<h4>Commit builds</h4>
		<p>Builds that target your <a href="#environment_development">Development</a> environment are automatically 
		queued whenever anyone on your team checks in code.</p>

		<a name="test_build"><hr></a>
		<br/>
		<h4>Test builds</h4>
		<p>To queue a build that targets your <a href="#environment_test">Test</a> environment, follow this procedure. Powerdelivery works with 
		Visual Studio 2010, but these instructions are for Visual Studio 2012.</p>
		<ol>
			<li>Open the <b>Team Explorer</b> panel in Visual Studio.</li>
			<br>
			<li>Right-click the build named after the <a href="create.html">deployment pipeline</a> you want to 
			queue in TFS that ends with the word "Test".</li>
			<br>
			<li>Select <b>Queue New Build...</b> from the context menu that appears.</li>
			<p>
				<br>
				<img src="img/queue_build.gif" />
				<p>
					<small>Figure: Queuing a build in Visual Studio 2012</small>
				</p>
			</p>
			<li>Select the <i>Parameters</i> tab from the dialog that appears and enter the build number of a 
			successful Development build in the <b>Build to Promote</b> field. See the <a href="#build_summary">build summary</a> topic to find 
			out where to obtain the build number. If you try to use a failed build or forget to provide this value, 
			the Test build will fail.</li>
			<p>
				<br>
				<img src="img/promote_build.gif" />
				<p>
					<small>Figure: Specifying the build to promote in Visual Studio 2012</small>
				</p>
			</p>
			<li>Click the <b>Queue</b> button.</li>
		</ol>
		
		<a name="production_build"><hr></a>
		<br/>
		<h4>Production build</h4>
		<p>To queue a build that targets your <a href="#environment_production">Production</a> environment, follow the same procedure as for a <a href="#test_build">Test build</a> but 
		specify the build number of a successful Test build in the <b>Build to promote</b> field, and queue the build that ends with the word "Production".</p>
		
		<a name="capacity_test_build"><hr></a>
		<br/>
		<h4>Capacity test build</h4>
		<p>To queue a build that targets your <a href="#environment_capacity_test">Capacity test</a> environment, follow the same procedure as for a <a href="#test_build">Test build</a> 
		but queue the build that ends with the word "Capacity Test".</p>
		
		<a name="build_summary"><hr></a>
		<br/>
		<h3>The summary of a powerdelivery build</h3>
		<p>Microsoft Team Foundation Server includes a <a href="http://msdn.microsoft.com/en-us/library/ms181733.aspx" target="_blank">summary page</a> 
		useful for reviewing the results of a 
		build. Powerdelivery extends the summary page with additional information and can also be 
		used to surface summary information custom to your deployment.</p>
		<img src="img/build_summary_detail.gif" style="width: 100%; max-width: 757px" />
		<p>
			<br/>
			<small>Figure: The build summary of a Commit build in Visual Studio 2012</small>
		</p>
		<br />
		<p>The summary page displays the following standard sections:</p>
		
		<h5>Release</h5>
		<p>Displays the version, environment, and build number. The build number is the value provided in the 
		<b>Build to Promote</b> field of the <i>Parameters</i> tab when promoting a build from one environment 
		to another.</p>
		
		<h5>Environment</h5>
		<p>Displays the values loaded from the <a href="create.html#environment">environment configuration</a> 
		file for the target environment of the build. Any values with the word "password" in them will be masked.</p>
		
		<h5>Delivery Modules</h5>
		<p>Displays the name and version of any <a href="create.html#modules">delivery modules</a> 
		loaded by the build.</p>
		
		<h5>Compilations</h5>
		<p>Displays any MSBuild projects compiled using the <a href="reference.html#invoke_msbuild_cmdlet">Invoke-MSBuild</a> 
		cmdlet or <a href="reference.html#msbuild_module">MSBuild</a> delivery module.</p>
		
		<h5>Published Assets</h5>
		<p>Displays any files published to the drop location of the build using the <a href="reference.html#publish_buildassets_cmdlet">Publish-BuildAssets</a> 
		cmdlet.</p>
		
		<h5>Unit Tests</h5>
		<p>Displays any unit tests run using the <a href="reference.html#invoke_mstest_cmdlet">Invoke-MSTest</a> 
		cmdlet or the <a href="reference.html#mstest_module">MSTest</a> module.</p>
		
		<h5>Acceptance Tests</h5>
		<p>Displays any acceptance tests run using the <a href="reference.html#invoke_mstest_cmdlet">Invoke-MSTest</a> 
		cmdlet or the <a href="reference.html#mstest_module">MSTest</a> module.</p>
		
		<h5>Deployments</h5>
		<p>Displays any databases deployed using the <a href="reference.html#invoke_roundhouse_cmdlet">Invoke-Roundhouse</a> 
		cmdlet or the <a href="reference.html#roundhouse_module">Roundhouse</a> module, the <a href="reference.html#webdeploy_module">WebDeploy</a> module, 
		or any other deployments that use this section name.</p>
		
		<p>You can add your own entries to any of the above sections, or create your own, using the <a href="reference.html#write_buildsummarymessage_cmdlet">Write-BuildSummaryMessage</a> 
		cmdlet.</p>
		
		<a name="build_log"><hr></a>
		<br/>
		<h3>Reviewing the log of a powerdelivery build</h3>
		<p>From the <a href="#build_summary">summary</a> page, click the <b>View Log</b> link to view the Team Foundation Server 
		build log. The log displays detailed information about the output of powerdelivery and any Windows PowerShell commands you run. 
		Any statements you write to the console using Windows PowerShell in your script will automatically be displayed in the log. 
		When you encounter failed builds, the first place to go should be the build log to view more details about what went wrong, and 
		look at what other operations may have run successfully prior to the failure to help you diagnose the breakage.</p>
		
		<a name="controlling_builds"><hr></a>
		<br/>
		<h3>Controlling who can build</h3>
		<p>When you <a href="create.html#add_pipeline">add powerdelivery to a TFS project</a>, three security groups are added to 
		your TFS server named after your deployment pipeline and suffixed with a build environment. Since <a href="#development_build">Development</a> 
		builds are triggered whenever anyone commits code, users only need to have permission to checkin code to source control 
		to gain the ability to trigger those builds.</p>
		<p>To trigger builds in other environments, the following procedure must be used to give permissions to users to do so:</p>
		<ol>
			<li>Open the <b>Team Explorer</b> panel in Visual Studio.</li>
			<br/>
			<li>Navigate to the <b>Settings</b> page of the Team Explorer panel.</li>
			<br/>
			<li>Click the <b>Group Membership</b> link under the <i>Team Project</i> you wish to modify security settings for.</li>
			<br/>
			<img src="img/team_project_group_membership.gif" />
			<p>
				<br/>
				<small>Figure: The settings panel of Team Explorer in Visual Studio 2012</small>
			</p>
			<li>The security page of the <b>Team Foundation Server Portal</b> website will appear in your web browser (if Visual Studio 2012) 
			or a dialog will appear (if Visual Studio 2010). Select the group named with the following pattern:</li>
			<p>
				<br/>
				<code>[Pipeline] [Environment] Builders</code>
			</p>
			<br/>			
			<p>Where <b>Pipeline</b> is the name of your build script and <b>Environment</b> is the build environment to allow 
			queueing of builds for.</p>
			<br/>
			<img src="img/team_project_security_page.gif" />
			<p>
				<br/>
				<small>Figure: The security page of the Team Foundation Server Portal in a web browser</small>
			</p>
			<li>Modify the list of users and groups to control who can queue builds into that environment.</li>
		</ol>
		
	</div>
</div>