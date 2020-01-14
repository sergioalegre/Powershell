##REQUISITO: VMware-PowerCLI

##devolverá vacio si la VM no tiene backup (si en Veeam configuras una tag vmware personalizada llamada VEEAM)
(Get-VM -Name VMNAME | Get-Annotation -Name *VEEAM*).Value


##Devolverá el SL de la máquina (devuelve la última palabra del campo notes)
(((get-view -viewtype VirtualMachine -filter @{"Name"="XXXVMNAME"}).config).Annotation).split()[-1]

##SL de todas las máquinas
$nameVM=(Get-VM -Name *).name
$nameVM | %{ write-host $_ (((get-view -viewtype VirtualMachine -filter @{"Name"="$_"}).config).Annotation).split()[-1] }
