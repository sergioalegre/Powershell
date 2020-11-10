#listaremos todas las VMs con algun disco THICK, excepto las que es normal que lo tengan, en orden descendiente de tamaño

cls


Get-VM | Get-HardDisk | Where {$_.storageformat -eq "Thick" `
-and $_.Parent -NotLike "*VARIV*" `
-and $_.Parent -NotLike "*VMRIV*" `
-and $_.Parent -NotLike "*VMCM*" `
-and $_.Parent -NotLike "*VMCOM*" `
-and $_.Parent -NotLike "*_MigratedITIBlock*" `
-and $_.Parent -NotLike "*CORE*" `
-and $_.Parent -NotLike "*WLC*" `
-and $_.Parent -NotLike "*_replica" `
-and $_.Parent -NotLike "*_livesync" `
-and $_.Parent -NotLike "*VANAC*"  `
-and $_.Parent -NotLike "GANVMSAP0*"} | Select Parent, Name, CapacityGB, storageformat | Sort -Property CapacityGB -Descending
