#Aiging a los 15 días
$path = “\\server\S$\”
$limit = (Get-Date).AddDays(-15)
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
#borrar directorios vacios
Get-ChildItem $path -Recurse | Where-Object {$_.PSIsContainer -eq $True} | Where-Object {($_.GetFiles().Count -lt 1 -and $_.GetDirectories().Count -lt 1)} | Select-Object FullName | ForEach-Object {Remove-Item $_.fullname -Recurse}
