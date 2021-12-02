#Nota: solo funciona si hay comunicacion no bloqueada por firewall

###Highlights:
# - invocar comando remoto mediante sesión
# - Test-Connection

#variables
$vCenter = <ip_vcenter>
$server_monitorizacion= <ip_server_monitorizacion>

cls
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
cls

$lista= Get-VM | Where { $_.Name -Like "*VMXXX0*"  } | Sort -Property Name
Write-Host "How many XXX servers we have and where: " $lista.Count
foreach ($vm in $lista){
    if(Test-Connection -Computername $vm -BufferSize 16 -Count 1 -Quiet)
    {
        $sl=(((get-view -viewtype VirtualMachine -filter @{"Name"=$vm.Name}).config).Annotation).split()[-1]
        $ses = New-PSSession -ComputerName $vm
        $contador=@();
        #netstat -an | findstr $server_monitorizacion | find /c /v ""
        $contador = Invoke-Command -Session $ses -ScriptBlock {netstat -an | findstr $server_monitorizacion}
        Remove-PSSession $ses
        if($contador.Count -gt 100){
            Write-Host $vm  es $sl y tiene $contador.Count conexiones a Solarwinds -ForegroundColor Red
        }
        else{
            Write-Host $vm  es $sl y tiene $contador.Count conexiones a Solarwinds -ForegroundColor Green
        }
    }
}
