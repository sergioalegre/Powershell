### Este sctript busca todas las unidades locales (que no sean de red) y las hace un defrag

#nos copiamos el sdelete
Invoke-Expression -Command "cp \\SERVER\c$\sdelete64.exe C:\"

#saber las letras de unidad locales
$unidades = @()
$unidades = ([System.IO.DriveInfo]::getdrives() | Where-Object {$_.DriveType -eq 'Fixed'}).name

foreach ($unidad in $unidades)
{
  #defrag
  $letra = $unidad.split(':')
  Optimize-Volume -DriveLetter $letra -ReTrim -Verbose
  Optimize-Volume -DriveLetter $letra -SlabConsolidate -Verbose
  Optimize-Volume -DriveLetter $letra -Defrag -Verbose
  if ($letra -eq "\")
  {
    continue
  }
  else
  {
    #UNMAP
    $letra = $letra+":"
    #Invoke-Expression -Command "C:\sdelete64.exe -z $letra -accepteula"
  }
}

# comandos para saber si se notifica la liberacion de bloques
# fsutil behavior query DisableDeleteNotify
# fsutil behavior set DisableDeleteNotify 1
