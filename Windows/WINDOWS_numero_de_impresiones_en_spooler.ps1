#Scope: este script comprueba el nº de archivos en el spooler alertando si hay mas de 1000

###Highlights:
# - invocar comando remoto mediante sesion
# - Test-Connection


$vCenter = <vCenter_Server>
Import-module vmware.vimautomation.core
Connect-VIServer -Server $vCenter


$lista= Get-VM | Where { $_.Name -like "*SERVER_CON_SPPOLER*"} | Sort -Property Name
Write-Host "How many BLD servers we have: " $lista.Count
foreach ($vm in $lista){
    if(Test-Connection -Computername $vm -BufferSize 16 -Count 1 -Quiet)
    {
        $ses = New-PSSession -ComputerName $vm            
        $contador=@();
        $contador = Invoke-Command -Session $ses -ScriptBlock { Get-ChildItem C:\Windows\System32\spool\PRINTERS }
        Remove-PSSession $ses
        if($contador.Count -gt 1000){
            Write-Host $vm tiene $contador.Count impresiones -ForegroundColor Red
            continue
        }
        else {
            Write-Host $vm tiene $contador.Count impresiones -ForegroundColor Green
        }
    }
}