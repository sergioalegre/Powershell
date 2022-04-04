###Nota: Este script busca todos los VMFIL servers y te dice el espacio provisionado y el real gastado
###Nota: bug conocido: cuenta el espacio de un disco usb como espacio de la VM y no se como evitarlo


### Highlights:
### - $ErrorActionPreference= 'silentlycontinue': para que no salgan errores en el output


### Variables:
$vCenter = "<vCenter-Server>"


cls
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
$ErrorActionPreference= 'silentlycontinue'
cls

$lista= Get-VM | Where { $_.Name -Like "*VMFIL0*"  } | Sort -Property Name
$lista_amarilla = $lista_roja = @();

Write-Host "How many FIL servers we have: " $lista.Count
foreach ($vm in $lista){
    if(Test-Connection -Computername $vm -BufferSize 16 -Count 1 -Quiet){

        #espacio provisionado VMWARE
        $espacio = (Get-HardDisk -VM $vm.Name | Measure-Object -Sum CapacityGB).Sum
        $espacio=[int]$espacio #quitar los decimales


        #espacio real usado WINDOWS
        $ses = New-PSSession -ComputerName $vm.Name
        $contador = Invoke-Command -Session $ses -ScriptBlock {Get-WmiObject -Class Win32_LogicalDisk |
            Select-Object -Property DeviceID, VolumeName,
            @{Label='Libre (Gb)'; expression={($_.FreeSpace/1GB).ToString('F2')}},
            @{Label='Provisionado (Gb)'; expression={($_.Size/1GB).ToString('F2')}},
            @{Label='Usado (Gb)'; expression={(($_.Size/1GB)-($_.FreeSpace/1GB)).ToString('F2')}}|ft} #usado es Provisionado - Libre # |ft es para el formato de tabla
        $contador2 = Invoke-Command -Session $ses -ScriptBlock {Get-WmiObject -Class Win32_LogicalDisk |
            Select-Object -Property @{Label='Real'; expression={(($_.Size/1GB)-($_.FreeSpace/1GB)).ToString('F2')}}}


        #suma de espacio real de los distintos discos
        $total=0
        foreach ($i in $contador2.Real){
            $total = $total + $i
        }
        #$contador #ver el provisionado el libre y el usado
        #$contador2 #ver solo el usado
        #$total #el total de espacio usado real de la VM
        Remove-PSSession $ses

        if($total -gt 4000){ #mas de 4Tb
            $lista_roja = $lista_roja + $vm.name +"tiene"+ $espacio + "Gb provisionado y" + $total +"Gb usados`n"
            Write-Host $vm.name tiene $espacio Gb provisionado y $total Gb usados -ForegroundColor Red
            continue
        }
        if($total -gt 2000) { #mas de 2Tb
            $lista_amarilla = $lista_amarilla + $vm.name +"tiene"+ $espacio + "Gb provisionado y" + $total +"Gb usados`n"
            Write-Host $vm.name tiene $espacio Gb provisionado y $total Gb usados -ForegroundColor Yellow
            continue
        }
        else { #menos de 2Tb
            Write-Host $vm.name tiene $espacio Gb provisionado y $total Gb usados -ForegroundColor Green
        }
    }
}

##Resumen
Write-Host "`nRESUME`n"
Write-Host "2 a 4 Tb:`n" $lista_amarilla -ForegroundColor Yellow
Write-Host "4Tb+:`n" $lista_roja -ForegroundColor Red
