Add-PsSnapIn VeeamPSSnapIn #invocamos cmdlets de Veeam

#variables
$plantas = "XXX","YYY","ZZZ"
$emisor="mi@email.com"
$receptor="destinatario@emial.com"
$PSEmailServer = "ip.ip.ip.ip"

foreach ($planta in $plantas){
    $trabajo = Get-VBRJob -Name *$planta*Backup*
    $body = "VMs with Backup at $planta plant are: " + (Get-VBRJobObject -Job $trabajo).Name + "`n`n" + "If there is a missing critical VM in this list, open ticket to helpdesk, asking DS-Systems team at HQ to add it into the backup and replica jobs"
    Send-MailMessage -From $emisor -To $receptor -Subject "Backup VMs list at $planta, please check" -Body "$body"
}