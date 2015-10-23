---

layout: page

---

# Frequently Asked Questions

## Why powerdelivery?

### Why another IT automation tool?

I built powerdelivery 1.0 and released it on github in late 2012 after reading the book on [continuous delivery](https://www.thoughtworks.com/continuous-delivery) and finding no practical continuous deployment technology for Windows. In the years that followed I changed it quite a bit in version 2.0. With version 2.0, I and other colleagues deployed business intelligence, ESB, and cloud solutions with it. I also use linux stack tools like rails and wordpress for side ventures so I've had quite a bit of time with ansible, puppet and vagrant. 

Even with more tools available today, developers and operations personnel still have insufficient support for meeting the tenets of continuous delivery when dealing with Windows. Version 3.0 consolidates the best of everything I've used and adds a few innovations as a solution for PowerShell.

### What about Microsoft Release Management?

Microsoft acquired Incycle a couple of years ago to bolt their product with automated release capabilities on top of Team Foundation Server. After using TFS for many clients and evaluating Release Manager, I have yet to find a client who finds Windows Workflow Foundation, its core technology, easy enough to work with and rapid enough to change. The continuous delivery methodology encourages using a scripting language for automating IT releases, and PowerShell is the premier technology on Windows. This is part of the reason why I continue to use powerdelivery with clients after the availability of Release Manager.

### What about PowerShell Desired State Configuration (DSC)?

I believe DSC is fine if you want an agent watching over nodes and ensuring their configuration is in the same state and all of your nodes have the requirements to run DSC. In my experience, many teams are still dealing with legacy nodes and deploying using different types of connections, and there is more PowerShell code out there outside of DSC configurations than within it. 

DSC doesn't provide much in the way of structure and conventions for managing a complex release management pipeline and leaves it up to you to figure out how to coordinate passing environment-specific nodes and variables to configurations, making sure you run on each node with the right credentials. I'd like to see Microsoft adopt some of what's in powerdelivery in DSC.

### Why doesn't powerdelivery include all the stuff in ansible?

Ansible is improving their support for managing Windows, but it is still triggered from a linux box. Because it uses python, there's less code out there for Windows so ansible is slowly adding some to cover common cases. Since powerdelivery is written in PowerShell, the multitude of freely available code and modules on the web are already available to you. For the most part, powerdelivery should stay out of your way and support you so you can just get stuff done. It does include a few [cmdlets](reference.html#cmdlets) to do common things that I got sick of scripting the same in every release.

## Common concerns

### Help! My product runs partially on premise, and partially in the cloud!

Powerdelivery can handle this with no problems whatsoever. Because it separates environments and logic in a simple way, you can target the cloud for some roles and on-premise resources for others and still release in an atomic process through a single [target](targets.html) if needed.

### Can I spin up nodes on the fly?

Powerdelivery employs [environment](environments.html) scripts to configure the names or IP addresses of nodes to deploy to. Since this is just a PowerShell script but it must return available nodes at the end, you can script provisioning before this to get the names or IP addresses of nodes to return. If you want to get a list of nodes with a tag, tear down, or clone existing nodes before you return the list for the environment - go for it!

### I don't want my developers to deploy to test or production!

This is a common concern to achieve SOX compliance and easy with powerdelivery. You can either keep your powerdelivery project's code in a separate source control repository from the main code and have it pull down the product's code (or pre-built packages by the dev team) before deploying, or just use [credentials](secrets.html#using_secrets_for_credentials) to control which accounts can deploy to which environments.

### Can I modify powerdelivery?

It's up on github and covered under the MIT license, so have at it! I encourage people to fork the code and submit pull requests if you find a defect or want to contribute improvements. I created powerdelivery to help my clients be successful, release side projects, and help others that have embraced PowerShell stop the chaos of manual changes to IT infrastructure. I'd love your help and ideas!

### Can you help me implement continuous delivery?

I'm a Managing Consultant for [Catapult Systems](http://www.catapultsystems.com) who is a Microsoft Gold partner, and I'm based out of Austin, Texas. If you are interested in hiring me to help you, [send me an email](mailto:jayme.edwards@catapultsystems.com). Otherwise you can use the [google group](https://groups.google.com/forum/#!forum/powerdelivery) to discuss powerdelivery, or visit [issues on github](https://github.com/eavonius/powerdelivery/issues) if you have a defect or enhancement to discuss.