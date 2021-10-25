﻿$IncludeStates = '^(Disc)$' # Only DISCONNECTED sessions

function Get-Sessions
{
    # `query session` is the same as `qwinsta`
    # `query session`: http://technet.microsoft.com/en-us/library/cc785434(v=ws.10).aspx

    # Possible session states:
    #http://support.microsoft.com/kb/186592
    #Disc.   The session is disconnected.
    #Active. The session is connected and active.
    #Conn.   The session is connected. No user is logged on.
    #ConnQ.  The session is in the process of connecting. If this state continues, it indicates a problem with the connection.
    #Shadow. The session is shadowing another session.
    #Listen. The session is ready to accept a client connection.
    #Idle.   The session is initialized.
    #Down.   The session is down, indicating the session failed to initialize correctly.
    #Init.   The session is initializing.

    # Snippet from http://poshcode.org/3062
    # Parses the output of `qwinsta` into PowerShell objects.
    $c = query session 2>&1 | where {$_.gettype().equals([string]) }

    $starters = New-Object psobject -Property @{"SessionName" = 0; "Username" = 0; "ID" = 0; "State" = 0; "Type" = 0; "Device" = 0;};
     
    foreach($line in $c) {
         try {
             if($line.trim().substring(0, $line.trim().indexof(" ")) -eq "SESSIONNAME") {
                $starters.Username = $line.indexof("USERNAME");
                $starters.ID = $line.indexof("ID");
                $starters.State = $line.indexof("STATE");
                $starters.Type = $line.indexof("TYPE");
                $starters.Device = $line.indexof("DEVICE");
                continue;
            }
           
            New-Object psobject -Property @{
                "SessionName" = $line.trim().substring(0, $line.trim().indexof(" ")).trim(">")
                ;"Username" = $line.Substring($starters.Username, $line.IndexOf(" ", $starters.Username) - $starters.Username)
                ;"ID" = $line.Substring($line.IndexOf(" ", $starters.Username), $starters.ID - $line.IndexOf(" ", $starters.Username) + 2).trim()
                ;"State" = $line.Substring($starters.State, $line.IndexOf(" ", $starters.State)-$starters.State).trim()
                ;"Type" = $line.Substring($starters.Type, $starters.Device - $starters.Type).trim()
                ;"Device" = $line.Substring($starters.Device).trim()
            }
        } catch {
            throw $_;
        }
    }
}

$IncludedSessions = Get-Sessions `
                        | Where { $_.State -match $IncludeStates } `
                        | Select -ExpandProperty ID

$session=@();
foreach ($session in $IncludedSessions){
    if ($session -ne 0){
        RESET SESSION $session
    }
}