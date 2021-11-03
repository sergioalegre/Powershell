###PLANNING:
# if there is backup
# 	if SL4 -> green
# 	if not SL4 and VM running
# 		if backup outdated -> yellow
# 		if backup on date -> green
# if there is no backup
# 	if SL4 -> green
# 	if not SL4 y VM running -> red
#variables

$vCenter = "your_vcenter_DNS"

#highlights:
# - string to datetime conversion
# - string lenght reduce
# - try/catch

cls
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
cls

$limite = (get-date).AddDays(-3) #we consider a good backup if 3 days or newer. 4 days or more = no backup
$lista_a_revisar=@();
$lista_a_revisar = Get-VM | Where {
                                 # always excluded / no vm backup, only config backup / temporally VM / still on Veeam
                                 $_.Name -NotLike "*exlude_pattern1*"  `
                            -and $_.Name -NotLike "*exlude_pattern2*"  `
                            -and $_.Name -NotLike "exlude_pattern3*" } | Sort -Property Name


$lista_amarilla = $lista_roja = @();

Foreach ($vm in $lista_a_revisar){
    $nombre = $vm.name #"CTTVMMYQS01"
    $estado = Get-VMGuest -VM $nombre | Select State
    if($estado.State -notcontains "NotRunning"){ #si la vm esta encendida
        Write-Host "checking " $nombre
        $backup_commvault = (Get-VM -Name $nombre | Get-Annotation -Name 'Backup Status').Value #Commvault escribe en esta etiqueta asi sabremos que es un backup de Commvault
        if($backup_commvault){ #if it has backup
            $fecha_ultimo_backup = (Get-VM -Name $nombre | Get-Annotation -Name 'Last Backup').Value
            if((((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation) -like "*SL4"){ #si hay backup y es SL4
                Write-Host $nombre "old backup but is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Green
            }
            else{ #si hay backup y no es SL4
                $fecha_ultimo_backup = $fecha_ultimo_backup -split '\s+' #separamos la cadena por espacios
                $fecha_ultimo_backup = $fecha_ultimo_backup[0] #nos quedamos con el primer elemento que es el que tiene la fecha
                #$fecha_ultimo_backup=$fecha_ultimo_backup.Substring(0,10) #quedarnos solo con los primeros 10 caracteres
                if($fecha_ultimo_backup.Length -eq 9){ #si la fecha tiene 9 digitos
                    try {
                        $fecha_ultimo_backup=[datetime]::ParseExact($fecha_ultimo_backup, 'M/dd/yyyy', $null) #convertir de string a datetime
                    }
                    catch{
                        $fecha_ultimo_backup=[datetime]::ParseExact($fecha_ultimo_backup, 'MM/d/yyyy', $null) #convertir de string a datetime
                    }
                }
                else{ #si la fecha tiene 10 digitos
                    $fecha_ultimo_backup=[datetime]::ParseExact($fecha_ultimo_backup, 'MM/dd/yyyy', $null) #convertir de string a datetime
                }
                try {#si lo puedo convertir es que no esta desactualizado

                    if ($fecha_ultimo_backup -lt $limite){ # si el backup es viejo
                        $lista_amarilla = $lista_amarilla + $nombre
                        Write-Host $nombre "backup OUTDATED" $fecha_ultimo_backup "is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Yellow

                    }
                    else{ ###comentar estas 3 lineas para que solo salga lo que hay que remediar
                        Write-Host $nombre "backed up OK at" $fecha_ultimo_backup "is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Green
                    }
                }
                catch {
                    $lista_roja = $lista_roja + $nombre
                    Write-Host $nombre "has OUTDATED backup " $fecha_ultimo_backup " and is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Red
                }
            }
        }
        else{ #if there is no backup
            if((((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation) -cnotlike "*SL4"){
                $lista_roja = $lista_roja + $nombre
                Write-Host $nombre "has NO BACKUP and is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Red
            }
            else{
                Write-Host $nombre "no backup but is" (((get-view -viewtype VirtualMachine -filter @{"Name"=$nombre}).config).Annotation).split()[-1] -ForegroundColor Green
            }
        }
    }
    else{ #si la VM esta apagada
        Write-Host "checking " $nombre
        Write-Host $nombre "is powered down"  -ForegroundColor Green
    }
}
Write-Host "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
Write-Host "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
Write-Host "RESUME:"
Write-Host "No backups:" $lista_roja -ForegroundColor Red
Write-Host "Outdated backups:" $lista_amarilla -ForegroundColor Yellow

#reporte HTML
$htmlCode=""
$htmlCode += '<html>'
$htmlCode += '<head>'
$htmlCode += '</head>'
$htmlCode += '<body>'
# Table for lista_roja
$htmlCode += '<br><br>'
$htmlCode += '<table border="1" style="width:90%">'
$htmlCode += '<tr style="color: #FFFFFF; background: #FF0000;">'
$htmlCode += '<td colspan="9" align="center"><b>NO BACKUP (VM up & is not SL4): '+$lista_roja.Count+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<table border="1" style="width:90%">'
$htmlCode += '<tr style="color: #FFFFFF; background: #FF0000;">'
$htmlCode += '<td colspan="9" align="center"><b>Common issues: VM is new, VM should be excluded from backup</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<tr style="color: #FFFFFF; background: #FF0000;">'
$htmlCode += '<td colspan="9" align="center">'+$lista_roja+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += '</table>'
# Table for lista_amarilla
$htmlCode += '<br><br>'
$htmlCode += '<table border="1" style="width:90%">'
$htmlCode += '<tr style="color: #FFFF00; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center"><b>OUTDATED BACKUP: '+$lista_amarilla.Count+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<tr style="color: #FFFF00; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center"><b>Common issues: if a single VM can be a punctual problem, if all VMs from same site: chech MediaAgent is disabled</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<tr style="color: #FFFF00; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center">'+$lista_amarilla+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += '</table>'
$htmlCode += '</body>'
$htmlCode += '<html>'

# Enviar reporte x email
$from = "report_server@domain.com"
$subject = "report_server - VMs without backup or outdated backup"
$smtpServer = "ip.ip.ip.ip"
#$recipients = "aaa@domain.com","bbb@domain.com","ccc@domain.com"
$recipients = "aaa@domain.com"
Send-MailMessage -From $from -Subject $subject -SmtpServer $smtpServer -To $recipients -Body $htmlCode -BodyAsHtml

# Escribir a log
$fichero = 'E:\Scripts\VMware\results\VMs_without_or_outdated_backup.html'
New-Item -Path $fichero -ItemType File
Set-Content $fichero $htmlCode
$fecha=$(Get-Date -UFormat "%Y%m%d")
$nombre_nuevo = $fecha + "_VMs_without_or_outdated_backup.html"
rename-item $fichero -NewName $nombre_nuevo

# dejar ultimos 20 logs
$numero_backups=( Get-ChildItem "E:\Scripts\VMware\results\" ).Count
if($numero_backups -gt 10){
    $path = "E:\Scripts\VMware\results\"
    $backups_mas_antiguos = Get-ChildItem -Path $path | Sort-Object LastAccessTime -Descending | Select-Object -First 20
    Remove-Item $backups_mas_antiguos
}
