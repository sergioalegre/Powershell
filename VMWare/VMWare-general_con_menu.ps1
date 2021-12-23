Add-PSSnapin VMware.VimAutomation.Core #Adds the base cmdlets

#$user=Read-Host "Tell me you admin name "
#$pass=Read-Host " and now your" $user "password "

Connect-VIServer -Server vCenterServer -User $user -Password $pass #cadena de conexión

#MENU
clear-host
write-host "#############################"
write-host ""
write-host "            MENU             "
write-host ""
write-host "1. Check VMWare tools status in your plant"
write-host "2. Hardware status of a host"
write-host "3. VMs running on a host"
write-host "4. XXX"
write-host "5. XXX"
write-host "6. (Exit)"
write-host " " "#############################"


$opc = Read-Host "Your option "
write-host ""

if($opc -ne 0  -or $opc -ge 6){
    switch($opc){
      1 {write-host "VMWare Tools" -ForegroundColor Cyan
         Tools
      }
      2 {write-host "Hardware status" -ForegroundColor Cyan
         HW
      }
      3 {write-host "VMs en un HOST" -ForegroundColor Cyan
         VMS
      }
      4 {write-host "XXX" -ForegroundColor Cyan
          xxx
      }
      5 {write-host "XXX" -ForegroundColor Cyan
          xxx
      }
      6 {write-host "Adios" -ForegroundColor Red
          exit
      }
    }#fin switch
}#fin if
#fin MENU

Function Tools{ #comprobar el estado de VMWareTools de una planta
    $planta=Read-Host "Tell me you plant code "
    write-host "VMs at "$planta -ForegroundColor Cyan
    get-vm $planta* | Select Name,@{Name="ToolsVersion";Expression={$_.ExtensionData.Guest.ToolsVersion}},@{Name="ToolsStatus";Expression={$_.ExtensionData.Guest.ToolsVersionStatus}}
}

Function HW{ #Hardware status
    $server="server01.domain.com"
    #$server=Read-Host "Tell me the hostname, for example server01.domain.com "
    Get-VMHost -Name $server |Get-View |Select Name,@{N=“Type“;E={$_.Hardware.SystemInfo.Vendor+ “ “ + $_.Hardware.SystemInfo.Model}},@{N=“CPU“;E={“PROC:“ + $_.Hardware.CpuInfo.NumCpuPackages + “ CORES:“ + $_.Hardware.CpuInfo.NumCpuCores + “ MHZ: “ + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}},@{N=“MEM“;E={“” + [math]::round($_.Hardware.MemorySize / 1GB, 0) + “ GB“}}
}

Function VMS{ #Saber las VMs de un host
    $server="server01.domain.com"
    #$server=Read-Host "Tell me the hostname, for example server01.domain.com "
    (Get-VMhost $server | Get-View).VM | Get-VIObjectByVIView
}


clear