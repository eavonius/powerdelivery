---

layout: page

---

# Credentials

Often you may want to deploy using a different set of credentials than the currently logged in user (for example to a production environment by specific accounts or groups). 

In addition, if any of the PowerShell commands in the [roles](roles.html) you execute on a remote node in turn access another node (this is known as a *"double-hop"* scenario), your credentials will fail to make it to that "second hop".

You can overcome both of these issues using either of the solutions that follow.

## Providing credentials at startup

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

## Storing credentials for silent execution

The second method of passing credentials is useful for running powerdelivery via a build server that is unable to throw up a prompt at runtime, or sharing a set of credentials with a limited set of people without giving them the password directly. This requires two steps.

<br />

<h3>Step 1. Generate a credential key</h3>

Powerdelivery can save credentials in an encrypted file so users are not prompted when deployment starts. The file is encrypted using a key that you must generate. *Whoever has access to this key will be able to decrypt the credentials stored with your source code*, so record the key somewhere safe, don't put it under source control, and only hand it out to those who you trust!

The PowerShell session below demonstrates this using the [New-DeliveryCredentialKey](reference.html#new_deliverycredentialkey_cmdlet) cmdlet:

<div class="row">
	<div class="col-sm-8">
		{% include console_title.html %}
		<div class="console">
{% highlight powershell %}
PS> New-DeliveryCredentialKey 
dP1tXKWC1u6dLOf/PsYrwqNzXVPuRy+/qkbjHYZoS9o=
{% endhighlight %}
		</div>
	</div>
</div>

Upon running this command, copy the key from the PowerShell console and save it somewhere safe. I can't stress this enough - *do not store the key in source control*! You have been warned.

<br />
<h3>Step 2. Encrypt credentials with the key</h3>

Now that you have a key, pass it to the [Write-DeliveryCredentials](reference.html#write_delivery_credentials_cmdlet) cmdlet with a name for the key, and the name of the account. The cmdlet will prompt for the password and write it to an encrypted file under the *Credentials* directory. This file *should* be stored in source control.

The PowerShell session below demonstrates writing credentials to a file using a key:

<div class="row">
	<div class="col-sm-12">
		{% include console_title.html %}
		<div class="console">{% highlight powershell %}
PS> Write-DeliveryCredentials 'dP1tXKWC1u6dLOf/PsYrwqNzXVPuRy+/qkbjHYZoS9o=' 'MyKey' 'MYDOMAIN\opsuser'
Enter the password for MYDOMAIN\opsuser and press ENTER:
**********
Credentials written to ".\Credentials\MyKey\MYDOMAIN#opsuser.credentials"
{% endhighlight %}
		</div>
	</div>
</div>

You should now commit this new file to your source control. 

<br />

<h3>Step 3. Create a keyfile</h3>

To enable your build server or any other person to run powerdelivery with these credentials, you need to provide them with the key you generated in step 1. You should only do this for computers you are permitting to decrypt the key for deployment, which is why we didn't store it in source control. Create a text file named after the second parameter passed to the Write-DeliveryCredentials cmdlet in step 2.

<br />

This must go in the directory:

C:\Users\YourAccount\Documents\PowerDelivery\Keys

<br />

In the example in step 2, we named the key *MyKey* so the text file with the key generated in step 1 goes here:

C:\Users\YourAccount\Documents\PowerDelivery\Keys\MyKey.key

<br />

<h3>Step 4. Deploy using the credentials</h3>

Once the keyfile is present, *Start-Delivery* can run without prompting by passing it the *-Credential* parameter:

{% include console_title.html %}
<div class="console">
  {% highlight powershell %}PS> Start-Delivery MyApp Release Production -Credential 'MYDOMAIN\opsuser'{% endhighlight %}
</div>

## Using credentials in roles

<br />

### Next read about [configuration](configuration.html).