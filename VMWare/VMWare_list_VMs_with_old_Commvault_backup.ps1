#este script solo devolvera las problematicas, si se quieren ver todas comentar las lineas 41-43
cls

$limite = (Get-Date).AddDays(-3) #consideramos que tener un backup hace 3 dias = OK y mas de 4 o no tener backup = NOK
$limite.ToString() #convertimos en string para luego poder compararla con otra fecha que tenemos de tipo string

#creamos la lista de VMs quitando aquellas que no necesitan tener backup
$lista_a_revisar=@();
$lista_a_revisar = Get-VM | Where {$_.Name -NotLike "*VARIV*"  `
                                -and $_.Name -NotLike "*VMRIV*"  `
                                -and $_.Name -NotLike "*_MigratedITIBlock*"  `
                                -and $_.Name -NotLike "*CORE*"  `
                                -and $_.Name -NotLike "*WLC*"  `
                                -and $_.Name -NotLike "*_replica*"  `
                                -and $_.Name -NotLike "*VANAC*"   `
                                -and $_.Name -NotLike "*VMCOM0*"  `
                                -and $_.Name -NotLike "*VMCM0*"  `
                                -and $_.Name -NotLike "*VMDC0*"  `
                                -and $_.Name -NotLike "GANVMSAP0*"  `
                                -and $_.Name -NotLike "*_Clone"  `
                                -and $_.Name -NotLike "*_clone"  `
                                -and $_.Name -NotLike "TMPL_*"  `
                                -and $_.Name -NotLike "IMCVM*"  `
                                -and $_.Name -NotLike "CHKVM*"  `
                                -and $_.Name -NotLike "CGZVM*"  `
                                -and $_.Name -NotLike "BNGVM*"  `
                                -and $_.Name -NotLike "CBTVMMES01"  `
                                -and $_.Name -NotLike "SPBVM*" } | Sort -Property Name #las que no hace falta backup o que sean Veeam


Foreach ($vm in $lista_a_revisar){

    $nombre = $vm.name
    $backup_commvault = (Get-VM -Name $nombre | Get-Annotation -Name 'Backup Status').Value #Commvault escribe en esta etiqueta asi sabremos que es un backup de Commvault
    if($backup_commvault){
        $fecha_ultimo_backup = (Get-VM -Name $nombre | Get-Annotation -Name 'Last Backup').Value
        if ($fecha_ultimo_backup){ #si hay backup
            if ($fecha_ultimo_backup -lt $limite){
                Write-Host $nombre "se hizo backup el" $fecha_ultimo_backup "y es" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Yellow
            }
            else{ ###comentar estas 3 lineas para que solo salga lo que hay que remediar
                Write-Host $nombre "se hizo backup el" $fecha_ultimo_backup "y es" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Green
            }
        }
    }
    else{ #si no hay ningun backup
        if((((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation) -cnotlike "*SL4"){
            Write-Host $nombre "NO TIENE BACKUP y es" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Red
        }
    }
}
