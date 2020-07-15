##BORRAR FICHEROS DE MAS DE 15 DIAS EN UN PATH CONCRETO##

  #Variables
  $path = “\\SERVER_NAME\Share$\”
  $limit = (Get-Date).AddDays(-15)
  #Código
  Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
  #borrar directorios que hayan quedado vacios
  Get-ChildItem $path -Recurse | Where-Object {$_.PSIsContainer -eq $True} | Where-Object {($_.GetFiles().Count -lt 1 -and $_.GetDirectories().Count -lt 1)} | Select-Object FullName | ForEach-Object {Remove-Item $_.fullname -Recurse}


