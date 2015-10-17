---

layout: page

---

# Credentials

When you run powerdelivery without specifying alternate credentials, [roles](roles.html) that run on nodes will execute as whoever is logged in that ran powerdelivery with the [pow](reference.html#pow_command) command. However, if any of the Powershell commands in the roles you execute on a remote node in turn access another node (this is known as a *"double-hop"* scenario), your credentials will fail to make it to that "second hop".

Additionally, if you wish to run powerdelivery against a different environment (for example, production) using a different set of credentials than the currently logged in user, you will need a way to pass those credentials.

You can overcome both of these problems with either of the following two solutions.

## Providing credentials at startup

To have powerdelivery execute activities on remote nodes using alternate credentials, pass the *-as* parameter. Powerdelivery will prompt for the password of the username you specify with this parameter and execute any roles on remote nodes using these credentials. Below is an example:

<div class="row">
	<div class="col-sm-8">
		<div class="console">{% highlight powershell %}pow release production -as 'MYDOMAIN\opsuser'{% endhighlight %}</div>
	</div>
</div>

Keep in mind that any roles set to run on localhost for your target [environment](environments.html) will still execute under the credentials you are logged into Windows with.

## Storing credentials for silent execution

The second method of passing credentials is useful for running powerdelivery via a build server that is unable to throw up a prompt at runtime, or sharing a set of credentials with a limited set of people without giving them the password directly. This requires two steps.

<br />
<h3>Step 1. Generate a credential key</h3>

Powerdelivery encrypts credentials provided to it for use without prompting using a key. *Whoever has access to this key will be able to decrypt the credentials stored with your source code*, so powerdelivery doesn't store the key and you will need to record it somewhere safe and only hand it out to those who you trust.

The Powershell session below demonstrates generating a key:

<div class="row">
	<div class="col-sm-8">
		<div class="console">{% highlight powershell %}pow:credentials:key
dP1tXKWC1u6dLOf/PsYrwqNzXVPuRy+/qkbjHYZoS9o=
{% endhighlight %}
		</div>
	</div>
</div>

Upon running this command, copy the key from the Powershell console and save it somewhere safe (**NOT in source control!**).

<br />
<h3>Step 2. Store credentials with the key</h3>

Now that you have a key, you pass the key to another powerdelivery command that will once again prompt for credentials, but this time store them in a file under the *Credentials* directory. This file *should* be stored in source control.

The Powershell session below demonstrates storing credentials with a key:

<div class="row">
	<div class="col-sm-12">
		<div class="console">{% highlight powershell %}
pow:credentials:save 'dP1tXKWC1u6dLOf/PsYrwqNzXVPuRy+/qkbjHYZoS9o=' 'MYDOMAIN\opsuser'
Enter the password for MYDOMAIN\opsuser and press ENTER:
**********
Credentials exported to ".\Credentials\MYDOMAIN#opsuser.credentials"
{% endhighlight %}
		</div>
	</div>
</div>

You should now commit this new file to your source control. 

<br />
<h3>Step 3. Set environment variable with key</h3>

To enable your build server or any other person to run powerdelivery under this set of credentials, you need to provide them with the key you generated in step 1. They then need to create an environment variable named MYDOMAIN_MYUSER_KEY with the value of the variable set to the key. Below is an example of setting the key using the Windows System control panel dialog for setting an envrionment variable using our example credential:

<br />
![](img/set_credential_envvar.png)

*Figure: Setting a credential environment variable*

<br />
<h3>Step 4. Run using the credentials</h3>


To run powerdelivery using this set of credentials without prompting, once this environment variable has been set *and a Powershell Administrator console has been re-opened* the following command can be run by your build server or another person who has the environment variable set without prompting:

<div class="console">
  {% highlight powershell %}pow release production -credential 'MYDOMAIN\opsuser'{% endhighlight %}
</div>

**NOTE**: If you have set an environment variable with a key and a build server is failing to authenticate with stored credentials, remember you may need to restart the build server (typically a console application or Windows service if using TeamCity or Team Foundation Server build) to pick up the new environment variable.

## Using credentials in roles

TODO

<br />

### Next read about [configuration](configuration.html).