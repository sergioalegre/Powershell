(Measure-Command {
  1..10 | ForEach-Object -Parallel {
    Start-Sleep -Seconds 1
    Write-Host $_ -ForegroundColor Yellow
  }
}).TotalMilliseconds