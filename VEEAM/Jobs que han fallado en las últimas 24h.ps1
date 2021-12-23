#Enter-PSSession GANVMBEM01 –Credential DOMAIN\user
Add-PsSnapIn VeeamPSSnapIn #invocamos cmdlets de Veeam

Get-VBRJob | ? {($_.Info.ScheduleOptions.LatestRun -ge (Get-Date).addhours(-24)) -and ($_.GetLastResult() -eq "Failed")} | Select-Object -Property @{N="Name";E={$_.Name}} , @{N="Objects in Job";E={$_.GetViOijs().Name}} , @{N="Description";E={$_.Description}} | Sort Name -Descending | Format-Table

#Exit-PSSession