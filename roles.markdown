---

layout: page

---

# Roles

When performing deployment activities with powerdelivery, the real work that applies changes to your nodes happens in roles. These are PowerShell scripts within the *Roles* directory of your project in their own directory named after the role.

## Generating role scripts

To assist with creating roles, you can use the [New-DeliveryRole](reference.html#new_deliveryrole_cmdlet) cmdlet to generate one for your project. Run this cmdlet in the directory above your powerdelivery project.

<br />

Below is an example of creating a role for installing the <a href="http://www.chocolatey.org" target="_blank">chocolatey</a> package manager:

<div class="row">
	<div class="col-sm-8">
		{% include console_title.html %}
		<div class="console">
{% highlight powershell %}
PS> New-DeliveryRole MyApp Chocolatey
Role created at ".\MyAppDelivery\Roles\Chocolatey"
{% endhighlight %}
		</div>
	</div>
</div>

<br />

After this cmdlet completes it will have added the following to your directory structure:

<div class="row">
  <div class="col-sm-8">
    <pre class="directory-tree">
.\MyAppDelivery\
    |-- Roles\
        |-- Compile\
            |-- Always.ps1
            |-- Migrations\</pre>
  </div>
</div>

<br />