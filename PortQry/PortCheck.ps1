# This script checks if all the necessary ports for custom or DC communications

# define Variables
 [CmdletBinding()]  # Esto es un decorator
   Param(
	[Parameter(Mandatory=$true,ValueFromPipeline=$false,HelpMessage="Destination system")]
	[string]$Target,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Port string")]
    [string[]]$Ports,
    [Parameter(Mandatory=$false,ValueFromPipeline=$false,HelpMessage="DC, custom")]
        [ValidateScript({$_ -eq "DC"})] # Solo aceptamos los valores custom o DC
    [string]$type
	)


# If type = DC we test next ports
if ($type -eq "DC"){
 $Ports = "389:TCP:LDAP TCP","389:UDP:LDAP UDP","636:TCP:LDAP SSL","3268:TCP:LDAP GC","3269:TCP:LDAP GC SSL","88:TCP:Kerberos TCP","88:UDP:Kerberos UDP","53:TCP:DNS",`            "53:UDP:DNS","445:TCP:SMB TCP","445:UDP:SMB UDP","135:TCP:EPM",`            "9389:TCP:SOAP","137:UDP:Netlogon UDP","139:TCP:DFSN:NetBIOS Serssion Service Netlogon"
}elseif (!$Ports){
$Ports = @()
# sino preguntamos por los puertos a testear

 do{
    $matches = $null
    $strIn = Read-Host "Type port:TCP or port:UDP. Type - to start testing"

    if ($strIn -ne "-"){
        $strIn -match "(?<port>[0-9]+):(?<protocol>(TCP|UDP))" | Out-Null

        if ($matches){
            $valid = $true
            $Ports += "{0}:{1}:{2}" -f $matches.port, $matches.protocol, "Custom port"
        }else{
            Write-Error "Incorrect entry. Please use port:TCP or port:UDP format. Example: 389:TCP"
        }
    }
 }while ($strIn -ne "-")
}

clear-host

#Looping throught all targets.

foreach ($sTarget in @($target))
{
    write-host ""
    write-host $sTarget -ForeGroundColor green
     $Ports | ForEach {
     $PortNumber = $_.Split(":")[0]
     $PortType = $_.Split(":")[1]
 	 $PortDescription = $_.Split(":")[2]
   

    .\portqry.exe -n $sTarget -e $PortNumber -p $PortType -q
    if ($LASTEXITCODE -ne 0)
    {
        switch ($LASTEXITCODE)
        {
            1 {
                write-host ("  {0}({1}) failed with port not listening." -f $PortNumber, $PortType, $PortDescription) -ForeGroundColor red
                break
            }
            2 {
                write-host ("  {0}({1}) failed with port not listening or filtered" -f $PortNumber, $PortType, $PortDescription)  -ForeGroundColor red
                break
            }
        }
    } 
    else {write-host ("  {0}({1}) reported okay"  -f $PortNumber, $PortType, $PortDescription) -ForeGroundColor green}
   }
}
