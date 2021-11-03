#Note: better run this via Azure Cloud Shell, otherwise use Connect-AzAccount. The amounth of RAM is proportional to blobs number

#variables
$StorageAccount = "XXX"
$contenedor = "XXX"
$StorageAccountKey = "XXX"
#$URI = "000/000/A1C0000000118.jpg"


#higlights: | Where-Object


#comandos útiles
#$todos_los_blobs[0].BlobProperties.AccessTier #saber nivel de tier
#$todos_los_blobs[0].BlobBaseClient | Select Uri #saber URI completa
#$todos_los_blobs[0].BlobBaseClient | Select Name #saber la ruta dentro del contenedor
#Get-AzStorageBlob -Container $containername -Context $context -Blob $URI | FT -AutoSize 
#formato de la URI $URI = "000/000/A1C0000000118.jpg"


#contexto
$context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountKey


#listar blobs de ese proyecto
$todos_los_blobs = Get-AzStorageBlob -Container $contenedor -Context $context #tarda unos 20 minutos para 1.000.000 objetos (35Gb)
$blobs_concretos_este_proyecto=@();
$blobs_concretos_este_proyecto = $todos_los_blobs | Where-Object {$_.BlobBaseClient.Uri -like "*248118.jpg"}
$cuantos = $blobs_concretos_este_proyecto.Count
Write-Host "Voy a desarchvar"$cuantos" blobs" -ForegroundColor Yellow

#ver el tier de los blobs del proyecto
$blobs_concretos_este_proyecto | %{
    $blobs_concretos_este_proyecto.BlobProperties.AccessTier
}

#desarchivar blob del proyecto
$blobs_concretos_este_proyecto.ICloudBlob.SetStandardBlobTier("Cool")


#Download blobs de un proyecto
$blobs_concretos_este_proyecto | %{
    Get-AzureStorageBlobContent -Container $contenedor -Blob $_.Name -Destination "C:\blobs_recuperados\" -Context $StorageAccount.Context
}