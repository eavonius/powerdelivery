powerdelivery
=============

Microsoft Team Foundation Server build template and Windows PowerShell framework for Continuous Delivery.

[Read the wiki](https://github.com/eavonius/powerdelivery/wiki)

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