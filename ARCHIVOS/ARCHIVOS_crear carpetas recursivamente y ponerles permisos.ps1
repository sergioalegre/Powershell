<# 
	1º Mapea la ruta
	
	2º Recorre el directorio actual y :
		Por cada carpeta que encuentre en este nivel (lo hará recursivo) creara un directorio dentro llamado DIR_CHANGE
		despues en las carpetas DIR_CHANGE que la cambie los permisos para 1º romper herencia y 2º Full control a 3 grupos
		
	NOTA:Este script requiere el modulo NTFSSecurity 
		https://gallery.technet.microsoft.com/scriptcenter/1abd77a5-9c0b-4a2b-acef-90dbb2b84e85
		https://www.powershellgallery.com/packages/NTFSSecurity/4.2.3
#>

#mapeamos la unidad de red
net use "M:" "\\server\path" | Out-Null

cd M:

#Por cada carpeta que encuentre en este nivel (no hará recursivo) creara un directorio dentro llamado DIR_CHANGE
Get-ChildItem -Directory | ForEach-Object {New-Item -ItemType directory -Path "$($_.FullName)" -Name "DIR_CHANGE" }


foreach ($dir in Get-ChildItem -Recurse -Directory)
{
	Write-Host "Buscando en " $dir.Name
	
	if("$($dir.Name)" -eq "DIR_CHANGE"  -and (Get-Item "$($dir.FullName)") -is [System.IO.DirectoryInfo] )
	{
		Write-Host "ENCONTRADO" $dir.FullName  -ForegroundColor Yellow
		
		#Asignamos propietario
		Set-NTFSOwner $dir.FullName -Account 'grupoantolin\Domain Admins'
		#Desabilitar herencia
		Disable-NTFSAccessInheritance $dir.FullName
		#Eliminar ACLs anteriores
		Clear-NTFSAccess $dir.FullName
		
		#poner permisos opcion
		Add-NTFSAccess -Path $dir.FullName -Account 'domain\gan_sl_pub-ssgg_c' -AccessRights FullControl
		Add-NTFSAccess -Path $dir.FullName -Account 'domain\hq_sg_server_admin' -AccessRights FullControl
		Add-NTFSAccess -Path $dir.FullName -Account 'domain\Domain Admins' -AccessRights FullControl
    
	}
}


#desconectamos la unidad de red
net use "M:" /DELETE 