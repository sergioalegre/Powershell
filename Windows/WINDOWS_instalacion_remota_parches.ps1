# ESTE SCRIPT NECESITA UN PARAMETRO AL INVOCARLE 
# ESE PARAMETRO ES LA RUTA COMPLETA A UN ARCHIVO DE TEXTO CON NOMBRES DE VMS A PARCHEAR EN LA MISMA RUTA QUE EL SCRIPT
# EN BASE A CADA SISTEMA OPERATIVO SE EJECUTA UN HOTFIX CONCRETO DESDE UNA RUTA QUE ESTA DENTRO DEL BLOQUE switch
# EL SCRIPT PERMITE REINICIAR O NO REINICIAR AL ACABAR COMENTANDO Y/O DESCOMENTANDO LAS LÍNEAS 59 Y 60


# Archivo con las máquinas a parchear
    $filename = $args[0]

    if ($filename -eq $null){
        echo "This script requires a list of VM to work. .\instalacion_remota_parches.ps1 C:\<path>\filename"
        exit
    }

# Credential for remote powershell
    $password = "Ant0Lin001" | ConvertTo-SecureString -asPlainText -Force
    $PSCred = New-Object System.Management.Automation.PSCredential('grupoantolin\hq_adminsg06',$password)

$file = [System.IO.File]::OpenText($filename)
while($null -ne ($vm = $file.ReadLine())) {
    echo "Opening remote powershell session to $vm ..."
    $ses = New-PSSession -ComputerName $vm
    $Object = Invoke-Command -Session $ses {
        $WinVer = ((Get-CimInstance Win32_OperatingSystem).version).Split(".")
        $OS = $WinVer[0]+"."+$WinVer[1]
        echo $OS
        switch($OS){
            6.3 { 
                echo "W2K12 R2"
                $hotfix = get-hotfix -id KB4012216 -ea 0
                $binpath = "\\gannsinf01\software\M17-010\Windows_2012R2\"
            }
            6.2 { 
                echo "W2K12"
                $hotfix = get-hotfix -id KB4012217 -ea 0
                $binpath = "\\gannsinf01\software\M17-010\Windows_2012\"
            }
            6.1 { 
                echo "W2K8"
                $hotfix = get-hotfix -id KB4012215 -ea 0
                $binpath = "\\gannsinf01\software\M17-010\Windows_2008_R2\"
            }
        }
        # If not installed
        if ($hotfix -eq $null){
            echo "Hotfix need to be installed"
            return $binpath
        }
    }
    $bin = $Object[3]
    echo "start copying binaries..."
    echo "From: $bin"
    $remotepath='\\'+$vm+'\c$\KB\'
    echo "To: $remotepath"
    xcopy $Object[3] $remotepath /F /S
    

    #REINICIAR O NO REINICIAR COMENTAR LA LINEA QUE NO INTERESE
        winrs -r:$vm dism.exe /online /add-package /PackagePath:C:\KB\Windows.cab /norestart
        #winrs -r:$vm dism.exe /online /add-package /PackagePath:C:\KB\Windows.cab /restart


    Remove-PSSession $ses
    exit
    }