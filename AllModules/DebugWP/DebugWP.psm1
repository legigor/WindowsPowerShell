function Debug-Wp([string]$name)
{
  if([String]::IsNullOrEmpty($name)) 
  {
    throw "Usage: Webug-Wp -Name 'appPoolName'"
  }

  $wplist = Get-WmiObject Win32_Process -f "Name='w3wp.exe'"
  
  foreach($wp in $wplist)
  {
    if($wp.CommandLine -match ('-ap "' + $name + '"')) 
    {
        vsjitdebugger.exe -p $wp.ProcessID
        break
    }
  }
  
  Write-Host "Could not find AppPool" $name
}
