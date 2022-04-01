- Problema: En un entorno DataCore Virtual SAN cuando se hace un apagado de las VM de DataCore, cuando las VMs DataCore se encienden y presenta los vDisk VMware ESXI no los ve y hay que hacer un reescaneo de los path iSCSI para que vea los DataSotes presentados. El objetivo de este script es hacer un reescaneo automático de los patchs iSCSI a nivel de host ESXi cada “X” tiempo (el intervalo que se especifique). No tengo claro si el script hay que ponerlo en vCenter o cada uno de los hosts ESXi.

- EModificar en cada caso el *datastore1* y nombre del datacore server *WINDatacore01*:


**vi /vmfs/volumes/datastore1/WINDatacore01/DataCore-Autorescan.sh**
  ```
  #!/bin/sh
  #DataCore Virtual Machine Name
  DCVM="WINDatacore02"
  VMID=$(vim-cmd vmsvc/getallvms |grep -i $DCVM)

  #Wait for VM started
  while [ $(vim-cmd vmsvc/get.guestheartbeatStatus $VMID) != "green" ]
  do
          sleep 30
  done

  #wait for DataCore service start (~1minute)
  sleep 60

  #Rescan iSCSI HBA while all target are failed
  check=1
  while [ $check -ne 0 ]
  do
          esxcfg-swiscsi -s
          sleep 30
          check=$(esxcli iscsi adapter target list|grep -c "Error:")
          if [ $check -ne 0 ] ;then sleep 500; fi
  done
  ```

**chmod +x /vmfs/volumes/datastore1/WINDatacore01/DataCore-Autorescan.sh**

**vi /etc/rc.local.d/local.sh**
  ```
  #!/bin/sh
  # local configuration options
  # Note: modify at your own risk!  If you do/use anything in this
  # script that is not part of a stable API (relying on files to be in
  # specific places, specific tools, specific output, etc) there is a
  # possibility you will end up with a broken system after patching or
  # upgrading.  Changes are not supported unless under direction of
  # VMware support.
  /vmfs/volumes/datastore1/WINDatacore02/DataCore-Autoreboot.sh
  exit 0
  ```
