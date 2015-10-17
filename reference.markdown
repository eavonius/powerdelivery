---
layout: page
---

# Reference
	
This page contains reference for the commands, DSL, and cmdlets included with powerdelivery.

<a name="generators"></a>

## Generators

Generators are used to create files for building your powerdelivery release. Run these in an Administrator Powershell console.

<hr />

<a name="pow_new_command"></a>

<p class="ref-item">pow:new</p>
Generates a powerdelivery project. Run within a directory of your source code (typically the root).

<p class="ref-upper">Parameters</p>
<dl>
	<dt>-ProjectName</dt>
	<dd>The required name of the project. Use the name of a product and avoid spaces to make your life easier.</dd>
	<dt>-Environments</dt>
	<dd>An optional array of strings with the names of the environments.</dd>
</dl>
<p class="ref-upper">Examples</p>

<div class="console">
	{% highlight powershell %}
pow:new MyApp @('Local', 'Test', 'Production')
{% endhighlight %}
</div>