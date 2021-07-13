cls

$limite = (get-date).AddDays(-3).ToString("dd'/'MM'/'yyyy hh:mm:ss") #we consider a good backup if 3 days or newer. 4 days or more = no backup
$limite.ToString() #convertimos en string para luego poder compararla con otra fecha que tenemos de tipo string


$lista_a_revisar=@();
$lista_a_revisar = Get-VM | Where {
                                 # always excluded / no vm backup, only config backup / temporally VM / still on Veeam
                                 $_.Name -NotLike "*VARIV*"  `
                            -and $_.Name -NotLike "*VMRIV*"  `
                            -and $_.Name -NotLike "vCLS*"  `
                            -and $_.Name -NotLike "TMPL_*"  `
                            -and $_.Name -NotLike "TMPLT_*"  `
                            -and $_.Name -NotLike "*TEST*" } | Sort -Property Name


Foreach ($vm in $lista_a_revisar){
 
    $nombre = $vm.name
    Write-Host "checking " $nombre
    $backup_commvault = (Get-VM -Name $nombre | Get-Annotation -Name 'Backup Status').Value #Commvault escribe en esta etiqueta asi sabremos que es un backup de Commvault
    if($backup_commvault){ #if it has backup
        $fecha_ultimo_backup = (Get-VM -Name $nombre | Get-Annotation -Name 'Last Backup').Value
        if ($fecha_ultimo_backup){ #si hay backup
            if ($fecha_ultimo_backup -lt $limite){
                Write-Host $nombre "backed up at" $fecha_ultimo_backup "is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Yellow
            }
            else{ ###comentar estas 3 lineas para que solo salga lo que hay que remediar
                Write-Host $nombre "backed up at" $fecha_ultimo_backup "is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Green
            }
        }
    }
    else{ #if there is no backup
        if((((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation) -cnotlike "*SL4"){
            Write-Host $nombre "HAS NO BACKUP and is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Red
        }
        else{
            Write-Host $nombre "no backup but is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Green
        }
    }
}
