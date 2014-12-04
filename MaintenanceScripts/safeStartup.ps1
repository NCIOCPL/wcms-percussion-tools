# Check whether a Java process exists.
$procID = -1
get-process | foreach {if($_.name -eq 'java') {$procID = $_.id}}

# Did Java stop? Or did we just timeout?
If( $procID -ne -1 ) {	
	Write-Host -foregroundcolor 'red'  "A java.exe process is already running. Percussion may not have been shutdown correctly."
	Write-Host -foregroundcolor 'red'  "The Percussion service was NOT restarted."
} else {
	Write-Host -foregroundcolor 'green'  "Restarting the Percussion service."
	start-service -name "Percussion Rhythmyx Server"
	Write-Host -foregroundcolor 'green'  "The Percussion service is running.  It may take several minutes before the UI accepts requests."
}
