# conectar vcenter
cls
Add-PSSnapin VMware.VimAutomation.Core
$user = "PUT_USERNAME_HERE"
$pass = "PUT_PASSWORD_HERE"
$vcenter = "PUT_VCENTER_HERE"
Connect-VIServer -Server $vcenter -User $user -Password $pass | Out-Null


# conesguir lista de hosts
$lista = Get-VMHost


# bucle para planchar la config snmp a todos
ForEach ($VMHost in $lista)
   { 
    Write-Host("---------")
    Write-Host($VMHost)
    $esxcli = Get-VMHost $VMHost | Get-Esxcli
    $esxcli.system.snmp.set($null,'public',$true,$null,$null,$null,$null,$null,'161',$null,$null,$null,$null,$null,'10.30.240.40@162/public',$null,$null)
    Write-Host("---------")
   }


# ejemplo escribir en 1 host concreto
#$esxcli =  Get-VMHost ryasvm03.grupoantolin.com | Get-Esxcli
#$esxcli.system.snmp.set($null,'public',$true,$null,$null,$null,$null,$null,'161',$null,$null,$null,$null,$null,'10.30.240.40@162/public',$null,$null)


# comprobar un host en concreto
#$esxcli =  Get-VMHost ryasvm03.grupoantolin.com | Get-Esxcli
#$esxcli.system.snmp.get()


# permitir trafico en firewall
#$esxcli.network.firewall.ruleset.set –-ruleset-id snmp -–allowed-all true
