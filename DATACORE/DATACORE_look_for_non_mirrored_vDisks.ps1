#Scope: Buscar vDisks que no esten en mirrored
#Created by: Sergio Alegre @ July 2022
#IMPORTANTE: Ejecutar en PWS, en VisualStudioCode no funciona

### Debug:
#$ErrorActionPreference= 'silentlycontinue'

### Highlights:
# - 

# Registro de Cmdlets de Datacore
cls
Import-Module '\\SERVER\c$\Program Files\DataCore\SANsymphony\DataCore.Executive.Cmdlets.dll' -WarningAction silentlyContinue

# Variables
$DCListPlant = Get-Content '\\SERVER\DataCoreSites.txt'  # Ruta al archivo con la lista de las plantas con Datacore


#Part1: Look for depleted DiskPools on Datacore
ForEach ($DCGroup in ($DCListPlant)) { 
    #Sacar la password #INFO PRIVADA
    $DcsCredItem = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $DCUserName, $DcsPassword


    # Conectar a DataCore
    Connect-DcsServer -Server $DCName -Credential $DcsCredItem -Connection $DCName

    # Listar los vDisks
    $discos =@()
    $discos=Get-DcsVirtualDisk
    foreach($disco in $discos)
    {
        if ($disco.Alias -notlike "*CORE0*")
        {
            if($disco.Type -eq "MultiPathMirrored")
            {
                Write-Host $disco.Alias "has mode" $disco.Type -ForegroundColor Green
            }
            else
            {
                Write-Host $disco.Alias "has mode" $disco.Type -ForegroundColor Red
            }
        }
    }

    # Desconexion de DataCore
    Disconnect-DcsServer
}
