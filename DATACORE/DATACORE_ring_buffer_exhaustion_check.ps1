# IMPORTANT: With EXSi >= 7.0, the script requires Posh-SSH >= 3.0. 
# Install-Module -Name Posh-SSH -Confirm:$false -AllowClobber -Scope CurrentUser
# Install-Module -Name VMware.PowerCLI -Confirm:$false -AllowClobber -Force -Scope CurrentUser
# IMPORTANT: This script requires PowerShell >= 7.0

###Highlight: 
#procesado en paralelo (ForEach-Object -Parallel)
#append de resultados a csv

Import-Module -Name VMware.VimAutomation.Core
Import-Module -Name Posh-SSH

# Variables
$blacklist_drops = New-Object System.Data.DataTable;
$blacklist_drops.Columns.Add("Host") | Out-Null
$blacklist_drops.Columns.Add("Port ID") | Out-Null
$blacklist_drops.Columns.Add("droppedRx") | Out-Null
$blacklist_drops.Columns.Add("timestamp") | Out-Null
$vCenter = "vCenter_Server_IP"
$User = "root"
$timestamp = Get-Date -Format "dd/MM/yyyy"

# Establish a connection with vCenter to obtain all hosts
Connect-VIServer -Server $vCenter
Clear-Host
$Hosts = VMWare.VimAutomation.Core\Get-VMHost | Select-Object Name

# Disconnect from vCenter
Disconnect-VIServer -Server $vCenter -Confirm:$false

$Hosts.Name | ForEach-Object -Parallel {
    $esx = $_
    Write-Host "Connecting to $esx..." -ForegroundColor Gray
    
    # Tries to connect via SSH to the host
    if (Test-Connection $esx -Quiet) {
        # Getting Password
        $Password = #put the password here
        
        try {
            # Establishing SSH connection
            $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential($using:User, $SecurePassword)
            $Session = New-SSHSession -ComputerName $esx -Credential $Credential -AcceptKey

            # Gets World ID given the computer name
            $name = $esx.Substring(0, 3).ToUpper() + "CORE"
            $id = Invoke-SSHCommand -SSHSession $Session -Command "esxcli network vm list | grep -F $name | { read first rest ; echo `$first ; }"
            $id = $id.Output

            # Gets Portgroup
            #$portgroup = Invoke-SSHCommand -SSHSession $Session -Command "esxcli network vm port list -w $id | grep -i 'MIRROR' | awk '{print `$2}'"
            #$portgroup = $portgroup.Output

            # Gets Port ID
            $portid = Invoke-SSHCommand -SSHSession $Session -Command "esxcli network vm port list -w $id | grep -i -C 2 'MIRROR' | grep -i 'Port ID: ' | awk '{print `$3}'"
            $portid = $portid.Output
            $portid = $portid.Where({ $_ -and $_.Trim() })

            # Gets droppedRx for each Port ID
            foreach ($p in $portid) {
                $drops = Invoke-SSHCommand -SSHSession $Session -Command "vsish -e get /net/portsets/DataCore/ports/$p/stats | grep -F droppedRx:"
                $drops = $drops.Output -Split ":"
                $drops = [int]$drops[1]

                # When droppedRx > 10.000 -> Message in red, added to dropped blacklist
                if ($drops -gt 10000) {
                    $blacklist = $using:blacklist_drops
                    $blacklist.Rows.Add($esx, $p, $drops, $using:timestamp) | Out-Null
                    Write-Host "Port ID: $p, droppedRx: $drops" -ForegroundColor Red
                }
            }

            # Disconnects from the host
            Remove-SSHSession -Name $Session | Out-Null
            Write-Host "Disconnected from $esx" -ForegroundColor Gray
        }
        catch {
            Write-Host "Couldn't connect to host $esx" -ForegroundColor Red
        }
    }
    else {
        Write-Host "$esx is not available" -ForegroundColor Gray
    }
}

# Execution resume
Write-Host "`nSUMMARY"
Write-Host "--------------"

Write-Host "`nDrops greater than 10.000:" -ForegroundColor Yellow
$blacklist_drops | Select-Object Host, droppedRx | Format-Table
Write-Host "Total:" $blacklist_drops.Rows.Count

#Export to CSV
$blacklist_drops | Export-Csv -Path '.\Ring buffer check\Ring buffer check log.csv' -Append -NoTypeInformation