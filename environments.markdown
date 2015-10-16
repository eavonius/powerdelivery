---

layout: page

---

# Environments

Next you need to think about what groups of computing nodes in your infrastructure will host your product in production. For example, you may need a set of three nodes participating as a "farm" to serve a website, two nodes running in a Windows cluster to host the database, and two more nodes that perform some batch processing. This will be totally dependent on your application - powerdelivery places no restrictions on the scale or structure you wish to employ.

Powerdelivery can deploy to computing nodes that are on-premise or in the cloud. It can also deploy to nodes that have already been provisioned (stood up with the operating system already joined to a domain), or spin up new ones on the fly. You can read about provisioning on the fly in the [roles](roles.html) topic, this is a more advanced technique that we'll skip for now to keep this overview topic moving forward.

Let's assume our test environment will have two web server nodes and one database server node. It's often good to have at least two nodes in any test environment that will have more than one in production to catch issues that only arise when things are load balanced or part of a "cluster" or "availability set". Let's assume then that in production, there will be four web servers and two database servers that have been setup for fault tolerance by being part of a Windows cluster. Again, there are no requirements about how you slice and dice the infrastructure. If you want to have one node for both environments that is up to you, but you must figure this out before you can start deploying into these environments.

To have Powerdelivery provision nodes on the fly, you'll need to install additional Powershell modules (e.g. Azure, VMWare, or Hyper-V cmdlets) or other command-line utilities (for example, the AWS SDK) and make sure these are able to be found when you run powerdelivery from the command-line. For Powershell modules, this usually happens automatically when you install them, or they can be added to the PSMODULEPATH system environment variable. For 