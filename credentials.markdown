---

layout: page

---

# Credentials

Credentials in powerdelivery are sets of username and password pairs used to impersonate another user account than you are logged in as when running a [target](targets.html). They can also be used in [role scripts](roles.html) to access credentials needed for secure cloud resources such as Windows Azure accounts.

## Using credentials on remote nodes

Often you may want to deploy using a different set of credentials than the currently logged in user. A common example is when production nodes require a different account than development or test nodes to deploy to. 

Additionally, if any of the PowerShell commands in the roles you execute on a remote node in turn access another node (this is known as a *"double-hop"* scenario), your credentials will fail to make it to that "second hop".

You can overcome both of these issues using either of the solutions that follow.

### Providing credentials at startup

To have powerdelivery apply roles to remote nodes using alternate credentials, pass the *-As* parameter to the [Start-Delivery](reference.html#start_delivery_cmdlet) cmdlet. Powerdelivery will prompt for the password of the username you specify. 

<p>
For example:
</p>

<div class="row">
	<div class="col-sm-8">
		{% include console_title.html %}
		<div class="console">
{% highlight powershell %}
PS> Start-Delivery MyApp Release Production -As 'MYDOMAIN\opsuser'
{% endhighlight %}
		</div>
	</div>
</div>

Keep in mind that any roles set to run on localhost for your target [environment](environments.html) will still execute under the credentials you are logged into Windows with.

### Storing credentials for silent execution

The second method of passing credentials is useful for running powerdelivery via a build server that is unable to throw up a prompt at runtime, or sharing a set of credentials with a limited set of people without giving them the password directly. This requires two steps.

<br />

<b>Step 1. Generate a credential key</b>

Powerdelivery can save credentials in an encrypted file so users are not prompted when deployment starts. The file is encrypted using a key file that you must generate. *Whoever has access to the key file will be able to decrypt the credentials stored with your source code*, so record it somewhere safe, don't put it under source control, and only hand it out to those who you trust!

The PowerShell session below demonstrates this using the [New-DeliveryKey](reference.html#new_deliverykey_cmdlet) cmdlet:

<div class="row">
	<div class="col-sm-8">
		{% include console_title.html %}
		<div class="console">
{% highlight powershell %}
PS> New-DeliveryKey ExampleKey
Key written to 'C:\Users\Jayme\Documents\PowerDelivery\Test\ExampleKey.key'
{% endhighlight %}
		</div>
	</div>
</div>

Upon running this command, copy the key file from where it was generated and save it somewhere safe. I can't stress this enough - *do not store the key file in source control*! You have been warned.

<br />
<b>Step 2. Encrypt credentials with the key</b>

Now that you have a key file, pass it to the [Write-DeliveryCredentials](reference.html#write_delivery_credentials_cmdlet) cmdlet with the username of an account. This must be run from the directory containing your project. The cmdlet will prompt for the password and write it to an encrypted file under the *Credentials* directory. This file *should* be stored in source control.

The PowerShell session below demonstrates writing credentials to a file using a key:

<div class="row">
	<div class="col-sm-12">
		{% include console_title.html %}
		<div class="console">{% highlight powershell %}
PS> Write-DeliveryCredentials ExampleKey 'MYDOMAIN\opsuser'
Enter the password for MYDOMAIN\opsuser and press ENTER:
**********
Credentials written to '.\Credentials\MyKey\MYDOMAIN#opsuser.credential'
{% endhighlight %}
		</div>
	</div>
</div>

You should commit this new file to your source control. 

<br />

<b>Step 3. Distribute the key file</b>

To enable your build server or any other person to run powerdelivery with these credentials, you need to provide them with the key file you generated in step 1. You should only do this for computers you are permitting to decrypt the key for deployment, which is why we didn't store it in source control.

<br />

Key files must go in the directory:

C:\Users\YourAccount\Documents\PowerDelivery\Keys

<br />

<b>Step 4. Deploy using the credentials</b>

Once the key file is present, *Start-Delivery* can run without prompting by passing it the *-UseCredentials* parameter:

{% include console_title.html %}
<div class="console">
  {% highlight powershell %}PS> Start-Delivery MyApp Release Production -UseCredentials 'MYDOMAIN\opsuser'{% endhighlight %}
</div>

## Using credentials in roles

You may also find a need to use credentials in a role script, for instance to authenticate with Windows Azure to manipulate cloud resources. To do this create a key and encrypt credentials following the steps above.

In your role script, use the *Credentials* property of the [$target parameter](reference.html#target_parameter) to retrieve your credentials by their username. You may then pass them to other PowerShell cmdlets that expect credentials. 

The example below assumes credentials for *me@somewhere.com* were encrypted with the *ExampleKey* key:

{% highlight powershell %}
Delivery:Role {
  param($target, $config, $role)

  # Don't do this when running on localhost
  if ($target.EnvironmentName -ne 'Local') {

    # Get Azure credentials encrypted by powerdelivery
    $azureCredentials = $target.Credentials['me@somewhere.com']

    Import-Module Azure

    # Add my credentials so I can use other Azure cmdlets!
    Add-AzureAccount -Credential $azureCredentials
  }
}
{% endhighlight %}
<div class="filename">MyAppDelivery\Roles\AzureExample\Role.ps1</div>

**Tips**:

* If you find that your credentials aren't availalbe, you may be missing the key file needed. Powerdelivery attempts to decrypt all credentials it finds in the *Credentials* subdirectory, but those for which keys are not present will be unavailable when the role executes.
* If you need to use different credentials in the role depending on which [environment](environments.html) is being targeted, consider using a [configuration variable](configuration.html) for the username.

<br />

### Next read about [configuration](configuration.html).