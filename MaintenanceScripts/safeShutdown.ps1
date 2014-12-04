$MAX_DELAY = 300  # Maximum number of seconds to wait before sending a shutdown signal.
$DELAY_INCREMENT = 15 # Number of seconds between checks

write-host "Stopping Percussion Service"
stop-service -name "Percussion Rhythmyx Server"

# Find the Java process if one exists.
$procID = -1
get-process | foreach {if($_.name -eq 'java') {$procID = $_.id}}

$minutes = $MAX_DELAY / 60
Write-Host -foregroundcolor 'green' "Waiting for Percussion Service to shutdown ($minutes minutes maximum)."

$totalDelay = 0
While ( $procID -ne -1 -and $totalDelay -lt $MAX_DELAY) {

	Start-Sleep -s $DELAY_INCREMENT
	$totalDelay = $totalDelay + $DELAY_INCREMENT

	# Check again for running Java process.
	Write-Host -foregroundcolor 'green' "$totalDelay seconds."
	$procID = -1
	get-process | foreach {if($_.name -eq 'java') {$procID = $_.id}}
}

# Did Java stop? Or did we just timeout?
If( $procID -ne -1 ) {	
	Write-Host -foregroundcolor 'red'  "Unleashing the flying monkeys to kill the Java process."
	$env:JAVA_HOME="e:\Rhythmyx\JRE64"
	e:\Rhythmyx\AppServer\bin\jboss_shutdown.bat -s localhost:9993 -H 1
}

Write-Host -foregroundcolor 'green' "Percussion service halted."
Write-Host -foregroundcolor 'green' "Please verify that the java.exe process is not running before restarting."