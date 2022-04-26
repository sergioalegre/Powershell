#Objetivo: cambiar 2 parametros de las NIC de MIRRORING: https://kb.vmware.com/s/article/2039495

try{
    $MR = Get-NetAdapter | where Name -Like '*_MR*'
    $i=0
    foreach ($nic in $MR){
        Set-NetAdapterAdvancedProperty -Name $MR[$i].Name -DisplayName "Small Rx Buffers" -DisplayValue "4096"
        Set-NetAdapterAdvancedProperty -Name $MR[$i].Name -DisplayName "Rx Ring #1 Size"  -DisplayValue "2048"
        $i=$i+1
    }
    write-host "ALL WENT OK" -ForegroundColor Green
}catch{
    write-host "Something went wrong, make it manually" -ForegroundColor Red
}