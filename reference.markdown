---
layout: page
---

# Reference
	
This page contains reference for the commands, DSL, and cmdlets included with powerdelivery.

<a name="Cmdlets"></a>

## Cmdlets

Cmdlets are Powershell functions included with powerdelivery generate files and run commands within [roles](roles.html).

<hr />

<a name="new_deliveryproject_cmdlet"></a>

<p class="ref-item">New-DeliveryProject</p>
Generates a new powerdelivery project. Typicall run at the root of a folder with source code (git, TFS, whatever).

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-ProjectName</dt>
	<dd>The required name of the project. A folder with this name suffixed with "Delivery" will be created containing the project.</dd>
	<dt>-Environments</dt>
	<dd>An optional array of strings with the names of the environments.</dd>
</dl>
<p class="ref-upper">Examples</p>

<div class="console">
	{% highlight powershell %}
New-DeliveryProject MyApp @('Local', 'Test', 'Production')
{% endhighlight %}
</div>