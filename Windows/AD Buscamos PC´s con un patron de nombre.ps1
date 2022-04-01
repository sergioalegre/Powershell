# Importamos el modulo de AD
import-module ActiveDirectory 

# Cogemos todos los ordenadores
$servers = Get-ADComputer -filter *

# genera un array, podemos ver el elemento numero 8 del array y ver sus propiedades
# $servers[8]

# Nos quedamos solo con las VMFIL
$servers | where {$_.Name -like "*VMFIL*"}


# El anterior exportado a csv
# $servers | where {$_.Name -like "*VMFIL*"} | Export-Csv .\sergio2.csv

#Get-DiskSpace -servers $servers | ConvertTo-Html -As Table  