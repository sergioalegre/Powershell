#listaremos todas las VMs con algun disco THICK, excepto las que es normal que lo tengan, en orden descendiente de tamaño

cls


Get-VM | Get-HardDisk | Where {$_.storageformat -eq "Thick" `
-and $_.Name -NotLike "*VARIV*" `
-and $_.Name -NotLike "*VMCM*" `
-and $_.Name -NotLike "*VMRIV*" `
-and $_.Name -NotLike "*_MigratedITIBlock*" `
-and $_.Name -NotLike "*CORE*" `
-and $_.Name -NotLike "*WLC*" `
-and $_.Name -NotLike "*_replica" `
-and $_.Name -NotLike "*_lyvesync" `
-and $_.Name -NotLike "*VANAC*"  `
-and $_.Name -NotLike "*VMCOM0*" `
-and $_.Name -NotLike "*VMCM0*" `
-and $_.Name -NotLike "*VMDC0*" `
-and $_.Name -NotLike "GANVMSAP0*"} | Select Parent, Name, CapacityGB, storageformat | Sort -Property CapacityGB -Descending
