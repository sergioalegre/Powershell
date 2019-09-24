#Instalar modulo necesario:
Install-Module -Name SqlServer

#Documentación:
https://docs.microsoft.com/en-us/powershell/module/sqlserver/get-sqlbackuphistory?view=sqlserver-ps

#Listar todos los backup historicos
Get-SqlBackupHistory -ServerInstance <server_name>

#Listar backups fulls
Get-SqlBackupHistory -ServerInstance <server_name> -BackupType Database
