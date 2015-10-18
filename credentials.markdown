---

layout: page

---

# Credentials

Often you will want to deploy with powerdelivery using a different set of credentials than the currently logged in user (for example into a production environment), so you need a way to pass those credentials.

Also, if any of the PowerShell commands in the roles you execute on a remote node in turn access another node (this is known as a *"double-hop"* scenario), your credentials will fail to make it to that "second hop".

You can overcome both of these problems with either of the following two solutions.

## Providing credentials at startup

To have powerdelivery apply roles to remote nodes using alternate credentials, pass the *-As* parameter. Powerdelivery will prompt for the password of the username you specify as it starts. 

Below is an example:

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

Powerdelivery can write credentials provided to it into an encrypted file so the user is not prompted when deployment starts. The encryption uses a key you must generate. *Whoever has access to this key will be able to decrypt the credentials stored with your source code*, so record the key somewhere safe, don't put it under source control, and only hand it out to those who you trust!

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
Write-DeliveryCredentials 'dP1tXKWC1u6dLOf/PsYrwqNzXVPuRy+/qkbjHYZoS9o=' 'MyKeyName' 'MYDOMAIN\opsuser'
Enter the password for MYDOMAIN\opsuser and press ENTER:
**********
Credentials written to ".\Credentials\MyKeyName\MYDOMAIN#opsuser.credentials"
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

C:\Users\YourAccount\Documents\PowerDelivery\Keys\MyKeyName.key

<br />

<h3>Step 4. Run using the credentials</h3>


To run powerdelivery using this set of credentials without prompting, once the keyfile is present *Start-Delivery* can be run by your build server or another person who has the environment variable set passing the *-Credential* parameter:

<br />

{% include console_title.html %}
<div class="console">
  {% highlight powershell %}StartDelivery MyApp Release Production -credential 'MYDOMAIN\opsuser'{% endhighlight %}
</div>

## Using credentials in roles

<br />

### Next read about [configuration](configuration.html).