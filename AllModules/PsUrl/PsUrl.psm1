##
##    Inspired by curl, adds some commands to work with web.
##

function Get-Url {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
    [String]$ToFile
)
    if ($ToFile -ne ""){
        (New-Object System.Net.WebClient).DownloadFile($Url, $ToFile)    
    } else {
        (New-Object System.Net.WebClient).DownloadString($Url)
    }
<#
.Synopsis
    Downloads from url as a string.
.Description     
.Parameter Url
    URL to download
.Parameter ToFile
    Optional parameter to dowload stuff to the file.
.Example
    Get-Url http://chaliy.name

    Description
    -----------
    Downloads content of the http://chaliy.name

#>
}

function Write-Url {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
	[HashTable]$Data,
	[TimeSpan]$Timeout = [System.TimeSpan]::FromMinutes(1)
)    
    Add-Type -AssemblyName System.Web
    $formData = [System.Web.HttpUtility]::ParseQueryString("")	
	foreach($key in $Data.Keys){
        $formData.Add($key, $Data[$key])		
	}
	$reqBody = [System.Text.Encoding]::Default.GetBytes($formData.ToString())	
	
	try{
		$req = [System.Net.WebRequest]::Create($Url)
		$req.Method = "POST"
		$req.ContentType = "application/x-www-form-urlencoded"		
		$req.Timeout = $Timeout.TotalMilliseconds
		$reqStream = $req.GetRequestStream()		
		$reqStream.Write($reqBody, 0, $reqBody.Length)
		$reqStream.Close()
		
		$resp = $req.GetResponse()
		$respStream = $resp.GetResponseStream()
		$respReader = (New-Object System.IO.StreamReader($respStream))
		$respReader.ReadToEnd() 		
	}
	catch [System.Net.WebException]{
		if ($_.Exception -ne $null -and $_.Exception.Response -ne $null) {
	 		$errorResult = $_.Exception.Response.GetResponseStream()
			$errorText = (New-Object System.IO.StreamReader($errorResult)).ReadToEnd()
			Write-Error "The remote server response: $errorText"
		}
		throw $_
	}	
	
<#
.Synopsis
    POST values to URL
.Description     
.Parameter Url
    URL to POST
.Parameter Data
    Hashtable of the data to post.
.Parameter Timeout
    Optional timeout value, by default timeout is 1 minute.
.Example
    Write-Url http://chaliy.name -Data @{"Foo" = "Bar" }

    Description
    -----------
    POST's to the http://chaliy.name as application/x-www-form-urlencoded

#>
}


Export-ModuleMember Get-Url
Export-ModuleMember Write-Url