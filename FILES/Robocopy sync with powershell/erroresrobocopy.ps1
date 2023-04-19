#Requires -RunAsAdministrator

write-host Gestion Errores Antolin
$error = Read-Host -Prompt 'Introduce cadena de texto a buscar por ej: ERROR'

$out = Read-Host -Prompt 'Introduce fichero de salida:'



get-content *.txt | Select-String $error > $out  