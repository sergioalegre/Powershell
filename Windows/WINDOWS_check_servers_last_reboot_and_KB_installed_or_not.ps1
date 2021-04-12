#This script check a server list one by one, when was rebooted last and if have or not serveral patches. Output in csv format

#we must list our servers in a txt file, one per line
$computers = Get-Content "C:\Temp\get-hotfix\lista_VMs.txt" 

#patch to be checked
$Patch_01 = "KB4012215"  
$Patch_02 = "KB4012216" 
$Patch_03 = "KB4012217" 
$Patch_04 = "KB4015549"


foreach ($computer in $computers)    
{    
	Write-Host "Cheching $computer"
	if(Test-Connection -Computername $computer -BufferSize 16 -Count 1 -Quiet)
	{
    $BootTime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer | select @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}

		if (get-hotfix -id $Patch_01 -ComputerName $computer -ErrorAction SilentlyContinue)    
		{    
			Add-content "$Patch_01;$computer;$BootTime" -path "C:\Temp\get-hotfix\Checked.log"     
		}  
		elseif (get-hotfix -id $Patch_02 -ComputerName $computer -ErrorAction SilentlyContinue)
		{
			Add-content "$Patch_02;$computer;$BootTime" -path "C:\Temp\get-hotfix\Checked.log"     
		}
		elseif (get-hotfix -id $Patch_03 -ComputerName $computer -ErrorAction SilentlyContinue)
		{
			Add-content "$Patch_03;$computer;$BootTime" -path "C:\Temp\get-hotfix\Checked.log"     
		}
		elseif (get-hotfix -id $Patch_04 -ComputerName $computer -ErrorAction SilentlyContinue)
		{
			Add-content "$Patch_03;$computer;$BootTime" -path "C:\Temp\get-hotfix\Checked.log"     
		}		
		Else    
		{    
			Add-content "noKB;$computer;$BootTime" -path "C:\Temp\get-hotfix\Checked.log"      
		}   
	}
	else{
		Add-content "noPing;$computer" -path "C:\Temp\get-hotfix\Checked.log"  
	}
}
