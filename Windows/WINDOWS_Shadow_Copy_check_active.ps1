# This script check if Shadow Copy is active on the right drives (not on C: but always on other letters), on servers with a VM pattern name
# IMPORTANT: Run as Administrator

#Highlight: regular expresions


$vCenter = "<vCenter>"
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter

Get-VM | Where { $_.Name -Like "*FILE_SERVER*" } | Select Name | Out-File E:\Shadow_Copy_Enable\server_list.txt
$lista = Get-Content -path E:\Shadow_Copy_Enable\server_list.txt | select-object -skip 3

ForEach ($ServerName in $lista){

    # filter drive letter from a given server with regular expressions
    $driveLetterArray = (Get-WmiObject win32_share -ComputerName $ServerName).Path -match '[A-Z]:\\$'

    # Check if that drive letter has shadowstorage
    foreach ($letter in $driveLetterArray) {
        # Clean up the letter variable so it will be able to match results from gwmi win32_volume
        $deviceID = (gwmi win32_volume -ComputerName $ServerName | Where-Object {$_.Name -eq $letter}).deviceID
        # Clean up the deviceID variable so it will be able to match results from gwmi win32_shadowstorage
        $deviceID = $deviceID.TrimStart("\\?\")
        $deviceID = "Win32_Volume.DeviceID=`"\\\\?\\" + $deviceID + "\`""
        $shadowQuery = gwmi win32_shadowstorage -ComputerName $ServerName | Where-Object {$_.Volume -eq $deviceID}

        # Report findings
        if ($shadowQuery) {
            if ($letter -eq "C:\") {
                Write-Host "Volume shadow enabled on drive ", "$letter" ,"$serverName" -ForegroundColor Red
            } else {
                Write-Host "Volume shadow enabled on drive ", "$letter" ,"$serverName" -ForegroundColor Green
            }
           
        } else {
            if ($letter -eq "C:\") {
                Write-Host "Volume shadow NOT enabled on drive ", "$letter" ,"$serverName" -ForegroundColor Green
            } else {
                Write-Host "Volume shadow NOT enabled on drive ", "$letter" ,"$serverName" -ForegroundColor Red
            }
        }
    }
}