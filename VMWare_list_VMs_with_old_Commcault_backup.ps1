#This script will:
  #get all VMs and exclude VMs we know need no backup
  #will check VM per VM if 'Backup Status' field has any data (a clue Commvault did backup once in the lifetime
  #if there was a commvault in 'Backup Status' field, job will check VM per VM if 'Last Backup' is at least 3 days older.

cls
$limite = (Get-Date).AddDays(-3) #consideramos que tener un backup hace 3 dias = OK y mas de 4 o no tener backup = NOK
$limite.ToString() #convertimos en string para luego poder compararla con otra fecha que tenemos de tipo string

#creamos la lista de VMs quitando aquellas que no necesitan tener backup
$lista_a_revisar=@();
$lista_a_revisar = Get-VM | Where {$_.Name -NotLike "*VARIV*" -and $_.Name -NotLike "*VMRIV*" -and $_.Name -NotLike "*_MigratedITIBlock*" -and $_.Name -NotLike "*CORE0*" -and $_.Name -NotLike "*WLC*" -and $_.Name -NotLike "*_replica*" -and $_.Name -NotLike "*VANAC*"  -and $_.Name -NotLike "*VMCOM0*" -and $_.Name -NotLike "*VMCM0*" -and $_.Name -NotLike "*VMDC0*"} | Sort -Property Name


Foreach ($vm in $lista_a_revisar){
 
    $backup_commvault = (Get-VM -Name $vm.name | Get-Annotation -Name 'Backup Status').Value #Commvault escribe en esta etiqueta asi sabremos que es un backup de Commvault
    if($backup_commvault){
        $fecha_ultimo_backup = (Get-VM -Name $vm.name | Get-Annotation -Name 'Last Backup').Value
        if ($fecha_ultimo_backup){ #si hay backup
            if ($fecha_ultimo_backup -lt $limite){
                $nombre = $vm.name
                Write-Host $nombre "se hizo backup el" $fecha_ultimo_backup -ForegroundColor Green
            }
        }
        else{ #si no hay ningun backup
            Write-Host $nombre "NO TIENE BACKUP" -ForegroundColor Yellow
        }
    }
}
