#Know how many VMs vCenter have of each criticity level
#highlight: progressbar
#highlight: clear
#highlight: salto de linea

#variables
$vCenter = <your_vCenterIP_or_DNSname>

cls

Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter

$lista_a_revisar=@();
$lista_a_revisar = Get-VM | Where { $_.Name -NotLike "*vCLS*" -and $_.Name -NotLike "*_replica*"} | Sort -Property Name

$SL1=$SL2=$SL3=$SL4=$numero_VM=0

Foreach ($vm in $lista_a_revisar){
 
    $numero_VM=$numero_VM+1 #un contador para la barra de progreso
    $nombre = $vm.name
    $SL = (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1]
    if($SL -eq "SL1"){ $SL1=$SL1+1}
    if($SL -eq "SL2"){ $SL2=$SL2+1}
    if($SL -eq "SL3"){ $SL3=$SL3+1}
    if($SL -eq "SL4"){ $SL4=$SL4+1}
    Write-Progress -Activity "Checking SL" -CurrentOperation $nombre -percentcomplete ($numero_VM/$lista_a_revisar.Count*100) #barra de progreso
    
    clear #con cls siempre borraria la pantalla
    Write-Host "`n`n`n`n`n`n" #salto de linea
    Write-Host "SL1 " $SL1 -ForegroundColor Red
    Write-Host "SL2 " $SL2 -ForegroundColor Magenta
    Write-Host "SL3 " $SL3 -ForegroundColor Yellow
    Write-Host "SL4 " $SL4 -ForegroundColor Green
}

