#Scope: Obtener todos los vDisks con sus tama�os de todos los clusters de datacore a la vez
### Created by: Sergio Alegre @ June 2022
#IMPORTANT: execute at PWS ISE, not at VSC (do not work)

### Debug:
#$ErrorActionPreference= 'silentlycontinue'

### Highlights:
# - 

# Registro de Cmdlets de Datacore
cls
Import-Module '\\SERVER\c$\Program Files\DataCore\SANsymphony\DataCore.Executive.Cmdlets.dll' -WarningAction silentlyContinue

# Variables
$DCListPlant = Get-Content '\\SERVER\E$\DataCoreSites.txt'  # Ruta al archivo con la lista de las plantas con Datacore
$allocationResult = @()
$GB = 1024*1024*1024

# Connect all Datacore clusters one by one
ForEach ($DCGroup in ($DCListPlant)) { 
    #Sacar la password
    $DcsPassword = $DCPassword | ConvertTo-SecureString -AsPlainText -Force
    $DCUserName = 'Administrator'
    $DcsCredItem = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $DCUserName, $DcsPassword


    # Conectar a un DataCore
    Connect-DcsServer -Server $DCName -Credential $DcsCredItem -Connection $DCName

    # List vDisk for each Datacore Cluster
    foreach($logicalDisk in (Get-DcsLogicalDisk -Server "$DCName"))
    {
        $result = New-Object PSObject
        $result | Add-Member -MemberType NoteProperty -Name "Virtual Disk" -Value ((Get-DcsVirtualDisk -VirtualDisk $logicalDisk.VirtualDiskId).Alias)
        $result | Add-Member -MemberType NoteProperty -Name "Allocation" -Value ($logicalDisk | Get-DcsPerformanceCounter| % {$_.BytesAllocated/$GB})
        $result | Add-Member -MemberType NoteProperty -Name "Size" -Value "GB"
        Write-Host $result
    }

    # Desconexion de un DataCore
    Disconnect-DcsServer
}
