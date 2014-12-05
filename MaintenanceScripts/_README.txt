This folder contains PowerShell scripts used for routine WCMS maintenance activities.

Scripts may be run from either the PowerShell command prompt as "./ScriptName.ps1" or
from the Windows command prompt as "powershell ./ScriptName.ps1"


cdeBackup.ps1		Creates a back up of the CDE code folders.


cdeDeploy.ps1		Deploys CDE code from a set of per-site folders to the matching Preview
					and Live sites.


safeShutdown.ps1	Shuts down the Percussion CMS, stopping the "Percussion Rhythmyx Server"
					and verifying that the underlying java.exe process has also stopped.


safeStartup.ps1		Starts the "Percussion Rhythmyx Server" service.
