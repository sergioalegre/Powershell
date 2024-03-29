#Borra todos los BAD ADDRESS DE UN SCOPE DE UN DHCP SERVER
cls
$leases=netsh dhcp server 172.25.185.37 scope 172.25.185.0 show clients
Write-Host ("IP leased: "+$leases.count)
$contToDelete=0

#Calculamos las reservar incorrectas
foreach ($lease in $leases)
{
    $leaseMAC=((($lease -split ("- "))[2] -split (" "))[0]).Trim() #???
    $leaseIP=(($lease -split ("- "))[0]).Trim() #???
    if (($leaseMAC.Length -eq 11) -and ($leaseIP -like "172.25.185.*")) { $contToDelete++ }
}
Write-Host ("Leases to be deleted: "+$contToDelete)

#Liberamos las resevas
foreach ($lease in $leases)
{
    $leaseMAC=((($lease -split ("- "))[2] -split (" "))[0]).Trim()
    $leaseIP=(($lease -split ("- "))[0]).Trim()
    if (($leaseMAC.Length -eq 11) -and ($leaseIP -like "172.25.185.*")) 
    { 
        Write-Host ("Releasing IP "+$leaseIP+" for MAC address "+$leaseMAC)
        netsh dhcp server 172.25.185.37 scope 172.25.185.0 delete lease $leaseIP | Out-Null
    }
}