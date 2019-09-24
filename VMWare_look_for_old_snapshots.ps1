# variables:
# VCENTER_HOST, DOMINIO, SERVICE_ACCOUNT, PASSWORD

# Description:
#   - Look snapshots for all the virtual machines in the virtual center VCENTER_HOST, 
#     except for the datacenters "hq-gua" and "hq-tests" and for the virtual machines which name finishes with "*_replica"
#   - From the snapshots detected select those created 3 days or more ago and send a report to the recipients stored in the variable $recipients
#   - The report separate the snapshots in 2 tables, one for the snapshots powered off and one for those snapshots running (powered on)
#   - The first argument is the number of Data Centers to be processed in parallel, "all" means all the Data Centers
#   - The second argument is the pattern used to build the Data Center Name to be processed, "all" means all the Data Centers
#   - To delete the snapshots, the script must be run with the third argument as "-removeSnaps" and if we want just a report, this third argument must be "-onlyReport"
#     In that case, all the snapshots powered off and aged 3 or more days, will be removed one by one per Data Center and always that all the Datastores
#     associated to the VM have free space over twice the aggregated size for the space used by all the snapshots of the VM (removal are one by one, so 
#     really we don't need such amount of free space
#     Examples:
#          vmware-remove_Old_VMs_snapshots.ps1 all all -onlyReport
#          vmware-remove_Old_VMs_snapshots.ps1 all IFR -onlyReport
#          vmware-remove_Old_VMs_snapshots.ps1 15 all -onlyReport
#          vmware-remove_Old_VMs_snapshots.ps1 7 all -removeSnaps

# Functions to support the HTML table that will be inclueded in the report sent by email
function CreateSnapToDelete {
    param ([string]$datacenter, [string]$virtualMachine, [string]$snapshot, [string]$snapPowerState,
        [string]$snapDescription, [string]$snapCreationDate, [string]$snapAgeDays, [string] $id, [string] $sizeGB)
    $objBackup = New-Object System.Object
    $objBackup | Add-Member -type NoteProperty -name DataCenter -value $datacenter
    $objBackup | Add-Member -type NoteProperty -name VirtualMachine -value $virtualMachine
    $objBackup | Add-Member -type NoteProperty -name Snapshot -value $snapshot
    $objBackup | Add-Member -type NoteProperty -name SnapPowerState -value $snapPowerState
    $objBackup | Add-Member -type NoteProperty -name SnapDescription -value $snapDescription
    $objBackup | Add-Member -type NoteProperty -name SnapCreationDate -value $snapCreationDate
    $objBackup | Add-Member -type NoteProperty -name SnapAgeDays -value $snapAgeDays
    $objBackup | Add-Member -type NoteProperty -name ID -value $id
    $objBackup | Add-Member -type NoteProperty -name SizeGB -value $sizeGB
    $objBackup
}
function bgColor ($color) {
    if ($color -eq "Red") { return "#FF0000" }
    elseif ($color -eq "Green") { return "#00FF00" }
    elseif ($color -eq "Yellow") { return "#FFFF00" }
    elseif ($color -eq "Gray") { return "#808080" }
    else { return "#FFFFFF" }
}
function fontColor ($color) {
    if ($color -eq "Red") { return "#FFFFFF" }
    elseif ($color -eq "Green") { return "#000000"}
    elseif ($color -eq "Yellow") { return "#000000" }
    elseif ($color -eq "Gray") { return "#FFFFFF" }
    else { return "#000000" }
}
function fillTable ($snapsToDelete) {
    $htmlCode = @()
    $htmlCode += '<tr style="color: #FFFFFF; background: #808080;">'
    $htmlCode += '<td align="center"><b>DATA CENTER</b></td>'
    $htmlCode += '<td align="center"><b>VIRTUAL MACHINE</b></td>'
    $htmlCode += '<td align="center"><b>SNAPSHOT NAME</b></td>'
    $htmlCode += '<td align="center"><b>SNAPSHOT ID</b></td>'
    $htmlCode += '<td align="center"><b>SNAP POWER STATE</b></td>'
    $htmlCode += '<td align="center"><b>DESCRIPTION</b></td>'
    $htmlCode += '<td align="center"><b>CREATION DATE</b></td>'
    $htmlCode += '<td align="center"><b>AGE DAYS</b></td>'
    $htmlCode += '<td align="center"><b>SIZE GBs</b></td>'
    $htmlCode += '</tr>'
    foreach ($item in $snapsToDelete)
    {
        $htmlCode += '<tr style="color: #000000; background: #FFFFFF;">'
        $htmlCode += '<td align="center"><b>'+$item.DataCenter+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.VirtualMachine+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.Snapshot+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.ID+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.SnapPowerState+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.SnapDescription+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.SnapCreationDate+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.SnapAgeDays+'</b></td>'
        $htmlCode += '<td align="center"><b>'+$item.SizeGB+'</b></td>'
        $htmlCode += '</tr>'
    }
    return $htmlCode
}

if ($args[2] -eq $null) #el número de argumentos debe ser 2 así que comprobamos si tiene 3
{
    Write-Host ("Invalid number of arguments")
    Write-Host ("Exiting ...");sleep 1
    return
}

# Loading PowerCLI module and connecting to Virtual Center
    $Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
    $rootFolder = "E:\Scripts\VMware"

    ######OPCION1 CON PASS EN TEXTO PLANO
        $pass= ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
        $credVC = new-object -typename System.Management.Automation.PSCredential("DOMINIO\SERVICE_ACCOUNT",$pass)
    ######OPCION2 CON PASS SEGURA
        #$secVCPass = Get-Content -Path "$rootFolder\passVCenter.txt" | ConvertTo-SecureString -Key $Key
        #$credVC = new-object -typename System.Management.Automation.PSCredential("DOMINIO\SERVICE_ACCOUNT",$pass)

    if (!(Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)) { Add-PSSnapin VMware.VimAutomation.Core }
    $vCenter=Connect-VIServer -Server "gansvc01" -Credential $credVC -Verbose:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

# Getting all the Data Centers (because we will report ordered by Data Center, not by Virtual Machine
$dataCentersAll = Get-Datacenter -Server $vCenter | Sort-Object
# Datacenters Pattern
$pattern = $args[1]
if ($pattern.GetType().Name -ne "String") 
{ 
    Write-Host ("Invalid Data Center Pattern Name")
    Write-Host ("Exiting ...");sleep 1
    return
} else {
    $dataCenters = @()
    $pattern = $pattern.ToUpper()
    if ($pattern -ne "ALL") { $dataCenters += $dataCentersAll | where {$_.Name -like ($pattern+"*") } }
    else { $dataCenters += $dataCentersAll }
}
# Number of Data Centers to be processed in parallel
if ($args[0].GetType().Name -eq "String") 
{ 
    if ($args[0].ToLower() -eq "all") 
    { 
        $numDCs = $dataCenters.Count
    } else { 
        Write-Host ("Invalid number of Data Centers")
        Write-Host ("Exiting ...");sleep 1
        return
    }
} else { [int]$numDCs = $args[0] }

cls
# Looking for the snapshots aged 3 days or over
$now = Get-Date
# Variables to store the information to be reported
$snapsToDeleteOff = @()
$snapsToDeleteOther = @()
$cont = 0
foreach ($datacenter in $dataCenters)
{
    if ($cont -ge $numDCs) { break }

    # descomentar la siguiente línea si quieremos exluir algún datacenter
    #if (("hq-gua","hq-tests") -cmatch $dataCenter.Name.ToLower()) { continue } 


    $dataCenter.Name
    
    $VMs = Get-VM -Location $dataCenter -Server $vCenter # Getting Virtual Machines for this Data Center
    $matched = $false

    foreach ($vm in $VMs)
    {
        $snaps = @()
        
        if ($vm.Name.ToLower() -like "*_replica" -Or $vm.Name.ToLower() -like "*_replicaDR") { continue } # If Virtual Machine is a replica o _replicaDR, we skip it
        
        $snaps += Get-Snapshot -VM $vm -Server $vCenter | Sort-Object -Property Created -Descending # Getting the snapshots for this Virtual Machine
        
        foreach ($snap in $snaps)
        {
            $matched = $true
            $ageDays = [int]($now-$snap.Created).TotalDays

            if ($ageDays -lt 3) { continue } # If the snapshot is "younger" than 3 days, will be skipped
            
            if ($snap.PowerState -eq "PoweredOff" ) # We classify the snapshots by Power Status
            {
                $snapsToDeleteOff += CreateSnapToDelete -datacenter $dataCenter.Name -virtualMachine $vm.Name -snapshot $snap.Name -snapPowerState $snap.PowerState `
                                -snapDescription $snap.Description -snapCreationDate $snap.Created -snapAgeDays $ageDays.ToString() -id $snap.Id `
                                -sizeGB ([System.Math]::Round($snap.SizeGB,5).ToString())
            } else {
                $snapsToDeleteOther += CreateSnapToDelete -datacenter $dataCenter.Name -virtualMachine $vm.Name -snapshot $snap.Name -snapPowerState $snap.PowerState `
                                -snapDescription $snap.Description -snapCreationDate $snap.Created -snapAgeDays $ageDays.ToString() -id $snap.Id `
                                -sizeGB ([System.Math]::Round($snap.SizeGB,5).ToString())
            }
        }
    }
    if ($matched) { $cont++ }
}

# Closing Virtual Center Connection
Disconnect-VIServer -Server $vCenter -Force -Confirm:$false

# Generating the HTML code to be reported
#region
$htmlCode=""
$htmlCode += '<html>'
$htmlCode += '<head>'
$htmlCode += '</head>'
$htmlCode += '<body>'
# Table for not powered off snapshots
$htmlCode += '<br><br>'
$htmlCode += '<table border="1" style="width:90%">'
$htmlCode += '<tr style="color: #FFFFFF; background: #FF0000;">'
$htmlCode += '<td colspan="9" align="center"><b>NOT POWERED OFF SNAPSHOTS DETECTED TO BE DELETED: '+$snapsToDeleteOther.Count+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += fillTable $snapsToDeleteOther
$htmlCode += '</table>'
# Table for powered off snapshots
$htmlCode += '<br><br>'
$htmlCode += '<table border="1" style="width:90%">'
$htmlCode += '<tr style="color: #FFFFFF; background: #0431B4;">'
$htmlCode += '<td colspan="9" align="center"><b>POWERED OFF SNAPSHOTS DETECTED TO BE DELETED: '+$snapsToDeleteOff.Count+'</b></td>'
$htmlCode += '</tr>'
$htmlCode += fillTable $snapsToDeleteOff
$htmlCode += '</table>'

$htmlCode += '</body>'
$htmlCode += '<html>'
#endregion

# Sending the report to the defined recipients
$from = "VMWare_Snapshots_Cleaning@DOMINIO.com"
$subject = "VMWare Snapshots Cleaning"
$smtpServer = "ip.ip.ip.ip" #SMTP server IP
$recipients = "destinatario1@DOMINIO.com","destinatario2@DOMINIO.com""
Send-MailMessage -From $from -Subject $subject -SmtpServer $smtpServer -To $recipients -Body $htmlCode -BodyAsHtml


# If arguments "-removeSnaps" is passed as the third argument, the snaps 3 days old and over and powered off, will be deleted
$removalScript = "E:\Scripts\VMware\vmware-remove_VMs_snapshots-OnebyOne.ps1"
if ($args[2] -eq "-removeSnaps")
{
    $snapsToBeDeletedGrouped = $snapsToDeleteOff | Group-Object -Property DataCenter
    foreach ($snapsGroup in $snapsToBeDeletedGrouped)
    {
        $argument = ""
        foreach ($item in $snapsGroup.Group) { $argument += $item.DataCenter+"/"+$item.VirtualMachine+"/"+$item.Snapshot+"/"+$item.ID+"@" }
        $argument = $argument.Substring(0,$argument.Length-1) -replace " ","#"
        $command = '/C powershell '+$removalScript+' "'+$argument+'"'
        Start-Process -FilePath cmd.exe -ArgumentList $command
    }
}
