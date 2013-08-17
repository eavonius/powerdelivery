function Update-XmlFile {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)] $ComputerName,
        [Parameter(Position=1,Mandatory=1)][string] $FileName, 
        [Parameter(Position=2,Mandatory=1)] $Replacements
    )

    $logPrefix = "Update-XmlFile:"

    $computerNames = $ComputerName -split "," | % { $_.Trim() }
	
	foreach ($computer in $computerNames) {

        if (![System.IO.Path]::IsPathRooted($FileName)) {
            $FileName = Join-Path (Get-ComputerLocalDeployPath $computer) $FileName
        }

        Invoke-Command -ComputerName $computer {

            Write-Host "$using:logPrefix Replacing values on $using:computer in $using:FileName"

            [xml]$xmlFile = Get-Content $using:FileName

            $ComputerReplacements = $using:Replacements

            $ComputerReplacements.Keys | % {

                $replacement = $ComputerReplacements[$_]

                $node = $xmlFile.SelectSingleNode($replacement.XPath)

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