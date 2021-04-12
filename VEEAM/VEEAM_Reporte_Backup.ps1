<# Este script dice a cada coordinador las VMs con Backup y Réplica en su planta por email#>
#variables:
# VEEAM_SERVER_NAME = hostname del Veeam server
# DOMINIO
# responsable_veeam@dominio.com



#Abrimos sesion en VEEAM SERVER
    $contrasena = Get-Content "E:\Scripts\Veeam\contrasena_gan_service_BEM.txt"
    $pw = convertto-securestring -AsPlainText -Force -String $contrasena
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "DOMINIO\gan_service_BEM",$pw
    $sesion = New-PSSession VEEAM_SERVER_NAME -credential $cred


#Ejecutamos comandos en la sesion abierta
    Invoke-Command -Session $sesion -ScriptBlock {

        Add-PsSnapIn VeeamPSSnapIn #invocamos cmdlets de Veeam

        $trabajos_backup = Get-VBRJob | ?{$_.JobType -eq "Backup"}  | sort -property Name
        $trabajos_replica = Get-VBRJob | ?{$_.JobType -eq "Replica"}  | sort -property Name

        #Propiedades comunues email
        $from = "reporte_veeam@dominio.com"
        $smtpServer = "ip.ip.ip.ip" #IP del smtp server
        $to = "responsable_veeam@dominio.com"
        #$to += " ," + $job.Name.Substring(0,3) + "_sg_mon@dominio.com"
        $bodycomun += "Remember everytime you request a new critical VM, to ask IT department to include it too on Backup&Replica jobs.<br><br>
                    
                       <b>What is the difference between backup & replica:</b><br>
                       Replica save the state of the VM in the last 24h, each 2h.<br>
                       Backup is long term backup, last 14hours, 1 per day.<br>
                       Replica recovery time is less."
    
        #BACKUP
        Write-Host "TAREAS DE BACKUP`n" -ForegroundColor Green ;
        foreach($job in $trabajos_backup) {
        
            #a consola
            Write-Host $job.Name -ForegroundColor Green ;
            $job.GetObjectsInJob() | foreach {
                Write-Host "`t" $_.Name  -ForegroundColor Yellow
            }
        
            #a email
            $body = "Hi, this is an automatic monthly reminder about your backed up VMs at <b>" + $job.Name.Substring(0,3) + "</b> please dont respond to this email. If you have any doubt about his content let <a mailto=responsable_veeam@dominio.com>responsable_veeam@dominio.com</a> know.<br><br>"
            $body += "Current VM(s) with backup in your enviroment are:<br><br>"
            $body += $job.GetObjectsInJob() | foreach {"<b style=color:red>"+$_.Name+"</b><br>"}
            $body += "<b><br>Why this email is important:</b><br>"
            $body += "Please, refer to <a href=http://URL_HERE>DOCUMENTACION</a> before asking any doubt.<br><br>"
            $body += "<b>What do you have to do:</b><br>"
            $body += "You must read carefully the VM list in <b style=color:red>red</b>. VM listed has backup, VMs not listed dont have it, if you consider there is any other important VM in your environment which is not listed, create a helpdesk ticket to request it.<br>"
            $body += $bodycomun


            $subject = "REPORTE VEEAM: VMs with BACKUP at " + $job.Name.Substring(0,3)
            Send-MailMessage -From $from -Subject $subject -SmtpServer $smtpServer -To $to -Body $body -BodyAsHtml
        }


        sleep 1
        Write-Host "`n-.-.-.-.-.-.-.-.-.-.-.-.-.`n" -ForegroundColor Green ;

        #REPLICA
        Write-Host "TAREAS DE REPLICA`n" -ForegroundColor Green ;
        foreach($job in $trabajos_replica) {
            #a consola
            Write-Host $job.Name -ForegroundColor Green ;
            $job.GetObjectsInJob() | foreach {
                Write-Host "`t" $_.Name  -ForegroundColor Yellow
            }
        
            #a email
            $body = "Hi, this is an automatic monthly reminder about your replicated VMs at <b>" + $job.Name.Substring(0,3) + "</b> please dont respond to this email. If you have any doubt about his content let <a mailto=responsable_veeam@dominio.com>responsable_veeam@dominio.com</a> know.<br><br>"
            $body += "Current VM(s) with backup in your enviroment are:<br><br>"
            $body += $job.GetObjectsInJob() | foreach {"<b style=color:red>"+$_.Name+"</b><br>"}
            $body += "<b><br>Why this email is important:</b><br>"
            $body += "Please, refer to <a href=http://URL_HERE>DOCUMENTACION</a> before asking any doubt.<br><br>"
            $body += "<b>What do you have to do:</b><br>"
            $body += "You must read carefully the VM list in <b style=color:red>red</b>. VM listed has replica, VMs not listed dont have it, if you consider there is any other important VM in your environment which is not listed, create a helpdesk ticket to request it.<br>"
            $body += $bodycomun


            $subject = "REPORTE VEEAM: VMs with REPLICATION at " + $job.Name.Substring(0,3)
            Send-MailMessage -From $from -Subject $subject -SmtpServer $smtpServer -To $to -Body $body -BodyAsHtml
        }
    }

    Exit-PSSession
