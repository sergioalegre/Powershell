# Importamos el modulo de AD
import-module ActiveDirectory 

# Cogemos todos los computers
$computers = Get-ADComputer -filter *
$computers.Count

# genera un array, podemos ver el elemento numero 8 del array y ver sus propiedades
# $servers[8]

# Nos quedamos solo con las VMFIL
$servers = $computers | where {$_.Name -like "*VMFIL*"}

# El anterior exportado a csv
$servers | where {$_.Name -like "*VMFIL*"} | Export-Csv .\sergio2.csv

#cuantos servidores 'windows server' hay
$windows_servers = (Get-ADComputer -Filter 'operatingsystem -like "*Windows Server*" -and enabled -eq "true"').Name
$windows_servers.Count

#espacio en discos locales
foreach ($s in $servers){
    if(Test-Connection -Computername $s -BufferSize 16 -Count 1 -Quiet)
    {
        $ses = New-PSSession -ComputerName $s
        $contador = Invoke-Command -Session $ses -ScriptBlock {netstat -an | findstr $server_monitorizacion}
        Remove-PSSession $ses
    }
}
Get-WMIObject  -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}  `
    | Select-Object @{n="Unidad";e={($_.Name)}}, 
                    @{n="Etiqueta";e={($_.VolumeName)}}, 
                    @{n='Tamaño (GB)';e={"{0:n2}" -f ($_.size/1gb)}}, 
                    @{n='Libre (GB)';e={"{0:n2}" -f ($_.freespace/1gb)}}, 
                    @{n='% Libre';e={"{0:n2}" -f ($_.freespace/$_.size*100)}}