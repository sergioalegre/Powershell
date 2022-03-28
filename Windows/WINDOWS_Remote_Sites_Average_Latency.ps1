###Objetivo: saber la latencia de sites remotos contra un collocation

###Notas: ejecutar desde una VM del collocation

###Highlights:
# - string split
# - string SubString
# - convertir de string a int

###variables:
$vCenter = "vCenterServer"

cls
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
cls

$lista= Get-VM | Where { $_.Name -Like "*VMDC0*"  } | Sort -Property Name
Write-Host "Total de plantas a consultar: " $lista.Count
foreach ($vm in $lista){
    if(Test-Connection -Computername $vm -BufferSize 16 -Count 1 -Quiet)
    {
        $resultado=@();
        $resultado = ping $vm | Select-Object -Last 1 #nos quedamos con el resumen del ping
        $matriz = $resultado -split "Average = " #dividimos por esta cadena del resumen para quedarnos solo con los ms
        $codigo_planta = $vm.name.SubString(0,3) #nos quedamos con las 3 primeras letras
        $ms=$matriz[1] -split"ms" #dividimos por esta cadena del para quedarnos solo con el número de ms
        $msNumero = [int]$ms[0] #convertir de string a int
        if($msNumero -gt 50){
            Write-Host $codigo_planta tiempo medio $msNumero ms -ForegroundColor Red
        }
        elseif($msNumero -gt 25){
            Write-Host $codigo_planta tiempo medio $msNumero ms -ForegroundColor Yellow
        }
        else{
            Write-Host $codigo_planta tiempo medio $msNumero ms -ForegroundColor Green
        }
    }
}
