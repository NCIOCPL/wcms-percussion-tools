# Constants
$RX_BASE = "E:\Rhythmyx"
$RX_TMP = "$RX_BASE\AppServer\server\rx\tmp"
$RX_DATA = "$RX_BASE\AppServer\server\rx\data"
$RX_WORK = "$RX_BASE\AppServer\server\rx\work"

Function Main {
	SuppressPrompts
	$percIsRunning = PercussionIsRunning
	
	If( $percIsRunning ) {
		ReportAlreadyRunning
	} else {
		DeleteTemporaryFiles
		StartPercussion
	}
}

Function PercussionIsRunning {
	# Check whether a Java process exists.
	$foundJava = $False
	get-process | foreach {if($_.name -eq 'java') {$foundJava = $True}}
	
	return $foundJava
}

Function StartPercussion {
	Write-Host -foregroundcolor 'green'  "Starting the Percussion service."
	start-service -name "Percussion Rhythmyx Server"
	Write-Host -foregroundcolor 'green'  "The Percussion service has been started.  It may take several minutes before the UI accepts requests."
}

Function DeleteTemporaryFiles {
	Write-Host -foregroundcolor 'green'  "Deleting temporary files."

	# E:\Rhythmyx\dbg_* (files only)
	Get-ChildItem $RX_BASE -filter "dbg_*" | Where-Object { -not $_.PSIsContainer } | Remove-Item

	# E:\Rhythmyx\.sys_* (directories only)
	Get-ChildItem $RX_BASE -filter ".sys_*" | Where-Object { $_.PSIsContainer } | Remove-Item

	# Remove all contents of E:\Rhythmyx\AppServer\server\rx\temp, data and work folders.
	Remove-Item "$RX_TMP\*" -Recurse
	Remove-Item "$RX_DATA\*" -Recurse
	Remove-Item "$RX_WORK\*" -Recurse
}

Function ReportAlreadyRunning {
	Write-Host -foregroundcolor 'red'  "A java.exe process is already running. Percussion may not have been shutdown correctly."
	Write-Host -foregroundcolor 'red'  "The Percussion service was NOT restarted."
}

Function SuppressPrompts {
	$ConfirmPreference = "None"
}

Main