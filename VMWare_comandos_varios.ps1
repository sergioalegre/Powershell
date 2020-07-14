##REQUISITO: VMware-PowerCLI

##devolverá vacio si la VM no tiene backup (si en Veeam configuras una tag vmware personalizada llamada VEEAM)
(Get-VM -Name VMNAME | Get-Annotation -Name *VEEAM*).Value


##Devolverá el SL de la máquina (devuelve la última palabra del campo notes)
(((get-view -viewtype VirtualMachine -filter @{"Name"="XXXVMNAME"}).config).Annotation).split()[-1]


##SL de todas las máquinas
$nameVM=(Get-VM -Name *).name
$nameVM | %{ write-host $_ (((get-view -viewtype VirtualMachine -filter @{"Name"="$_"}).config).Annotation).split()[-1] }


#Listar todos los host y todas las IPs de un vCenter
# Con ft * -Autosize formateamos la salida ya que el tamaño de las columas vendra determinadas por el tamaño del primer registro
# Todo lo que exceda el tamaño del primer registro aparecerá con puntos suspensivos
# la parte mala de este formateo es que ha de acabar el script (no saldra linea a linea) hasta que no haya calculado todos
Get-VMHost | Select Name,@{n="ManagementIP"; e={Get-VMHostNetworkAdapter -VMHost $_ -VMKernel | ?{$_.ManagementTrafficEnabled} | %{$_.Ip}}} | ft * -AutoSize > C:\Users\sergio\Desktop\lista.txt


#Listar propiedades HW de cada host de vCenter
$VMHosts = Get-VMHost
ForEach ($VMHost in $VMHosts)
   { 
   "" | Select-Object -Property 
   @{N="Name";E={$VMHost.Name}},
   @{N="Vendor";E={(Get-View -ViewType HostSystem -Filter @{"Name" = $VMHost.Name}).Hardware.Systeminfo.Vendor}},
   @{N="Model";E={(Get-View -ViewType HostSystem -Filter @{"Name" = $VMHost.Name}).Hardware.Systeminfo.Model}},
   @{N="CPU Model";E={$VMHost.ExtensionData.Summary.Hardware.CpuModel}},
   @{N="Datacenter";E={(Get-Datacenter -VMHost $VMHost.Name).Name}},
   @{N="Cluster";E={(Get-Cluster -VMHost $VMHost.Name).Name}},
   @{N="Hypervisor";E={$VMHost.Extensiondata.Config.Product.Name}}, 
   @{N="Hypervisor Version";E={$VMHost.Extensiondata.Config.Product.Version}}, 
   @{N="Clock Speed (Mhz)";E={$VMHost.ExtensionData.Summary.Hardware.CpuMhz}},
   @{N="Memory (MB)";E={$VMHost.MemoryTotalMB}},
   @{N="Hyperthreading Enabled";E={$VMHost.HyperThreadingActive}},
   @{N="Number of Cores";E={$VMHost.ExtensionData.Summary.Hardware.numCpuCores}}
   }
