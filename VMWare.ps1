#devolverá vacio si la VM no tiene backup (si en Veeam configuras una tag vmware personalizada llamada VEEAM)
(Get-VM -Name VMNAME | Get-Annotation -Name *VEEAM*).Value


#Devolverá el SL de la máquina (devuelve la última palabra del campo notes)
(((get-view -viewtype VirtualMachine -filter @{"Name"="NSHVMT4M01"}).config).Annotation).split()[-1]
