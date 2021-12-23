#Requires -RunAsAdministrator

write-host 'Sincronizacion carpetas con Robocopy' -ForegroundColor red -BackgroundColor white 
write-host '-----------------------------------' -ForegroundColor red -BackgroundColor white 

$ruta = Read-Host -Prompt 'Introduce RUTA COMPLETA (ej: \\servidor\directorio_a_copiar)'
$destino = Read-Host -Prompt 'Introduce RUTA COMPLETA DESTINO DE LA COPIA (ej: d:\backup)'


$directorios = cmd /c "dir /b $ruta"


foreach($var in $directorios)
{
    #write-host Robocopy $ruta'\'$var $destino'\'$var /E /SEC /MIR /R:1 /W:1 /MT:48 /v /LOG:$var'.txt'
    write-host Robocopy $ruta'\'$var $destino\$var /E /SEC /MIR /R:1 /W:1 /MT:48 /v /LOG:$var'.txt'
    Robocopy $ruta'\'$var $destino\$var /E /SEC /MIR /R:1 /W:1 /MT:48 /v /LOG:$var'.txt'
}



