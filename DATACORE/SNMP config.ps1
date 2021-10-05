###Variables
    #IPs to be allowed at firewall
    $ips = @("1.2.3.4", "4.3.2.1")
    $Managers = @("1.2.3.4", "4.3.2.1")
    $ReadOnlyCommunities = @("comunity_name")
    $RWCommunities = ""
    $sysLocation = "location_name"
    $sysContact = "contact_name"
    $readonlytrap = "1.2.3.4"
    $rwtrap = ""
    $fileserver = ""
    $filepath = ""


###Setup firewall Prerequisites
    Write-Host "firewall rules add ..." -ForegroundColor Yellow
    New-NetFirewallRule -DisplayName “Solarwinds Monitoring” -Direction Inbound -RemoteAddress $ips -Action Allow
    Write-Host "firewall rules COMPLETE" -ForegroundColor Green


###SNMP Service Setup
    Write-Host "install SNMP services ..." -ForegroundColor Yellow
    Install-WindowsFeature -Name 'SNMP-Service','RSAT-SNMP'
    Write-Host "SNMP services COMPLETE" -ForegroundColor Green

    #start services and set them to automatic start
    Write-Host "changing SNMP to AUTOMATIC" -ForegroundColor Yellow
    Set-Service SNMP -startuptype automatic
    Write-Host "SNMP service set to AUTOMATIC COMPLETE" -ForegroundColor Green

    Write-Host "changing Datacore SNMP to AUTOMATIC" -ForegroundColor Yellow
    Set-Service DcsSNMP -startuptype automatic
    Write-Host "Datacore SNMP service set to AUTOMATIC COMPLETE" -ForegroundColor Green

    Write-Host "starting Datacore SNMP to AUTOMATIC" -ForegroundColor Yellow
    Start-Service DcsSNMP
    Write-Host "Datacore SNMP service started COMPLETE" -ForegroundColor Green



###SNMP Configuration
    Write-Host "SNMP config started ..." -ForegroundColor Yellow
    Import-Module ServerManager
            Write-host "Enable ServerManager"
            Import-Module ServerManager
    #		#Check if SNMP-Service is already installed
            Write-host "Checking to see if SNMP is Installed..."
            $check = Get-WindowsFeature -Name SNMP-Service
    #		
            If ($check.Installed -ne "True") {
                #Install/Enable SNMP-Service
                Write-host "SNMP is NOT installed..."
                Write-Host "SNMP Service Installing..."
                Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeAllSubFeature | Out-Null
                }
                Else {
                Write-Host "Error: SNMP Services Already Installed"
                }
    #Configure SNMP Regigstry Keys
            Write-Host "Setting SNMP sysServices"
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent" /v sysServices /t REG_DWORD /d 79 /f | Out-Null
            Write-Host "Setting SNMP sysLocation"
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent" /v sysLocation /t REG_SZ /d $sysLocation /f | Out-Null
            Write-Host "Setting SNMP sysContact"
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent" /v sysContact /t REG_SZ /d $sysContact /f | Out-Null
            Write-Host "Setting SNMP Community Regkey"
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration" /f | Out-Null
            Write-Host "Setting read only SNMP Community Regkey"
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\$readonlytrap" /f | Out-Null
            Write-Host "Setting read write SNMP Community Regkey"
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\$rwtrap" /f | Out-Null
            Write-Host "Adding readonly SNMP Trap Communities"

    #Loop Through Read Only SNMP Communities
            Foreach ($ReadOnlyCommunity in $ReadOnlyCommunities) {
                reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $ReadOnlyCommunity /t REG_DWORD /d 4 /f | Out-Null
            }

    #Loop through permitted SNMP management systems
            Write-Host "Adding Permitted Managers"
            $i = 1
            Foreach ($Manager in $Managers){
                reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $i /t REG_SZ /d $manager /f | Out-Null
                reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /v $i /t REG_SZ /d $manager /f | Out-Null
                $i++
            }
    Write-Host "SNMP config COMPLETE" -ForegroundColor Green


###Restart SNMP
    Write-Host "SNMP restarting ..." -ForegroundColor Yellow
    Restart-Service SNMP -PassThru
    Write-Host "SNMP restart COMPLETE" -ForegroundColor Green

    Write-Host "Datacore SNMP restarting ..." -ForegroundColor Yellow
    Restart-Service DcsSNMP -PassThru
    Write-Host "Datacore SNMP restart COMPLETE" -ForegroundColor Green


#NOW CHECK AND FIX WHAT NEEDED
    wf.msc
    services.msc
    Write-Host "NOW CHECK & FIX WHAT NEEDED" -ForegroundColor RED