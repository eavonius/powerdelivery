function Update-XmlFile {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=0)] $ComputerName,
        [Parameter(Position=1,Mandatory=1)][string] $FileName, 
        [Parameter(Position=2,Mandatory=1)] $Replacements,
        [Parameter(Position=3,Mandatory=0)] $Namespaces
    )

	Set-Location $powerdelivery.deployDir

    $logPrefix = "Update-XmlFile:"

    if (![String]::IsNullOrWhiteSpace($ComputerName)) {

        $computerNames = $ComputerName -split "," | % { $_.Trim() }
	
	    foreach ($computer in $computerNames) {

            if (![System.IO.Path]::IsPathRooted($FileName)) {
                $FileName = Join-Path (Get-ComputerLocalDeployPath $computer) $FileName
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
            $FileName = Join-Path $powerdelivery.deployDir $FileName
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
}