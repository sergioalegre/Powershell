###Objective: create a scheduled task

#Set Shadow Copy Scheduled Task for E:at 12:00 AM
$diskname = "E:\"
$VolumeWmi = gwmi Win32_Volume -Namespace root/cimv2 | ?{ $_.Name -eq $diskname }
$DeviceID = $VolumeWmi.DeviceID.ToUpper().Replace("\\?\VOLUME", "").Replace("\","")
$TaskName = "ShadowCopyVolume" + $DeviceID
$Action=new-scheduledtaskAction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=E:"
$Trigger=new-scheduledtasktrigger -daily -at 12:00AM
$ScheduledSettings = New-ScheduledTaskSettingsSet -Compatibility V1 -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Days 3) -Priority 5
Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Description "ShadowCopyEDrive_12:00AM" -User "DOMAIN\xxx_service_pws" -Password "mi_password" -RunLevel Highest