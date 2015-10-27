<#
	Removes web sites from IIS and optionally deletes the site's code and content directories
	as well as the associated AppPool.
	
	Setup: Each site receives an entry in the <SiteList> structure.  Set the
		attribute values as follows:
		
		name (required) - Contains the site's name from IIS configuration. (Not the host name.)
						  The sitelist script can provide a list of valid site name's.

	    removeFiles (optional) - Controls deletion of the site's physical folder.  Set to one (1)
								to delete.
								
		removeAppPool (optional) - Controls deletion of the site's AppPool.  Set to one (1)
								to delete.
#>
$siteList = [xml]@"
<SiteList>
	<Site name="site1" />
	<Site name="site2" removeFiles="1" />
	<Site name="site3" />
</SiteList>
"@




function Main() {
Write-Host -foregroundcolor 'red' "Still in development.  Not ready for use."
return;

	# The WebAdministration module requires elevated privileges.
	$isAdmin = Is-Admin
	if( $isAdmin ) {
		Write-Host -foregroundcolor 'green' "Starting..."
		Import-Module WebAdministration

		# Delete sites.
		foreach($site in $siteList.SiteList.Site) {
			RemoveSite $site.name $site.removeFiles
		}

	} else {
		Write-Host -foregroundcolor 'red' "This script must be run from an AA account."
	}
}

<#
	Remove $siteName from IIS.  If $removeFiles is set to one (1), the site's physical path
	is removed as well. (All other $removeFiles values are ignored.)
#>
function RemoveSite($siteName, $removeFiles) {

	Write-Host "Deleting $siteName."
	
	# Get-WebSite always returns an array.
	$details = GetSiteDetails $siteName
	
	if( $details -ne $null ) {
		if($removeFiles -eq 1) {
			Write-Host "Removing Site Folder."
			RemoveFiles $details.physicalPath
		} else {
			Write-Host "Skipping Site Folder."
		}
		
		Remove-WebSite $siteName
	} else {
		Write-Host -foreground 'red' "Site $siteName not found."
	}
}

<#
	Removes the directory $deletePath and all everything below it.
#>
function RemoveFiles($deletePath) {

	if( $deletePath -ne $null ) {
		Write-Host 'Removing' deletePath
		Remove-Item $deletePath -Recurse -Force
	} else {
		Write-Host -foregroundcolor 'red' "RemoveFiles: Path must not be null."
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