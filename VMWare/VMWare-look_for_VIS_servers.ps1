cls
$vCenter = "GANSVC01"
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter
$lista= Get-VM | Where { $_.Name -Like "*VMVIS0*"  } | Sort -Property Name
Write-Host "VIS servers deployed: " $lista.Count -ForegroundColor Red
$lista.Name