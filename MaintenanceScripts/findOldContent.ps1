# Finds content older than a given date.
Write-Host -foregroundcolor 'red' "Update the hard-coded date and remove this line before running."
Get-ChildItem -recurse .\ | ? {$_.PSIsContainer -eq $false -and $_.LastWriteTime -le '8/18/2014 9:00 pm'} | % { $_.FullName }