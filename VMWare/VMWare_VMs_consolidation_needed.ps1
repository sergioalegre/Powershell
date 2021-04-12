Add-PSSnapin VMware.VimAutomation.Core

$user = "tu_user"
$pass = "tu_pass"
$vcenter = "tu_vcenter"

Connect-VIServer -Server $vcenter -User $user -Password $pass

cls

write-host "Las VMs pendientes de consolidar son: "

Get-VM | where {$_.ExtensionData.Runtime.consolidationNeeded} | Select Name
