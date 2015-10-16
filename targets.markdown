---

layout: page

---

# Targets

In powerdelivery, a sequential deployment process you might want to perform is represented by a target script. These are scripts contained within the **Targets** subdirectory and describe a sequential process. Each step in this process applies one or more [roles](roles.html) to one or more [nodes in an environment](environments.html). 

## Anatomy of a target script

## Creating your own targets

Every powerdelivery project comes with an empty target **Release** (located in Targets\Release.ps1) that will typically be configured to apply one or more roles to the local computer to compile/build source code and then release it. You can put all of your deployment steps in this one target, or create as many other additional target scripts as you like. You can even delete the Release target script if you don't like it.

As an example, you may want to create one target that provisions nodes (spins them up in Azure, AWS, or your local VMWare or Hyper-V virtualized resource pool), and another that performs actual deployments. This could then be controlled through [credentials](credentials.html) to allow operations personnel to provision nodes, but only permit developers to perform deployments of the product.