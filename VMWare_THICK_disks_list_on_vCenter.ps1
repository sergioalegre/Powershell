#listaremos todas las VMs con algun disco THICK, excepto las que es normal que lo tengan

Get-VM | Get-HardDisk | Where {$_.storageformat -eq "Thick" -and $_.Parent -NotLike "*VARIV*" -and $_.Parent -notlike "*VMRIV*" -and $_.Parent -notlike "*_MigratedITIBlock*"} | Select Parent, Name, CapacityGB, storageformat | FT -AutoSize
