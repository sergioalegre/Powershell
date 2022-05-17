###Nota: Este script busca VMs cuyo espacio en vmware difiera en al menos 500Gb del espacio en windows. Si la reclamacion y el unmap no funciona un apagado de los servers ha demostrado ser efectivo
###Nota: bug conocido: cuenta el espacio de un disco usb como espacio de la VM y no se como evitarlo


### Highlights: 
### - $ErrorActionPreference= 'silentlycontinue': para que no salgan errores en el output

cls
$vCenter = "GANSVC01"
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
$ErrorActionPreference= 'silentlycontinue'
cls

$lista= Get-VM | Where { $_.Name -Like "*VMFIL0*" -or $_.Name -Like "*VMVIS0*"  } | Sort -Property Name
Write-Host "How many FIL/VIS servers we have: " $lista.Count

$lista_amarilla = $lista_roja = @();

foreach ($vm in $lista){
    if(Test-Connection -Computername $vm -BufferSize 16 -Count 1 -Quiet){
        
        #espacio que dice VMWARE
        $espacio_vmware = Get-VM $vm.Name | select UsedSpaceGB
        $espacio_vmware=[int]$espacio_vmware.UsedSpaceGB #quitar los decimales



        #espacio que dice WINDOWS
        $ses = New-PSSession -ComputerName $vm.Name
        $contador = Invoke-Command -Session $ses -ScriptBlock {Get-WmiObject -Class Win32_LogicalDisk |
            Select-Object -Property DeviceID, VolumeName, 
            @{Label='Libre (Gb)'; expression={($_.FreeSpace/1GB).ToString('F2')}},
            @{Label='Provisionado (Gb)'; expression={($_.Size/1GB).ToString('F2')}},
            @{Label='Usado (Gb)'; expression={(($_.Size/1GB)-($_.FreeSpace/1GB)).ToString('F2')}}|ft} #usado es Provisionado - Libre # |ft es para el formato de tabla
        $contador2 = Invoke-Command -Session $ses -ScriptBlock {Get-WmiObject -Class Win32_LogicalDisk |
            Select-Object -Property @{Label='Real'; expression={(($_.Size/1GB)-($_.FreeSpace/1GB)).ToString('F2')}}}
        
        #suma de espacio real de los distintos discos
        $espacio_windows=0
        foreach ($i in $contador2.Real){
            $espacio_windows = $espacio_windows + $i
        }
        $espacio_windows=[int]$espacio_windows #quitar los decimales
        Remove-PSSession $ses

        $diferencia=$espacio_vmware-$espacio_windows

        if($diferencia -gt 500){
            $lista_roja = $lista_roja + $vm.name +"tiene"+ $espacio_vmware + "Gb provisionado y usa" + $espacio_windows +"Gb usados, Diferencia:" + $diferencia + "Gb`n"
            write-host $vm.Name "Vmware:" $espacio_vmware "Windows:" $espacio_windows "- Diferencia" $diferencia "Gb" -ForegroundColor Red
            continue
        }
        else {
            write-host $vm.Name "Vmware:" $espacio_vmware "Windows;" $espacio_windows  "- Diferencia" $diferencia "Gb" -ForegroundColor Green
        }
    }
}

##Resumen
Write-Host "`nRESUME`n"
Write-Host "VMs con mas de 500Gb de diferencia:`n" $lista_roja -ForegroundColor Red