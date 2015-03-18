if (-not (get-module PsGet -ListAvailable)){
    (new-object Net.WebClient).DownloadString("http://bit.ly/GetPsGet") | iex
}
if (-not (get-module PsUrl -ListAvailable)){
    import-module PsGet
    install-module PsUrl
}

#if (-not (get-module PsJson -ListAvailable)){
#    import-module PsGet
#    install-module PsJson
#}

function Invoke-Nvt {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Command,
    [String]$Destination = "http://localhost:8100/Commands/Legacy/",
    [Parameter(ValueFromRemainingArguments=$true)]
    $Data
)
    # Prepare dependecies    
    import-module PsUrl

    Write-Host $Destination
    
    # Prepare data
    $preparedData = @{} 
    $preparedData["Zaz-Command-Id"] = $Command
    foreach($item in $Data){
        $argMatch = [regex]::match($item, "(?'key'[^:]+):(?'value'.*)")
        if ($argMatch.Groups["key"].Success) {
            $preparedData.Add($argMatch.Groups["key"].Value, $argMatch.Groups["value"].Value)
        }
    }

    # POST!
    Write-Url $Destination -Data $preparedData -Timeout 00:59:00
}

#function Get-Nvt {
#[CmdletBinding()]
#Param(
#    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
#    [String]$View,
#	[String]$Query,
#	[String]$Context,
#    [String]$Destination = "http://localhost:8100/Services/Views/"
#)
#    # Prepare dependecies    
#    import-module PsUrl
#	import-module PsJson
#        	
#	$URL = $Destination + "?view=$View&query=$Query&secretContextId=$Context"
#
#    # GET
#    Get-Url $URL | ConvertFrom-JSON
#}

Set-Alias nvt Invoke-Nvt
Export-ModuleMember -Function Invoke-Nvt,Get-Nvt -Alias *