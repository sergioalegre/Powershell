#NOTA1 Resize para maquineas Windows, ver mas abajo que cambiar para otra Linux
#NOTA2: Posible problema con discos extra, ver mas abajo
Connect-AzAccount

# Set variables
$resourceGroup = "myresourcegroup"
$vmName = "myexistingVM"
$newSize = "Standard_D2as_v4"

#Resize para maquineas Windows, ver mas abajo que cambiar para otra Linux
Connect-AzAccount

# Get the details of the VM to be resized
$originalVM = Get-AzVM `
   -ResourceGroupName $resourceGroup `
   -Name $vmName

# Remove the original VM
Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
Remove-AzVM -ResourceGroupName $resourceGroup -Name $vmName    

# Create the basic configuration for the replacement VM. 
$newVM3 = New-AzVMConfig `
   -VMName $originalVM.Name `
   -VMSize $newSize `
   -Tags $originalVM.Tags `
   -LicenseType $originalVM.LicenseType

# NOTA1: For a Linux VM, change the last parameter from -Windows to -Linux 
Set-AzVMOSDisk `
   -VM $newVM3 -CreateOption Attach `
   -ManagedDiskId $originalVM.StorageProfile.OsDisk.ManagedDisk.Id `
   -Name $originalVM.StorageProfile.OsDisk.Name `
   -Windows

# Add Data Disks
foreach ($disk in $originalVM.StorageProfile.DataDisks) { 
Add-AzVMDataDisk -VM $newVM3 `
   -Name $disk.Name `
   -Caching $disk.Caching `
   -Lun $disk.Lun `
   -DiskSizeInGB $disk.DiskSizeGB `
   -CreateOption Attach
}

#NOTA2: hubo un problema que no hacia bien esta propiedad asi que si la VM tiene mas de un disco habra que ir pasando esa propiedad a mano. Tantos como discos extra tenga la VM
#$originalvm.StorageProfile.DataDisks #para ver cuantos discos tiene
#$newVM3.StorageProfile.DataDisks[0].ManagedDisk = $originalvm.StorageProfile.DataDisks[0].ManagedDisk
#$newVM3.StorageProfile.DataDisks[1].ManagedDisk = $originalvm.StorageProfile.DataDisks[1].ManagedDisk
#etc


# Add NIC(s) and keep the same NIC as primary; keep the Private IP too, if it exists. 
foreach ($nic in $originalVM.NetworkProfile.NetworkInterfaces) {	
if ($nic.Primary -eq "True")
{
        Add-AzVMNetworkInterface `
           -VM $newVM3 `
           -Id $nic.Id -Primary
           }
       else
           {
             Add-AzVMNetworkInterface `
            -VM $newVM3 `
             -Id $nic.Id 
            }
  }

# Recreate the VM
New-AzVM `
   -ResourceGroupName $resourceGroup `
   -Location $originalVM.Location `
   -VM $newVM3 `
   -DisableBginfoExtension