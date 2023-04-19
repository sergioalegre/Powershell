#Scope: Buscar Clusters con un nodo caido (sin responder) hace 3 o mas días y enviar un email
#Created by: Sergio Alegre @ Mar 2023

### Debug:
#$ErrorActionPreference= 'silentlycontinue'

### Highlights:
# Barra progreso

#variables
$vCenter = "<vCENTER_IP>"

cls

Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter

$lista_clusters= Get-Cluster
$resumen = @() #lista de sitios en degradado a revisar
$iteracion=0  #un contador para la barra de progreso


Foreach ($cluster in $lista_clusters){

    $iteracion=$iteracion+1
    $nombre = $cluster.name
    Write-Progress -Activity "Checking " -CurrentOperation $nombre -percentcomplete ($iteracion/$lista_clusters.Count*100) #barra de progreso

    $miembros = @()
    $miembros = Get-Cluster $cluster | Get-VMHost
    if ($miembros.Count -lt 2){
        Write-Host "En" $cluster.Name "hay:" $miembros.Count "miembros" -ForegroundColor Red
        $resume+=$cluster.Name
    }
    else
    {
        Write-Host "En" $cluster.Name "hay:" $miembros.Count "miembros" -ForegroundColor Green
    }
}

cls
Write-Host "-+-+-+-+-SITES WITH DEGRADED STATUS+-+-+-+-+-+-+"
Write-Host $resumen
