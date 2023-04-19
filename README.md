Check also my other github scripting repos for [BASH](https://github.com/sergioalegre/Bash-Script) and [PYTHON](https://github.com/sergioalegre/Python-automations).

**POWERSHELL SCRIPTS INDEX:**

[#FILES](#FILES)

[#Datacore](#Datacore)

[#MYSQL](#MYSQL)

[#Veeam](#Veeam)

[#VMWare](#VMWare)

[#Windows](#Windows)

[#Azure](#Azure)

[#Commvault](#Commvault)

------------

### highlights
  - barra de progreso: VMWare-count_VMs_by_criticity, vmware-lookfor_Cluster_Degraded_Status
  - clear: VMWare-count_VMs_by_criticity
  - string to datetime conversion: VMWare_list_VMs_with_old_Commvault_backup
  - string to int: WINDOWS_Remote_Sites_Average_Latency
  - string lenght reduce: VMWare_list_VMs_with_old_Commvault_backup
  - string substring: WINDOWS_Remote_Sites_Average_Latency
  - try/catch: VMWare_list_VMs_with_old_Commvault_backup
  - PSSession: WINDOWS_ejecutar_comando_en_server_remoto
  - Test-Connection: WINDOWS_ejecutar_comando_en_server_remoto
  - ejecución en paralelo: WINDOWS_servers_con_conexiones_TIME_WAIT
  - ejecucion en paralelo: DATACORE_ring_buffer_exhaustion_check
  - objetos array: WINDOWS_servers_con_conexiones_TIME_WAIT
  - exportar a csv: WINDOWS_servers_con_conexiones_TIME_WAIT
  - exportar a csv: DATACORE_ring_buffer_exhaustion_check
  - menu con opciones: VMWare-general_con_menu
  - funciones: VMWare-plant_latency_against_FR
  - funcion con mas de un parametro: commvault_check_Azure_backups
  - regular expressions: WINDOWS_Shadow_Copy_check_active

### VMWare
  - **VMWare_Change_SNMP_all_Hosts_in_vCenter**
  - **VMWare_THICK_disks_list_on_vCenter** look for THICK disk in all hosts
  - **VMWare_VMs_consolidation_needed** in all vCenter
  - **VMWare_VMs_with_USB_SERIAL_Parallel** in all vCenter
  - **VMWare_comandos_varios** cheetsheet
  - **VMWare_get_VMs_criticity** get all VMs criticity in vCenter (based label in Notes field)
  - **VMWare_list_VMs_with_old_Commvault_backup** look for outdate backups based the comment on 'Last Backup' field
  - **VMWare_listar_alarmas_VMs** get all vCenter alarms
  - **VMWare_look_for_old_snapshots** in all vCenter
  - **VMWare_get_VMs_criticity** show a single VM criticity
  - **VMWare-count_VMs_by_criticity** live counter and progress bar
  - **VMWare-get_vm_information** Get PowerState, vCenterServer, Datacenter, Cluster, VMHost, Datastore, Folder, GuestOS, NetworkName, IPAddress, MacAddress, VMTools
  - **VMWare-plant_latency_against_FR** latencia de sites remotos contra un punto central
  - **vmware-lookfor_Cluster_Degraded_Status** look for cluster with less than 2 nodes (degraded)

### Files
  - **ARCHIVOS_aiging** delete files older than x days in a determinate path
  - **ARCHIVOS_archieved_files** look for archieved files (offline attribute + disk size 0)
  - **ARCHIVOS_buscar_herencia_permisos_cortada** look for folder with inherance problems
  - **ARCHIVOS_copiar_jerarquia_carpetas** just copy folder jerarchy from source to destination
  - **ARCHIVOS_crear carpetas recursivamente y ponerles permisos**
  - **ARCHIVOS Abre de 5 en 5 los ficheros .txt y .bmp de una ruta**
  - **ARCHIVOS_FileWatcher_when_a_file_is_created_copy_to_Azure**

### Datacore
  - **DATACORE_varios.txt** cheetsheet
  - **List_Datacore_Server_IPs** list all Datacore servers IPs on vCenter
  - **SNMP config** configure SNMP settings and create firewall rules
  - **VMWare no ve los vDisk tras encender Datacore** Rescan iSCSI HBA if VMware do not detect vDisk afer Datacore power up
  - **DATACORE_buscar_problemas_de_latencia_en_todos_los_datacore_servers** Se conecta a todos los Datacore Clusters y busca latencias en el log, tambien muestra si el log database esta detenido.
  - **DATACORE_ring_buffer_exhaustion_fix** Solucionar el problema de llenado del buffer.
  - **DATACORE_healthCheck_completo** checkea en localhost u otro server varios componentes.
  - **DATACORE_get_all_vDisks_gloabally** Se conecta a todos los Datacore Clusters y muestra la ocupacion de todos los vDisks de cada cluster.
  - **DATACORE_ring_buffer_exhaustion_check** Comprueba en todos los ESX la cantidad de drops en las tarjetas de mirros y si es mas de 10000 lo guarda en un CSV.

### MYSQL
  - **MSSQL_comandos_varios** cheetsheet
  - **MYSQL_Backup_a_Share** open ssh session and Get-SCPFile to cifs share

### Veeam
  - **VEEAM_Reporte_Backup** veeam report based VeeamPSSnapIn

### Windows
  - **WINDOWS_Optimice_Volume+UNMAP** busca todas las unidades locales (que no sean de red) y las hace un defrag
  - **WINDOWS_check_servers_last_reboot_and_KB_installed_or_not** check a server list one by one, when was rebooted last and if have or not several patches. Output in csv format
  - **WINDOWS_kill_disconnected_sessions** kill disconected sessions on an RDP server
  - **WINDOWS_ejecutar_comando_en_server_remoto** abrir sesion remota a varios servidores y ejecutar en ellos comandos locales
  - **WINDOWS_ejecutar_comando_en_server_remoto_por_WMI**: comandos a servers remotos por WMI
  - **WINDOWS_servers_con_conexiones_TIME_WAIT** look for servers with many unclosed conenctions
  - **WINDOWS Borrar Bad address de DHCP server**
  - **WINDOWS_instalacion_remota_parches** lee una lista de servers y en base a la version instala un parche u otro
  - **WINDOWS_Remote_Sites_Average_Latency** calcula la latencia media contra todos los sites remotos desde un collocation
  - **AD buscar pcs con un patron de nombre**
  - **WINDOWS cambiar letra de unidad del homedrive**
  - **WINDOWS_Servers_with_MBR_disks** mira en todas las VMs si algun disco que no sea el del OS tiene MBR
  - **WINDOWS_create_scheduled_task** crear una tarea programada
  - **WINDOWS_Shadow_Copy_check_active** comprueba si Shadow Copy esta activo en los servers en donde deberia estarlo

### Azure
  - **VMresize** resize Azure VMs
  - **Azure_change_blob_tier_and_download_blobs** list, change tier, download blobs, look for blobs based pattern name
  - **Azure_FileWatcher_when_a_file_is_created_copy_to_Azure**
  - **AZURE Template Spec export-import** Export/Import a RG via AZ CLI or Powershell

### Commvault
