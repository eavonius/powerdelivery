<#
.Synopsis
Updates data in an XML file.

.Description
Selects nodes in an XML file using an XPath statement and updates attributes or content 
of those nodes.

.Parameter ComputerName
Optional. A comma-separated list of computers to update the XML file on.

.Parameter FileName
A relative path to the file to update.

.Parameter Replacements
hash - A set of named replacements to make. Each hash entry requires an XPath, Attribute, and NewValue.

.Parameter Namespaces
hash - A set of XML namespaces used in the XPath statements being replaced.

.Example
# MyConfigFile.yml

XmlReplacements:
  SomeFile:
    FileName: SomeDir\SomeFile.xml
    Replacements:
      TabularConnection:
        XPath: //mn:somelement/mn:someotherelement[@name='test']
        Attribute: someOtherAttribute
        NewValue: Hello World!
    Namespaces:
      MyNs:
        Prefix: mn
        URI: http://www.mynamespace.com/

# MyScript.ps1
$XmlReplacements = Get-BuildSetting XmlReplacements
Invoke-BuildConfigSections $XmlReplacements Update-XmlFile
#>
function Update-XmlFile {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=0)] $ComputerName,
        [Parameter(Position=1,Mandatory=1)][string] $FileName, 
        [Parameter(Position=2,Mandatory=1)] $Replacements,
        [Parameter(Position=3,Mandatory=0)] $Namespaces,
        [Parameter(Position=4,Mandatory=0)] $DriveLetter = $powerdelivery.deployDriveLetter
    )
	
	$originalLocation = Get-Location

	Set-Location $powerdelivery.deployDir

    $logPrefix = "Update-XmlFile:"

    if (![String]::IsNullOrWhiteSpace($ComputerName)) {

        $computerNames = $ComputerName -split "," | % { $_.Trim() }
	
	    foreach ($computer in $computerNames) {

            if (![System.IO.Path]::IsPathRooted($FileName)) {
                $FileName = Join-Path (Get-ComputerLocalDeployPath $computer $DriveLetter) $FileName
            }

            Invoke-Command -ComputerName $computer {

                Write-Host "$using:logPrefix Replacing values on $using:computer in $using:FileName"

                [xml]$xmlFile = Get-Content $using:FileName

                $ComputerNamespaces = $using:Namespaces

                $ns = new-object Xml.XmlNamespaceManager $xmlFile.NameTable
                if ($ComputerNamespaces -ne $null) {
                    $ComuterNamespaces.Keys | % {
                        $NamespaceEntry = $ComputerNamespaces[$_]
                        $ns.AddNamespace($NamespaceEntry.Prefix, $NamespaceEntry.URI)
                    }
                }

                $ComputerReplacements = $using:Replacements

                $ComputerReplacements.Keys | % {

                    $replacement = $ComputerReplacements[$_]

                    $node = $xmlFile.SelectSingleNode($replacement.XPath, $ns)

                    if ($node -eq $null) {
                        throw "Path $($replacement.XPath) didn't match a node on $using:computer in $using:FileName"
                    }

                    $value = $replacement.NewValue
                    $attr = $replacement.Attribute

                    Invoke-Expression "`$node.$($attr) = `"$value`""
                }

                $xmlFile.Save($using:FileName)
            }
        }
    }
    else {

        if (![System.IO.Path]::IsPathRooted($FileName)) {
            if ($powerdelivery.blockName -eq 'Compile') {
                $FileName = Join-Path $powerdelivery.currentLocation $FileName
				Set-ItemProperty $FileName -Name IsReadOnly -Value $false
            }
            else {
                $FileName = Join-Path $powerdelivery.deployDir $FileName
            }
        }

        Write-Host "$logPrefix Replacing values in $FileName"

        [xml]$xmlFile = Get-Content $FileName

        $ns = new-object Xml.XmlNamespaceManager $xmlFile.NameTable
        if ($Namespaces -ne $null) {
            $Namespaces.Keys | % {
                $NamespaceEntry = $Namespaces[$_]
                $ns.AddNamespace($NamespaceEntry.Prefix, $NamespaceEntry.URI)
            }
        }

        $ComputerReplacements = $Replacements

        $ComputerReplacements.Keys | % {

            $replacement = $ComputerReplacements[$_]

            $node = $xmlFile.SelectSingleNode($replacement.XPath, $ns)

            if ($node -eq $null) {
                throw "Path $($replacement.XPath) didn't match a node in $FileName"
            }

            $value = $replacement.NewValue
            $attr = $replacement.Attribute

            Invoke-Expression "`$node.$($attr) = `"$value`""
        }

        $xmlFile.Save($FileName)
    }
	
	Set-Location $originalLocation
}