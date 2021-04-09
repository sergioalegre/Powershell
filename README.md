[#FILES](#FILES)

[#Datacore](#Datacore)

[#Monitorizacion](#Monitorizacion)

[#MYSQL](#MYSQL)

[#Veeam](#Veeam)

[#VMWare](#VMWare)

[#Windows](#Windows)

------------

### FILES
  - **ARCHIVOS_aiging.ps1** delete files older than x days in a determinate path
  - **ARCHIVOS_archieved_files.ps1** look for archieved files (offline attribute + disk size 0)
  - **ARCHIVOS_buscar_herencia_permisos_cortada.ps1** look for folder with inherance problemas
  - **ARCHIVOS_copiar_jerarquia_carpetas.md** just copy folder jerarchy from source to destination


### Datacore
  - **DATACORE_varios.txt** cheetsheet


### MYSQL
  - **MSSQL_comandos_varios.ps1** cheetsheet
  - **MYSQL_Backup_a_Share.ps1** sqldump to cifs share

### Veeam
  - **VEEAM_Reporte_Backup.ps1** veeam report based VeeamPSSnapIn

### VMWare
  - **VMWare_Change_SNMP_all_Hosts_in_vCenter.ps1**
  - **VMWare_THICK_disks_list_on_vCenter.ps1** look for THICK disk in all hosts
  - **VMWare_VMs_consolidation_needed.ps1** in all vCenter
  - **VMWare_VMs_with_USB_SERIAL_Parallel.ps1** in all vCenter
  - **VMWare_comandos_varios.ps1** cheetsheet
  - **VMWare_get_VMs_criticity.ps1** get all VMs criticity in vCenter (based label in Notes field)
  - **VMWare_list_VMs_with_old_Commvault_backup.ps1** look for outate backups based the comment on 'Last Backup' field
  - **VMWare_listar_alarmas_VMs.ps1** get all vCenter alarms
  - **VMWare_look_for_old_snapshots.ps1** in all vCenter

### Windows
  - **WINDOWS_Optimice_Volume+UNMAP.ps1** busca todas las unidades locales (que no sean de red) y las hace un defrag
  - **WINDOWS_check_servers_last_reboot_and_KB_installed_or_not.ps1** check a server list one by one, when was rebooted last and if have or not several patches. Output in csv format
