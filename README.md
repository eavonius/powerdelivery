powerdelivery
=============

Microsoft Team Foundation Server build template and Windows PowerShell framework for Continuous Delivery.

[Read the wiki](https://github.com/eavonius/powerdelivery/wiki)

How do I get started?
---------------------

1. Add the BuildProcessTemplates and PowerShellModules directories included in PowerDelivery to the root of any TFS source repository you want to enable for Continuous Delivery.
2. Download a copy of the PSake PowerShell extension from https://github.com/psake/psake and place it in a PSake subfolder of the PowerShellModules directory.
3. Open a PowerShell console window on the TFS build server, any TFS build agents, and your local computer and execute the following command:
````````````````````````````````
Set ExecutionPolicy RemoteSigned
````````````````````````````````
4. Add the included .csv files to the root of your PowerDelivery-enabled TFS source control repository for any environments you want your build to support. It is highly recommended to at least have a separate local, commit, user acceptance testing (UAT) and production environment.
5. Add the included Build.ps1 file to the root of your PowerDelivery-enabled TFS source control repository.
6. Create a new build in TFS for your project named "Commit". When selecting a build template, create a new one based off the PowerDelivery.xaml and name it CommitTemplate.xaml.
7. Configure the build properties for your new Commit build by pointing the "PowerShellScriptPath" property to Build.ps1 and setting the "Environment" property to "Commit".
8. Create a new SQL server database and give full access to it to the account your TFS build will run under. See your administrator or whoever setup TFS if you need to figure this out.
9. Configure the "PipelineDBConnectionString" property in your Commit build by providing the connection string to the database you just created. 
10. Repeat steps 6 through 9 above for the other environments, reusing the same SQL pipeline database (only create the database once, set the property though for each build).

You now have everything you need to start authoring your Continous Delivery builds.

How does it work?
-----------------

When you run a build using PowerDelivery, your Build script in turn calls the included PowerDelivery script and first 
figures out whether the build is running on your local computer or the server by inspecting the "onServer" argument 
to the script. **You should never set this property when running a build on your own computer.** 

Next, the build looks for a .csv file named after the environment you set using the TFS build properties, or in the case 
where you are running off of your local computer, the "Environment" argument to the script. If no argument is provided, 
this defaults to "Local". All the name/value pairs in the CSV file are loaded and then made available to your script.

Next, depending on the environment the build is targeting, a sequence of functions in your build script are called that 
you will write PowerShell statements in to do the automation. The matrix below shows the order of these functions and 
which are called in each environment.

<table>
  <tr>
    <th>Function</th><th>Local</th><th>Commit</th><th>UAT</th><th>LoadTesting</th><th>Production</th>
  </tr>
  <tr>
    <td>Compile</td><td>Yes</td><td>Yes</td><td>No</td><td>No</td><td>No</td>
  </tr>
  <tr>
    <td>SetupEnvironment</td><td>Yes</td><td>Yes</td><td>Yes</td><td>Yes</td><td>Yes</td>
  </tr>
  <tr>
    <td>TestEnvironment</td><td>Yes</td><td>Yes</td><td>Yes</td><td>Yes</td><td>Yes</td>
  </tr>
  <tr>
    <td>Deploy</td><td>Yes</td><td>Yes</td><td>Yes</td><td>Yes</td><td>Yes</td>
  </tr>
  <tr>
    <td>TestUnits</td><td>Yes</td><td>Yes</td><td>No</td><td>No</td><td>No</td>
  </tr>
  <tr>
    <td>TestAcceptance</td><td>Yes</td><td>Yes</td><td>No</td><td>No</td><td>No</td>
  </tr>
  <tr>
    <td>TestCapacity</td><td>No</td><td>No</td><td>No</td><td>Yes</td><td>No</td>
  </tr>
</table>

At the end of a successful build on the server (any build other than Local) a row is written to the PipelineDatabase to 
keep track of what the current TFS build changeset is deployed to that environment. The inclued SQL Reporting Services 
report can be used to view which changesets are currently in each environment and can be easily added to the homepage 
of your TFS project portal.

Running Builds Locally
----------------------

On your local computer, open a PowerShell prompt, change directory to wherever your local copy of Build.ps1 is for 
the project using PowerDelivery, and use the command syntax below to run your build.

```````````````````````````````````````````
.\Build.ps1 -environment <Environment Name>
```````````````````````````````````````````

You can omit the environment parameter to perform a local build, and also target builds to any of the other environments 
as well. Note that if you run builds targeting an environment other than local on your own computer, a record will not 
be written to the Pipeline Database so use this for debugging and initial authoring purposes only.

Running Builds on the Server
----------------------------

Set your "Commit" build to automatically trigger when there is a checkin. All other builds should be set to manually 
trigger. Keep in mind that a UAT build will not re-compile your source and will use the last known good Commit build 
as input. Additionally, you cannot queue a Production build until a UAT build has been marked as a candidate for Production. 
See [Certifying a UAT build] for more information.

Writing Builds
--------------