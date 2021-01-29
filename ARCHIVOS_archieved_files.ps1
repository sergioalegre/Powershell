#Los ficheros archivados tienen el atributo Offile y tienen un tamaño en disco 0

# La variable $carpeta es la ruta a escanear recursivamente
# ROJO: si el archivo tiene el atributo offline pero no tiene tamaño en disco 0
# AMARILLO: si no tiene el atributo offline (no esta archivado)
# VERDE: si tiene el atributo Offline y su tamaño en disco en 0



cls
$carpeta = @()
$carpeta = 'E:\PUBLIC\Pub-Engineering\'

$source = @"
 using System;
 using System.Runtime.InteropServices;
 using System.ComponentModel;
 using System.IO;

 namespace Win32
  {

    public class Disk {

    [DllImport("kernel32.dll")]
    static extern uint GetCompressedFileSizeW([In, MarshalAs(UnmanagedType.LPWStr)] string lpFileName,
    [Out, MarshalAs(UnmanagedType.U4)] out uint lpFileSizeHigh);

    public static ulong GetSizeOnDisk(string filename)
    {
      uint HighOrderSize;
      uint LowOrderSize;
      ulong size;

      FileInfo file = new FileInfo(filename);
      LowOrderSize = GetCompressedFileSizeW(file.FullName, out HighOrderSize);

      if (HighOrderSize == 0 && LowOrderSize == 0xffffffff)
       {
	 throw new Win32Exception(Marshal.GetLastWin32Error());
      }
      else {
	 size = ((ulong)HighOrderSize << 32) + LowOrderSize;
	 return size;
       }
    }
  }
}

"@

Add-Type -TypeDefinition $source

$archivados = 0
$no_archivados = 0
$raros = 0


foreach( $fichero in Get-ChildItem $carpeta -Recurse)
{
    if (((Get-ItemProperty $fichero.FullName).attributes) -like '*Offline*')
    {
        $tamano = (Get-Item $fichero.FullName).length
        $tamano_disco = [Win32.Disk]::GetSizeOnDisk($fichero.FullName)
        if ($tamano_disco -eq 0)
        {
            Write-Host "El fichero" $fichero "SI esta archivado, tamaño" $tamano " tamaño en disco" $tamano_disco -ForegroundColor Green
            $archivados=$archivados+1

        }
        else
        {
            Write-Host "El fichero" $fichero "SI esta archivado, tamaño" $tamano " PERO EL TAMAÑO EN DISCO ES" $tamano_disco -ForegroundColor Red
            $raros=$raros+1
        }
    }
    else
    {
        $tamano2 = (Get-Item $fichero.FullName).length
        $tamano_disco2 = [Win32.Disk]::GetSizeOnDisk($fichero.FullName)
        Write-Host "El fichero" $fichero "NO esta archivado, tamaño" $tamano2 " tamaño en disco" $tamano_disco2 -ForegroundColor Yellow
        $no_archivados=$no_archivados+1
    }
}

$total=$archivados+$no_archivados+$raros
Write-Host "---------------------------------------------------"
Write-Host  "---" $total "ficheros analizados en" $carpeta "---"
Write-Host "Total de ficheros ARCHIVADOS en esta ruta" $archivados  -ForegroundColor Green
Write-Host "Total de ficheros NO archivados en esta ruta" $no_archivados  -ForegroundColor Yellow
Write-Host "Total de ficheros RAROS en esta ruta" $raros  -ForegroundColor Red
