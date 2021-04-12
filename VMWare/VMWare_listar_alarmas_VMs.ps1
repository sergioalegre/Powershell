cls
Add-PSSnapin VMware.VimAutomation.Core

$user = "you_user_here"
$pass = "tu_pass_aqui"
$vcenter = "vcenter_name_here"

Connect-VIServer -Server $vcenter -User $user -Password $pass | Out-Null

cls
write-host "Listado de alarmas activas en VMs con nombre '*_replica': "

#cogemos la lista de VMs con nombre *_replica
$VMs = Get-View -ViewType VirtualMachine -Property Name,OverallStatus,TriggeredAlarmstate | where name -like "*_replica"
 
#Cuantas de ellas tienen algún fallo
$FaultyVMs = $VMs | Where-Object {$_.OverallStatus -ne "Green"}

 
$progress = 1
$report = @()
if ($FaultyVMs -ne $null) {
    foreach ($FaultyVM in $FaultyVMs) {
            foreach ($TriggeredAlarm in $FaultyVM.TriggeredAlarmstate) {
                Write-Progress -Activity "Leyendo alarmas" -Status "Trabajando en $($FaultyVM.Name)" -PercentComplete ($progress/$FaultyVMs.count*100) -Id 1 -ErrorAction SilentlyContinue
                $alarmID = $TriggeredAlarm.Alarm.ToString()
                $object = New-Object PSObject
                Add-Member -InputObject $object NoteProperty VM $FaultyVM.Name
                Add-Member -InputObject $object NoteProperty TriggeredAlarms ("$(Get-AlarmDefinition -Id $alarmID)")
                $report += $object
            }
        $progress++
        }
    }
Write-Progress -Activity "Gathering VM alarms" -Status "All done" -Completed -Id 1 -ErrorAction SilentlyContinue
 
$report | Where-Object {$_.TriggeredAlarms -ne ""}

#Disconnect-VIServer
