##
##    PowerShell Client for Zaz Command Bus
##

function Send-ZazCommand {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Command,
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, Position=1)]
    [HashTable]$Data = @{},    
    [String]$Destination,
    [Management.Automation.PSCredential]$Credential
)

ipmo psget
install-module psjson
install-module psurl
#ipmo c:\Users\m\Projects\psurl\PsUrl\PsUrl.psm1 -force 
# PsJson and PsUrl are used to ensure script works under Powershell v2.0

$cmd = @{}
$cmd.Key = $Command
$cmd.Command = $Data

$Status_Pending = 'Pending'
$Status_InProgress = 'InProgress'
$Status_Success = 'Success'
$Status_Failure = 'Failure'

$Severity_Info = 'Info'
$Severity_Warning = 'Warning'
$Severity_Error = 'Error'

function convertToToken($d){
    $d.ToString("o")
}

function convertFromJsonDate($ii){
    if ($ii -match 'Date\((?<d>\d*)\)'){
        $d = new-object DateTime(1970, 1, 1)
        $d.AddMilliseconds([double]$matches["d"] + 1)
    }    
}

function writeLog($t, $sev, $msg){
    switch($sev){
        $Severity_Info {
            Write-Host $msg
        }
        
        $Severity_Warning {
            Write-Host $msg -ForegroundColor:Yellow
        }
        
        $Severity_Error {
            Write-Host $msg -ForegroundColor:Red
        }
    }
}

# Async
$scheduledUrl = ($Destination + "Scheduled")

Write-Verbose "Post command: $Command to $scheduledUrl"

Exit-Host

$cmdContent = convertto-json $cmd
$scheduledResp = Write-Url $scheduledUrl -Content:$cmdContent -ContentType:"application/json" -Credential:$Credential -ErrorAction:Stop
$scheduled = convertfrom-json $scheduledResp
$execId = $scheduled.Id

Write-Verbose "Execution ID: $execId"

$read = $true
$token = [DateTime]::MinValue
while($read){

    sleep -m 400

    $commandStatsUrl = $Destination + "Scheduled/" + $execId + "/?token=" + (convertToToken($token))
    Write-Verbose "Download command stats from $commandStatsUrl"
    $statsResp = Get-Url $commandStatsUrl -Credential:$Credential -ErrorAction:Stop
    $stats = convertfrom-json $statsResp
    
    $status = $stats.Status
    $log = $stats.Log    

    $log | % {
                   
        $timestamp = convertFromJsonDate($_.Timestamp)

        writeLog $timestamp ($_.Severity) ($_.Message)

        if ($timestamp -gt $token){
            $token = $timestamp
        }
    }

    switch ($status){               

        $Status_Pending {            
            Write-Verbose "Command($execId) is pending"
        }
        $Status_InProgress {
            Write-Verbose "Command($execId) is in progress"
        }                    
        $Status_Success {
            Write-Host "Command($execId) is complete" -ForegroundColor:Green
            $read = $false
        }
        $Status_Failure {
            Write-Error "Command($execId) failed"
            $read = $false
        }        
    }
}
    
<#
.Synopsis
    Sends command to ZAZ Command Bus
.Description    
.Parameter Command
    Key of the command
.Parameter Data
    Optional JSON payload of the command
.Parameter Destination
    Full URL to the command endpoint
.Example
    Send-ZazCommand FooCommand

    Description
    -----------
    Sends command FooCommand
	
.Example
    Send-ZazCommand Ping "{ Message : 'Hello word!' }" -Destination "http://localhost:9302/Commands"

    Description
    -----------
    Sends command Ping to command bus at "http://localhost:9302/Commands" with some data.

#>
}