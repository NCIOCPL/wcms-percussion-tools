This folder contains PowerShell scripts used for routine WCMS maintenance activities.

Scripts may be run from either the PowerShell command prompt as "./ScriptName.ps1" or
from the Windows command prompt as "powershell ./ScriptName.ps1"


safeShutdown.ps1	Shuts down the Percussion CMS, stopping the "Percussion Rhythmyx Server"
					and verifying that the underlying java.exe process has also stopped.


safeStartup.ps1		Starts the "Percussion Rhythmyx Server" service.
