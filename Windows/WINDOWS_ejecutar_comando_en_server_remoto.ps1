#Nota: solo funciona si hay comunicacion no bloqueada por firewall

#Highlights: invocar comando remoto

cls
$localhost = $dato = Invoke-Command -ScriptBlock {hostname}
Write-Host "Estamos en" $localhost
$remote_host="<remote_host_here>"
$ses = New-PSSession -ComputerName $remote_host
$dato = Invoke-Command -Session $ses -ScriptBlock {hostname}
Remove-PSSession $ses
Write-Host $vm tiene de hostname $dato