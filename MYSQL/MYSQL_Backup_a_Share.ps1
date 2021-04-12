#Este script almacena fuera del servidor los últimos 7 días de la bbdd
    #https://github.com/darkoperator/Posh-SSH/issues/173
    #http://www.powershellmagazine.com/2014/07/03/posh-ssh-open-source-ssh-powershell-module/
	  #https://www.linuxito.com/gnu-linux/nivel-alto/400-listar-los-archivos-modificados-en-las-ultimas-24-horas
	


#1º BORRAR BACKUPS DE MÁS DE 7 DÍAS

    $path = “\\server\share$\_Backup_Diario\”
    $limit = (Get-Date).AddDays(-7)
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force


#2º TRAERNOS EL ÚLTIMO BACKUP

    #Establecer conexion
        clear
        Import-Module Posh-SSH

        $Global:sshPassword = "paswword_here"
        $Global:sshUser = "root"
        $Global:sshHostName = "hostname_here"

        $securePassword = ConvertTo-SecureString -String $Global:sshPassword -AsPlainText -Force
        $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:sshUser, $securePassword
        $session = New-SSHSession -ComputerName $Global:sshHostName -Port "22" -Credential $credential -AcceptKey -Force #-Verbose


    #Buscamos el ultimo archivo
        $ultimo_backup = Invoke-SSHCommand -SSHSession $session -Command "find /ruta/repo_backup -type f -mtime -1"
        Write-Host "El últmimo backup es " $($ultimo_backup.Output)

    #Calculamos la fecha de hoy para renombrar el fichero
        $fecha=$(Get-Date -UFormat "%Y%m%d")
        $fichero="nombre_fichero_backup"
        $nombre_nuevo = $fichero + "." + $fecha + ".sql"
        echo $nombre_nuevo
        $ruta_completa = "\\servidor_destino\share$\" + $nombre_nuevo

    #Descargamos el fichero
        Get-SCPFile -LocalFile $ruta_completa -RemoteFile $($ultimo_backup.Output) -ComputerName $Global:sshHostName -Credential $credential


    #Desconectamos
    Remove-SSHSession -Name $session | Out-Null
