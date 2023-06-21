<#
Creates user 'ReportBLD' into multiple SQL instances (which have a common name pattern). This user will have RO access to an specific database
#>
Import-Module SqlServer

$inventoryInstance = "instanciaSQLconInventario,1433"
$inventoryDatabase = "inventarioSQLs"
$secPasswd = Get-Content C:\PS_statusBBDD\passwords\password.txt | ConvertTo-SecureString -Key (Get-Content C:\PS_statusBBDD\passwords\aes.key)
$cred = New-Object System.Management.Automation.PSCredential ("usuario_con_permisos_acceso_a_las_instancias", $secPasswd)

$instances = Invoke-Sqlcmd -ServerInstance $inventoryInstance `
    -Database $inventoryDatabase `
    -Query "SELECT [Database_Status].[Instance_Name]
      ,[Database_Status].[Database_Name]
	  ,[Server].[Instance_Port]
    FROM [Database_Status] RIGHT JOIN [Server] 
    ON [Database_Status].[Instance_Name] = [Server].[Instance_Name]
    WHERE 
    ([Database_Status].[Instance_Name] LIKE '%PATRON_NOMBRE_BASE_DATOS%' 
	AND [Database_Status].[Database_Name] LIKE '%patron_nombre_base_datos%' 
    AND [Database_Status].[Database_Name] NOT LIKE '%nointeresa1%'
    AND [Database_Status].[Database_Name] NOT LIKE '%nointeresa2%'
    AND [Database_Status].[Database_Name] NOT LIKE '%nointeresa3%');"`
    -Credential $cred

foreach ($instance in $instances) {
    $instancePort = $instance.Instance_Port
    if ($instancePort -eq [System.DBNull]::Value) {
        $instancePort = 1433
    }
    $insConnectionString = $instance.Instance_Name + ',' + $instancePort
    
    $connection = Get-SqlInstance -ServerInstance $insConnectionString -Credential $onpremiseCred -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "Connection established with $($instance.Instance_Name)\$($instance.Database_Name),$($instancePort)" -ForegroundColor Green
        $query = Invoke-Sqlcmd -ServerInstance $insConnectionString `
            -Database $instance.Database_Name `
            -Query "USE [master]
            GO
            CREATE LOGIN [usuarioRO] WITH PASSWORD=N'contrasenia_usuarioRO', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
            GO
            USE [$($instance.Database_Name)]
            GO
            CREATE USER [usuarioRO] FOR LOGIN [usuarioRO]
            GO
            USE [$($instance.Database_Name)]
            GO
            EXEC sp_addrolemember N'db_datareader', N'usuarioRO'
            GO" `
            -Credential $cred

        $query
    } 
    else {
        Write-Host "Connection error at $($instance.Instance_Name)\$($instance.Database_Name),$($instancePort)" -ForegroundColor Red       
    }
}