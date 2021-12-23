#El script busca dentro de una carpeta recursivamente archivos de varias extensiones, los abre de 5 en 5 esperando 2 segundos en cada iteracion.

$location = "C:\TEST"
$i =0
$lista = Get-ChildItem -Recurse -Path $location -File | Where-Object {$_.Extension -eq ".txt" -or $_.Extension -eq ".bmp"}

ForEach ($file in $lista)
{
    $i=$i+1
    Invoke-Item $file.FullName
   
    if ($i -eq 5)
    {
        sleep(2)
        $i=0
    }
}