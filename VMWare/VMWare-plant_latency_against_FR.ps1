### Objetivo: saber la latencia de las sites remotos contra un collocation

### Notas: ejecutar desde alguna VM de FR4

### Debug:
$ErrorActionPreference= 'silentlycontinue'

### Highlights:
# - string split
# - string SubString
# - convertir de string a int
# - Parent folder de la VM en VMWare
# - Funciones

### Variables
$vCenter = <vCenter>

cls
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
cls

function pais($vm) { #devuelve el pais de una VM
    $parent.Name =""
    Get-VM $vm.Name | Get-View | %{
      $current = Get-View $_.Parent
      $path = $_.Name
      do {
        $parent = $current
        if($parent.Name -ne "vm"){$path =  $parent.Name + "\" + $path} #hay que omitir vm porque lo mete vmware siempre
	    $current = Get-View $current.Parent
      } while ($current.Parent -ne $null)
    }
    $parent.Name #Carpeta raiz en nuestro caso el pais
    #$path #ruta completa a la VM
}

$lista_verde, $lista_amarilla, $lista_roja = $lista_FR = $lista_DA = @();
$lista= Get-VM | Where { $_.Name -Like "*VMDC0*" -and $_.Name -notlike "GAN*"  -and $_.Name -notlike "FR*"} | Sort -Property Name
#$lista_FR = @("XXXVMDC0y", )
#$lista_DA = @("XXXVMDC0y", )
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
            $lista_roja = $lista_roja + $codigo_planta +" ,"
        }
        elseif($msNumero -gt 25){
            $pais_vm = ""
            $pais_vm = pais($vm)
            Write-Host $codigo_planta tiempo medio $msNumero ms -ForegroundColor Yellow
            $lista_amarilla = $lista_amarilla + $codigo_planta + " " + $pais_vm + "`n"
        }
        else{
            $pais_vm = ""
            $pais_vm = pais($vm)
            Write-Host $codigo_planta "en" $pais_vm "tiempo medio" $msNumero ms -ForegroundColor Green
            $lista_verde = $lista_verde + $codigo_planta + " " + $pais_vm + "`n"
        }
    }
}

#Resumen
Write-Host "`nRESUME`n"
Write-Host $lista_roja -ForegroundColor Red
Write-Host $lista_amarilla -ForegroundColor Yellow
Write-Host $lista_verde -ForegroundColor Green