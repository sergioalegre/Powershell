### Objetivo: Buscar servers todos los discos MBR en todo el vCenter
### Nota: ejecutar desde GANVMTS31 para evitar problemas firewall. No funciona desde GANVMPWS03

### Highlights: 
# - 

### Debug:
# diskmgmt.msc
# $ErrorActionPreference= 'silentlycontinue'

### Variables:
$vCenter = "<vCenter>"


cls
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
cls

$lista= Get-VM | Where { $_.Name -Like "*VM*"  } | Sort -Property Name #para evitar los VA
$lista_roja = @();
i=0

Write-Host "Servers to check: " $lista.Count
foreach ($vm in $lista){
    if(Test-Connection -Computername $vm -BufferSize 16 -Count 1 -Quiet){
        
        $ses = New-PSSession -ComputerName $vm.Name
        
        $partitions = Invoke-Command -Session $ses -ScriptBlock {Get-Disk | Select-Object PSComputerName, Number, PartitionStyle}
        if ($partitions.PartitionStyle[1] -eq "MBR" -or $partitions.PartitionStyle[2] -eq "MBR" -or $partitions.PartitionStyle[3] -eq "MBR")
        {
            Write-Host $vm.name " tiene al menos un disco MBR" -ForegroundColor Red
            $lista_roja = $lista_roja + $vm.name + "`n"
            $i=$i+1
            continue
        }
        else {Write-Host $vm.name " NO tiene ningun disco MBR" -ForegroundColor Green}
        
        Remove-PSSession $ses
    }
}

#Resumen
Write-Host "`nRESUME`n"
Write-Host "Encontrados " $i " servers`n" -ForegroundColor Red
Write-Host $lista_roja -ForegroundColor Red
