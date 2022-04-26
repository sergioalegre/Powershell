### Objetivo: Buscar en todos los sites alertas de latencia Datacore en la última semana.

### Debug:
#$ErrorActionPreference= 'silentlycontinue'

### Highlights:
# -

# Registro de Cmdlets de Datacore
cls
Import-Module '\\SERVER\c$\Program Files\DataCore\SANsymphony\DataCore.Executive.Cmdlets.dll' -WarningAction silentlyContinue

# Variables
$DCListPlant = Get-Content '\\SERVER\E$\DataCoreSites.txt'  # Ruta al archivo con la lista de las plantas con Datacore
$lista_roja = $lista_amarilla = @();
$hoy=(GET-DATE)


ForEach ($DCGroup in ($DCListPlant)) {
    #Sacar la password
    $DCName = $DCGroup + "CORE01"
    $DCName02=$DCName.Substring(0,$DCName.Length-1)+"2"
    $DCIPServer = nslookup $DCName
    $DCIPPassword = $DCIPServer[4].split(".")[2]
    $DCNamePassword = $DCName.Substring(0,3)
    $DCPassword = $DCNamePassword + $DCIPPassword + "datacore"
    $DcsPassword = $DCPassword | ConvertTo-SecureString -AsPlainText -Force

    $DCUserName = 'Administrator'
    $DcsCredItem = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $DCUserName, $DcsPassword

    # Conexion a un DataCore
    Connect-DcsServer -Server $DCName -Credential $DcsCredItem -Connection $DCName

    $alertas =@();
    $alertas = Get-DcsAlert |  Select-Object -Property MessageText, TimeStamp -First 10 #Últimas 10 alertas
    if($alertas.count -eq 0)
    {
        Write-Host "Alerta" $DCName "no tiene alertas asi que log database is paused" -ForegroundColor Yellow
        $lista_amarilla = $lista_amarilla + $DCName
    }
    else #si hay alertas
    {
        foreach($alerta in $alertas){
            $diferencia= $hoy – $alerta.Timestamp
            if($diferencia.Days -le 7)
            {
                if($alerta.MessageText -like "*is >= 30s") # The I/O latency of Virtual Disk SITE from SITE is >= 30s este es el tipo de mensaje a detectar
                {
                    write-host "LATENCIAS en" $DCName "hace" $diferencia.Days "dias" -ForegroundColor Red
                    write-host $alerta.MessageText $alerta.Timestamp -ForegroundColor Gray
                    $lista_roja = $lista_roja + $DCName + "hace" + $diferencia.Days + "dias`n"
                    break
                }
                else
                {
                    write-host "no hay latencias en" $DCName ":" $alerta -ForegroundColor Green
                }
            }
            else { write-host "no hay alertas en" $DCName "en la última semana" -ForegroundColor Green}
        }

    # Desconexion de DataCore
    Disconnect-DcsServer
    }
}

###RESUMEN
write-host "`n`n__________PLANTAS CON LATENCIA__________"
write-host $lista_roja -ForegroundColor Red
write-host "`n`n__________PLANTAS CON LOG PARADO__________"
write-host $lista_amarilla -ForegroundColor Yellow


###ENVIAR POR EMAIL
$htmlCode=""
$htmlCode += '<html>'
$htmlCode += '<head>'
$htmlCode += '</head>'
$htmlCode += '<body>'
# Table for lista_roja
$htmlCode += '<br><br>'
$htmlCode += '<table border="1" style="width:90%">'
$htmlCode += '<tr style="color: #FFFFFF; background: #FF0000;">'
$htmlCode += '<td colspan="9" align="center"><b>SITES WITH LATENCY: '+$lista_roja.Count+'</b></td>'
$htmlCode += '<tr style="color: #FFFFFF; background: #FF0000;">'
$htmlCode += '<td colspan="9" align="center"><b>The I/O latency of Virtual Disk XXX_XXXVMXXX0y from XXX is >= 30s</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<tr style="color: #FFFFFF; background: #FF0000;">'
$htmlCode += '<td colspan="9" align="center">'+$lista_roja+'</b></td>'
$htmlCode += '</tr></table>'
# Table for lista_amarilla
$htmlCode += '<br><br>'
$htmlCode += '<table border="1" style="width:90%">'
$htmlCode += '<tr style="color: #FFFF00; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center"><b>LOG BACKUP PAUSED: '+$lista_amarilla.Count+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<tr style="color: #FFFF00; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center"><b>A</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<tr style="color: #FFFF00; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center">'+$lista_amarilla+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += '<tr style="color: #FFFF00; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center"><br>'+$lista_amarilla_detalle+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += '</table>'

# Enviar reporte x email
$from = "GANVMPWS03@grupoantolin.com"
$subject = "GANVMPWS03 - Datacore latency or log issues detected"
$smtpServer = "172.25.120.140"
#$recipients = "infrasupport.ga@omega-peripherals.com","jesus.tamayo@grupoantolin.com","oscar.asuncion@grupoantolin.com","sergio.alegre@grupoantolin.com","Raul.hernando@grupoantolin.com"
$recipients = "sergio.alegre@grupoantolin.com"
Send-MailMessage -From $from -Subject $subject -SmtpServer $smtpServer -To $recipients -Body $htmlCode -BodyAsHtml
