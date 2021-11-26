#Nota: solo funciona si hay comunicacion no bloqueada por firewall

### Highlights: 
### - invocar comando remoto mediante WMI
### - comprobar si el server esta levantado con Test-Connection

cls
$vCenter = "<you_vCenter>"
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
cls

$lista= Get-VM | Where { $_.Name -Like "*VMXXX0*"  } | Sort -Property Name
Write-Host "How many XXX servers we have and where: " $lista.Count
foreach ($vm in $lista){
    $sl=(((get-view -viewtype VirtualMachine -filter @{"Name"=$vm.Name}).config).Annotation).split()[-1]
    if($sl -notcontains "SL1"){
        Write-Host $vm.Name $sl -ForegroundColor Red
        if(Test-Connection -Computername $vm -BufferSize 16 -Count 1 -Quiet)
        {
            $BootTime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $vm | select @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
            Add-content "$vm;$BootTime" -path "C:\temp\LOG.log" 
        }
    } else {
        Write-Host $vm.Name $sl -ForegroundColor Green
    }
}