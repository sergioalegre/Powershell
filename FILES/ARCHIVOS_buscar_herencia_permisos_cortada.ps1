#devolverá 'True' en carpetas con herencia cortada. Solamente modificar en la primera línea el directorio a escanear
dir E:\USERS -Directory | get-acl | 
Select @{Name="Path";Expression={Convert-Path $_.Path}},AreAccessRulesProtected |
Format-table -AutoSize
