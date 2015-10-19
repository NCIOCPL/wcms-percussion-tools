function Main() {
	# The WebAdministration module requires elevated privileges.
	$isAdmin = Test-Admin
	if( $isAdmin ) {
		Write-Host "Good to go!"
		Import-Module WebAdministration
		GetSiteNames
	} else {
		Write-Host -foregroundcolor 'red' "This script must be run from an AA account."
	}
}


function GetSiteNames {
	# Create output file, overwrite an existing one.
	$OutputFile = GetOutputFilename
	$junk = New-Item -Name $OutputFile -type File -force

	Add-Content $OutputFile -Value "Name`tID`tPath`tbindings"
	Get-WebSite | foreach {
		$text = $_.Name + "`t" + $_.ID + "`t" + $_.physicalPath
		
		$_.bindings.collection | foreach {
			$localText = $text + "`t" + $_
			Add-Content $OutputFile -Value $localText
		}
		
	}

	Write-Host $fn
}

function GetOutputFilename {
	$Computer = Get-WmiObject -Class Win32_ComputerSystem
	return $Computer.Name + ".txt"
}


function Test-Admin {
 $id = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
 $id.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Main