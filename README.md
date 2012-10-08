powerdelivery
=============

Microsoft Team Foundation Server build template and Windows PowerShell framework for Continuous Delivery.

What is it?
-----------

Continuous Delivery is a set of practices to reduce the time it takes to go from an idea to getting it into users' hands. 
Get the book from Jez Humble at http://continuousdelivery.com/. To implement Continuous Delivery requires following 
the practices outlined in the book and adopting them to your technology stack of choice. To do it property requires a 
sophisticated set of automated builds.

This project provides several assets that make it easy to start doing Continous Delivery now using Microsoft Team 
Foundation Server (TFS) to trigger builds and Windows PowerShell to author them.

Why Windows PowerShell?
-----------------------

TFS is great at watching your source code repository for checkins and kicking off builds, but unless the features that 
come with the build out of the box are enough for you, it requires significant customization to be suitable for a 
Continous Delivery build platform. If you read Jez Humble's book he makes a much more detailed case about why it makes 
sense to author your builds in a scripting language. I'll specifically state that using PowerShell allows you several 
benefits. First, if you just use TFS to do builds, you can't run a build on your computer that does everything that 
the server can. Second, if you want to really tap into automation you will be modifying the build's behavior greatly 
and that requires recompilation of code in the case of MSBuild, or understanding the difficult Windows Workflow engine 
that TFS leverages.

What's included?
----------------

* A TFS build template written in Windows Workflow that strips out all but the basics and calls out to PowerShell to do the heavy lifting.
* A PowerShell script that implements Continous Delivery logic and process needed by any build based on PowerDelivery.
* A default Build script you can start with that includes hooks for the various steps in your build.
* A set of comma-separated files to use for storing the configuration differences between your environments. For instance, your local computer, development, test, and production environment probably use a different database.

How do I get started?
---------------------

1. Add the BuildProcessTemplates and PowerShellModules directories included in PowerDelivery to the root of any TFS source repository you want to enable for Continuous Delivery.
2. Download a copy of the PSake PowerShell extension from https://github.com/psake/psake and place it in a PSake subfolder of the PowerShellModules directory.
3. Open a PowerShell console window on the TFS build server, any TFS build agents, and your local computer and execute the following command:

````````````````````````````````
Set ExecutionPolicy RemoteSigned
````````````````````````````````