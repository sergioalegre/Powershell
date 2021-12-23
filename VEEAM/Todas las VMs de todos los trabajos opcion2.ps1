$credential = get-credential
$sesion= New-PSSession VEEAM_SERVER_NAME -credential $credential

Invoke-Command -Session $sesion -ScriptBlock {

    Add-PsSnapIn VeeamPSSnapIn #invocamos cmdlets de Veeam

    $trabajos = Get-VBRJob | sort -property Name

    foreach ($job in $trabajos) {
       $jobOptions = New-Object PSObject
   
       $Objects = $Job | Get-VBRJobObject 
   
       $jobOptions | Add-Member -MemberType NoteProperty -Name "Name" -value $job.name
       $jobOptions | Add-Member -MemberType NoteProperty -Name "Objects" -value $Objects.name
       $jobOptions | Add-Member -MemberType NoteProperty -Name "Type" -value $job.JobType
   
       $jobOptions
    }
}

Exit-PSSession