function Invoke-Nvt {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Command,
    [String]$Destination = "http://localhost:8001/services/api/commands/",
    [Parameter(ValueFromRemainingArguments=$true)]
    $Data
)    
    # Setup dependecies    
    import-module PsGet    
    #install-module Zaz
    import-module Zaz
    
    # Prepare data
    $preparedData = @{}
    foreach($item in $Data){
        $argMatch = [regex]::match($item, "(?'key'[^:]+):(?'value'.*)")
        if ($argMatch.Groups["key"].Success) {  
            $preparedData[$argMatch.Groups["key"].Value] = $argMatch.Groups["value"].Value
        }
    }    

    $cred = New-Object Management.Automation.PSCredential("NventreeServices@justapplications.co.uk", ( ConvertTo-SecureString "J44u5t77i6l817!" -asPlainText -Force ))
    
    # POST!
    Send-ZazCommand $Command $preparedData -Destination:$Destination -Credential:$cred
        
}

Set-Alias nvt2 Invoke-Nvt
Export-ModuleMember -Function Invoke-Nvt -Alias *