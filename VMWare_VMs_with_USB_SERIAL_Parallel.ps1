#VARIABLES: DOMINIO, SERVICE_ACCOUNT, PASSWORD, VCENTER_HOST

Function Start_VMWare_PowerCLI(){
    . 'C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'
}
Function Connect_VMWare ($sHost){

        Connect-VIServer -Server $sHost -User DOMINIO\SERVICE_ACCOUNT -Password PASSWORD
}

Function Get-SerialPort { 
    Param ( 
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)] 
        $VM 
    ) 
    Process { 
        Foreach ($VMachine in $VM) { 
            Foreach ($Device in $VMachine.ExtensionData.Config.Hardware.Device) { 
                If ($Device.gettype().Name -eq "VirtualSerialPort"){ 
                    $Details = New-Object PsObject 
                    $Details | Add-Member Noteproperty VM -Value $VMachine 
                    $Details | Add-Member Noteproperty Name -Value $Device.DeviceInfo.Label 
                    If ($Device.Backing.FileName) { $Details | Add-Member Noteproperty Filename -Value $Device.Backing.FileName } 
                    If ($Device.Backing.Datastore) { $Details | Add-Member Noteproperty Datastore -Value $Device.Backing.Datastore } 
                    If ($Device.Backing.DeviceName) { $Details | Add-Member Noteproperty DeviceName -Value $Device.Backing.DeviceName } 
                    $Details | Add-Member Noteproperty Connected -Value $Device.Connectable.Connected 
                    $Details | Add-Member Noteproperty StartConnected -Value $Device.Connectable.StartConnected 
                    $Details 
                } 
            } 
        } 
    } 
}

Function Get-ParallelPort { 
    Param ( 
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)] 
        $VM 
    ) 
    Process { 
        Foreach ($VMachine in $VM) { 
            Foreach ($Device in $VMachine.ExtensionData.Config.Hardware.Device) { 
                If ($Device.gettype().Name -eq "VirtualParallelPort"){ 
                    $Details = New-Object PsObject 
                    $Details | Add-Member Noteproperty VM -Value $VMachine 
                    $Details | Add-Member Noteproperty Name -Value $Device.DeviceInfo.Label 
                    If ($Device.Backing.FileName) { $Details | Add-Member Noteproperty Filename -Value $Device.Backing.FileName } 
                    If ($Device.Backing.Datastore) { $Details | Add-Member Noteproperty Datastore -Value $Device.Backing.Datastore } 
                    If ($Device.Backing.DeviceName) { $Details | Add-Member Noteproperty DeviceName -Value $Device.Backing.DeviceName } 
                    $Details | Add-Member Noteproperty Connected -Value $Device.Connectable.Connected 
                    $Details | Add-Member Noteproperty StartConnected -Value $Device.Connectable.StartConnected 
                    $Details 
                } 
            } 
        } 
    } 
}

Start_VMWare_PowerCLI
$vCenter="VCENTER_HOST"
Connect_VMWare $vCenter


Write-Host ("VMs con puerto Serie") -ForegroundColor Yellow
Get-VM * | Get-SerialPort | select VM

Write-Host ("VMs con puerto paralelo") -ForegroundColor Yellow
Get-VM * | Get-ParallelPort | select VM

Write-Host ("VMs con dispositivo USB") -ForegroundColor Yellow
Get-VM * | Get-UsbDevice | select parent
