###scope:
# - comprobar en todos los servidores a la vez si hay conexiones masivas en TIME_WAIT

### highlights: 
# - ejecución en paralelo en lugar de batch
# - pssesion
# - objetos array @{}
# - exportar a CSV

### requisitos:
# - powercli
# - conectividad firewall

###variables
$vCenter = ""
$TO=""
$FROM=""
$SUBJECT="Monitor TCP Connections"
$SMTPSERVER= ""

cls
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
cls
$lista=@();
$lista = Get-VM | Where {
                                 $_.Name -NotLike "*VMXXX*"  `
                             -and $_.Name -NotLike "*vCLS*"} | Sort -Property Name 

$jobs =@{} #array
$date= (Get-Date).ToString("yyyy/MM/dd HH:mm")
$salida=@()
Write-Host "Voy a consultar a "$lista.Count " servidores"
$contadorSleep=0

$lista | %{
    $job = Invoke-Command  -AsJob -ScriptBlock { $result=netstat -an |findstr TIME_WAIT;$result.count } -ComputerName $_.Name
    $jobs.Add($_.Name, $job)
}


While (($jobs.Values | where {($_.State -ne "Completed" -or $_.HasMoreData) -and  $_.State -ne "Failed" }) -and $contadorSleep -le 60 )
{
    $jobs.Values | where {$_.State -eq "Completed" -and $_.HasMoreData} | %{

        $receive=Receive-Job $_
        Write-host $date "," $_.Location "," $receive

        $entry=[PSCustomObject] @{
        "Date" = $date
        "Server" = $_.Location
        "TIME_WAIT" = $receive
        }
       $salida+=$entry
    }
    $contadorSleep+=1
    sleep 2
}


$salida | Export-Csv C:\Users\sergio.alegre\Desktop\MonitorizacionConexiones.csv -Append -Delimiter ","


if ($salida | where {$_."TIME_WAIT" -gt 2000}){

    $BODY= '<h2 style="color: #2e6c80;">Monitor TCP Connections</h2>'
    $BODY+= "<p>There are servers with more than 2000 TIME_WAIT connections</p>"

    $salida | where {$_."TIME_WAIT" -gt 2000} | % {
        $BODY+="<p>$($_.Server)</p>"
    }

    $BODY+= "<p>$($salida | where {$_."TIME_WAIT" -gt 2000})</p>"

    Send-MailMessage -to $TO -from $FROM -Subject $SUBJECT -SmtpServer $SMTPSERVER -BodyAsHtml -Body $BODY 
}
else{
"Sin correo"
}