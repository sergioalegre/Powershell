#Por cada carpeta que encuentre recursivamente creará un txt con el mismo nombre de la carpeta
Get-ChildItem -Recurse -Directory | ForEach-Object {New-Item -ItemType file -Path "$($_.FullName)" -Name "$($_.Name).txt" }

#Por cada carpeta que encuentre en este nivel (no hará recursivo) creara otro directorio dentro con el mismo nombre
Get-ChildItem -Directory | ForEach-Object {New-Item -ItemType directory -Path "$($_.FullName)" -Name "$($_.Name)" }

#Por cada carpeta que encuentre en este nivel (no hará recursivo) creara un directorio dentro llamado HQ_INFR
Get-ChildItem -Directory | ForEach-Object {New-Item -ItemType directory -Path "$($_.FullName)" -Name "HQ_INFR" }