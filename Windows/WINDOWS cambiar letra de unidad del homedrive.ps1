#Poner S: como HomeDrive a todos los usuarios de una OU concreta

#MOSTRAR COMO ESTA ACTUALMENTE:
Get-ADUser -SearchBase "OU=users,OU=burgos,DC=midominio,DC=com" -Filter * -Properties name, homedrive, homedirectory | select name,homedrive,homedirectory


#EJECUTAR EL CAMBIO:
#Get-ADUser -SearchBase "OU=users,OU=burgos,DC=midominio,DC=com" -Filter * | SET-ADUSER -HomeDrive 'S:'