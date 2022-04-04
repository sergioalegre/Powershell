#Abre de 5 en 5 los ficheros .txt y .bmp que esten en C:\TEST

$location = "C:\TEST"
$i =0
$lista = Get-ChildItem -Recurse -Path $location -File | Where-Object {$_.Extension -eq ".txt" -or $_.Extension -eq ".bmp"}

ForEach ($file in $lista)
{
    $i=$i+1
    Invoke-Item $file.FullName
   
    if ($i -eq 5)
    {
        sleep(5)
        $i=0
    }
}
