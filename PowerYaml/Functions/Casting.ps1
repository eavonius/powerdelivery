function Add-CastingFunctions($value) {
	Add-Member -InputObject $value -Name ToInt `
           -MemberType ScriptMethod -PassThru -ErrorAction SilentlyContinue -Value `
           { [int] $this } |
		   Add-Member -Name ToLong `
           -MemberType ScriptMethod -PassThru -ErrorAction SilentlyContinue -Value `
           { [long] $this } |
           Add-Member -Name ToDouble `
           -MemberType ScriptMethod -PassThru -ErrorAction SilentlyContinue -Value `
           { [double] $this } |
           Add-Member -Name ToDecimal `
           -MemberType ScriptMethod -PassThru -ErrorAction SilentlyContinue -Value `
           { [decimal] $this } |
           Add-Member -Name ToByte `
           -MemberType ScriptMethod -PassThru -ErrorAction SilentlyContinue -Value `
           { [byte] $this } |
           Add-Member -Name ToBoolean `
           -MemberType ScriptMethod -PassThru -ErrorAction SilentlyContinue -Value `
           { [System.Boolean]::Parse($this) }

	return $value
		   
}