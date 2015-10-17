---

layout: page

---

# Frequently Asked Questions

### Why another IT automation tool?

I built powerdelivery 1.0 and released it on github in late 2012 after reading the book on [continuous delivery](https://www.thoughtworks.com/continuous-delivery) and finding no practical continuous deployment technology for Windows. In the years that followed I changed it quite a bit in version 2.0. With version 2.0, I and other colleagues deployed business intelligence, ESB, and cloud solutions with it. I also use linux stack tools like rails and wordpress for side ventures so I've had quite a bit of time with ansible, puppet and vagrant. 

Even with more tools available today, developers and operations personnel still have insufficient support for meeting the tenets of continuous delivery when dealing with Windows. Version 3.0 consolidates the best of everything I've used and adds a few innovations as a solution for Powershell.

### What about Microsoft Release Management?

Microsoft acquired Incycle a couple of years ago to bolt their product with automated release capabilities on top of Team Foundation Server. After using TFS for many clients and evaluating Release Manager, I have yet to find a client who finds Windows Workflow Foundation, its core technology, easy enough to work with and rapid enough to change. The continuous delivery methodology encourages using a scripting language for automating IT releases, and Powershell is the premier technology on Windows. This is part of the reason why I continue to use powerdelivery with clients after the availability of Release Manager.

### What about Powershell Desired State Configuration (DSC)?

There is some overlap between what's possible with DSC and powerdelivery. I believe DSC is a promising technology that is great if you want an agent watching over nodes and ensuring their configuration is in the same state such as is possible with [chef](https://www.chef.io). Unfortunately, it doesn't provide enough structure and conventions for managing a complex release management pipeline and leaves it up to you to figure out how to break apart your scripts, and manage separate environments and credentials. Powerdelivery can manage credentials and configuration settings in its own definition of [roles](roles.html) and apply these to DSC if you like. However this requires Powershell 4 or later, and isn't really necessary.

### Why doesn't powerdelivery include all the stuff in ansible?

Ansible is improving their support for managing Windows, but it is still triggered from a linux box. Because it uses python, there's less code out there for Windows so ansible is slowly adding some to cover common cases. Since powerdelivery is written in Powershell, the multitude of freely available Powershell scripts and modules on the web are already available to you. Powerdelivery also includes a few [cmdlets](reference.html#cmdlets) to do common things that I got sick of scripting the same in every release.

### Help! My product runs partially on premise, and partially in the cloud!

Powerdelivery can handle this with no problems whatsoever. Because it separates environments and logic in a simple way, you can target the cloud for some roles and on-premise resources for others and still release in an atomic process through a single [target](targets.html) if needed.

### Can I spin up nodes on the fly?

Powerdelivery employs [environment](environments.html) scripts to configure the names or IP addresses of nodes to deploy to. Since this is just a Powershell script but it must return available nodes at the end, you can script provisioning before this to get the names or IP addresses of nodes to return. If you want to get a list of nodes with a tag, tear down, or clone existing nodes before you return the list for the environment - go for it!

### Can I modify powerdelivery?

It's up on github and covered under the MIT license, so have at it! I encourage people to fork the code and submit pull requests if you find a defect or want to contribute improvements. I created powerdelivery to help my clients be successful, release side projects, and help others that have embraced Powershell stop the chaos of manual changes to IT infrastructure. I'd love your help and ideas!