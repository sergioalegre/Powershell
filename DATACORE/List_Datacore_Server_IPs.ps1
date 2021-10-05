#variables
$vcenter ="vcenter_server_name"

cls

Import-module vmware.vimautomation.core
Connect-VIServer -Server $vcenter
$datacore_servers= Get-VM | Where {$_.Name -Like "*CORE0*"}

foreach ($dcs in $datacore_servers){
    $IPs=$dcs.Guest.IPAddress
    foreach ($ip in $IPs){
        if($ip -notlike "192.168.*" -and $ip -notlike "fe80*"){
            Write-Host $dcs.Name $ip
        }
    }
}