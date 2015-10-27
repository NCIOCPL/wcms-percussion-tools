<#
	Removes web sites from IIS and optionally deletes the site's physical folder code,
	associated AppPool and additional content directories.

	Site Removal

		Every site to be removed receives an entry in the <SiteList> structure.
		Set the attribute values as follows:
		
		name (required) - Contains the site's name from IIS configuration. (Not the host name.)
						  The sitelist powershell script can provide a list of valid site name's.

	    removeFiles (optional) - Controls deletion of the site's physical folder.  Set to one (1)
								to delete.
								
		removeAppPool (optional) - Controls deletion of the site's AppPool.  Set to one (1)
								to delete.


	Removing Additonal Directories

		Directories outside a site's direct file tree (e.g. the "PublishedContent" folder
		associated with a WCMS site) may be deleted by listing them as entries in the
		<DirectoryList> structure.

#>
$siteList = [xml]@"
<SiteList>
	<Site name="site1" />
	<Site name="site2" removeFiles="1" removeAppPool="1" />
	<Site name="site3" />
</SiteList>
"@

$directoryList = [xml]@"
<DirectoryList>
	<path>C:\svn\wcmteam\cde\siteCont\site1</path>
	<path>C:\svn\wcmteam\cde\siteCont\site2</path>
</DirectoryList>
"@


function Main() {
	# The WebAdministration module requires elevated privileges.
	$isAdmin = Is-Admin
	if( $isAdmin ) {
		Write-Host -foregroundcolor 'green' "Starting..."
		Import-Module WebAdministration

		# Delete sites.
		foreach($site in $siteList.SiteList.Site) {
			RemoveSite $site.name $site.removeFiles $site.removeAppPool
		}

		# Delete extra paths
		foreach($path in $directoryList.Directorylist.path) {
			RemovePath $path
		}
		
	} else {
		Write-Host -foregroundcolor 'red' "This script must be run from an AA account."
	}
}

<#
	Remove $siteName from IIS.
	
	$siteName - IIS name for the site to be removed.

	$removeFiles - If set to one (1), the site's physical directory is removed as well.
					(All other $removeFiles values are ignored.)

	$removeAppPool - If set to one (1), the site's associated AppPool is removed.
					(All other $removeFiles values are ignored.)
#>
function RemoveSite($siteName, $removeFiles, $removeAppPool) {

	Write-Host "Deleting $siteName."
	
	# Get-WebSite always returns an array.
	$details = GetSiteDetails $siteName
	
	if( $details -ne $null ) {

		Stop-Website $details.Name

		if( $removeFiles -eq 1 ) {
			Write-Host "Removing Site Folder."
			RemovePath $details.physicalPath
		} else {
			Write-Host "Skipping Site Folder."
		}
		
		if( $removeAppPool -eq 1 ) {
			Write-Host "Removing AppPool " $details.applicationPool "."
			Stop-WebAppPool $details.applicationPool
			Remove-WebAppPool $details.applicationPool
		} else {
			Write-Host "Skipping AppPool."
			# If we're not removing the AppPool, bounce it.
			Restart-WebAppPool $details.applicationPool
		}
		
		# Remove the acutal site.
		Remove-WebSite $siteName
	} else {
		Write-Host -foreground 'red' "Site $siteName not found."
	}
}

<#
	Removes the directory $deletePath and all everything below it.
#>
function RemovePath($deletePath) {

	if( $deletePath -ne $null ) {
		Write-Host 'Removing' $deletePath
		Remove-Item $deletePath -Recurse -Force
	} else {
		Write-Host -foregroundcolor 'red' "RemovePath: Path must not be null."
	}
}

<#
	Looks up IIS details for the site specified in $siteName.
	Returns null if the site is unknown.
#>
function GetSiteDetails( $siteName ) {
	# In PowerShell 2, Get-WebSite returns information for *all* sites, regardless of whether a
	# name is supplied, so we have to do the filtering ourselves. Web site names are unique,
	# and this is an "equals" check, so there's no way the filter will return more than one result.
	$details = Get-WebSite | where {$_.Name -eq $siteName}
	if($details -ne $null) {
		return $details
	} else {
		return $null
	}
}

<#
	Verify that the currently logged in user has administrator access.
#>
function Is-Admin {
 $id = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
 $id.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Main