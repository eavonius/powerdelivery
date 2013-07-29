function Get-ArrayFromStringOrHash {
    param(
        [Parameter(Position=0,Mandatory=1)] $computerNames
    )
    
    if ($computerNames.GetType().Name -eq 'Hashtable') {
        return $computerNames.Values
    }
    else {
        return @($computerNames)
    }
}