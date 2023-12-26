foreach ($num in 10..1)
{
  Write-Information -MessageData $num -InformationAction Continue
  Start-Sleep -Seconds 1
}
