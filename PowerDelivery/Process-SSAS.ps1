function Process-SSAS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $computerName, 
        [Parameter(Mandatory=1)][string] $cubeName,
        [Parameter(Mandatory=0)][string] $processType = "ProcessFull"
    )
    
    Set-Location $powerdelivery.deployDir

    $logPrefix = "Process-SSAS:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        $processCubeQuery = @"
        <Process xmlns=`"http://schemas.microsoft.com/analysisservices/2003/engine`">
          <Type>$processType</Type>
          <Object>
            <DatabaseID>$cubeName</DatabaseID>
          </Object>
        </Process>
"@
        "$logPrefix Processing $cubeName on $curComputerName..."

        $processResult = Invoke-Command -ComputerName $curComputerName {
            Invoke-ASCMD -server "$using:curComputerName" -query "$using:processCubeQuery"
        }

        [xml]$processXml = $processResult | ConvertTo-Xml

        $nsOut = new-object Xml.XmlNamespaceManager $processXml.NameTable
        $nsOut.AddNamespace('xa', 'urn:schemas-microsoft-com:xml-analysis')
        $nsOut.AddNamespace('xae', 'urn:schemas-microsoft-com:xml-analysis:empty')
        $nsOut.AddNamespace('xex', 'urn:schemas-microsoft-com:xml-analysis:exception')

        $warningNodes = $processXml.SelectNodes("//xa:return/xae:root/xex:Messages/xex:Warning", $nsOut)

        $deploySuccess = $true

        if ($warningNodes -ne $null) {
            foreach ($warningNode in $warningNodes) {
                
                $warningDesc = $warningNode.Description
                
                "SSAS Processing Error: $warningDesc"

                $deploySuccess = $false
            }
        }

        if ($deploySuccess -eq $false) {
            throw "One or more errors occurred deploying an SSAS cube. See the build log for details."
        }
        else {
            "$logPrefix Processing of $cubeName on $curComputerName successful."
        }
    }
}