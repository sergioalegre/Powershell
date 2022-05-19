###Objetivo: Filewatcher es un componente de Windows. En este caso cuando un archivo aparece en una carpeta, la copia a Azure

##set watcher.Path to match the folder you want to monitor
##watcher.Filter to be set to wildcard, you can exclude file types from ### filesystemwatcher exclude files section
##watcher.IncludeSubdirectories to be true, you can exclude directories from ### filesystemwatcher exclude directory section

$DestinationFolder = "\\mystorageaccount.file.core.windows.net\nombre_share"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = “C:\prueba\”
$watcher.Filter = “*.*”
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true


#what to do when a event is detected
$action = {
    $s=Get-Date
    $fileName = Split-Path $Event.SourceEventArgs.FullPath -leaf
    $path = $Event.SourceEventArgs.FullPath
    Write-Host "new file $($fileName) in the path $($path) to $($DestinationFolder)"
    Copy-Item $path -Destination $DestinationFolder
    $e=Get-Date
    $ti = ($e - $s).TotalSeconds
    Write-Host "Copied in $($ti) seconds"
}

#what events to be watched
Register-ObjectEvent $watcher “Created” -Action $action
#Register-ObjectEvent $watcher “Changed” -Action $action
#Register-ObjectEvent $watcher “Deleted” -Action $action
#Register-ObjectEvent $watcher “Renamed” -Action $action
while ($true) {sleep 0.1}