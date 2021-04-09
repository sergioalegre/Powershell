##Devolverá el SL de la máquina (devuelve la última palabra del campo notes)
(((get-view -viewtype VirtualMachine -filter @{"Name"="XXXVMNAME"}).config).Annotation).split()[-1]


##SL de todas las máquinas
$nameVM=(Get-VM -Name *).name
$nameVM | %{ write-host $_ (((get-view -viewtype VirtualMachine -filter @{"Name"="$_"}).config).Annotation).split()[-1] }
