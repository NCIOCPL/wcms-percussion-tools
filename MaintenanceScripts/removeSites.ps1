<#
	Removes web sites from IIS and optionally deletes the site's code and content directories
	as well as the associated AppPool.
	
	Setup: Each site receives an entry in the <SiteList> structure.  Set the
		attribute values as follows:
		
		name (required) - Contains the site's name from IIS configuration. (Not the host name.)
						  The sitelist script can provide a list of valid site name's.

	    removeCode (optional) - Controls deletion of the site's physical folder.  Set to zero (0)
								to suppress deletion.
								
		removeContent (optional) - Controls deletion of the site's content folder.  Set to zero (0)
								to suppress deletion.  See $contentFolderBase (below) for more information.
								
		removeAppPool (optional) - Controls deletion of the site's AppPool.  Set to zero (0)
								to suppress deletion.
#>
$siteList = [xml]@"
<SiteList>
	<Site name="site1" removeCode="0" removeContent="0" removeAppPool="0" />
	<Site name="site2" />
</SiteList>
"@

$contentFolderBase="C:\svn\wcmteam\cde\siteCont"

function Main() {
Write-Host -foregroundcolor 'red' "Still in development.  Not ready for use."
return;

	# The WebAdministration module requires elevated privileges.
	$isAdmin = Is-Admin
	if( $isAdmin ) {
		Write-Host -foregroundcolor 'green' "Starting..."
		Import-Module WebAdministration

		foreach($site in $siteList.SiteList.Site) {
			DoRemoval $site.name $site.removeCode $site.removeContent $site.removeAppPool
		}

	} else {
		Write-Host -foregroundcolor 'red' "This script must be run from an AA account."
	}
}

function DoRemoval($siteName, $removeCode, $removeContent, $removeAppPool) {

	Write-Host "Deleting $siteName."
	
	# Get-WebSite always returns an array.
	$details = GetSiteDetails $siteName

	if($removeCode -ne 0) {
		Write-Host "Removing Code Folder."
		RemoveCode $details
	} else {
		Write-Host "Skipping Code Folder."
	}
	
	Remove-WebSite $siteName
}

function RemoveCode($siteDetails) {

	if( $siteDetails -ne $null ) {
		if( $siteDetails.physicalPath -ne $null ) {
			Write-Host 'Removing' $siteDetails.physicalPath
			Remove-Item $siteDetails.physicalPath -Recurse -Force
		} else {
			Write-Host -foregroundcolor 'red' "No physical path data available for " $siteDetails.Name
		}
	}
}

function GetSiteDetails( $siteName ) {
	# In PowerShell 2, Get-WebSite returns information for *all* sites, regardless of whether a
	# name is supplied, so we have to do the filtering ourselves. Web site names are unique,
	# and this is an "equals" check, so there's no way the filter will return more than one result.
	$details = Get-WebSite | where {$_.Name -eq $siteName}
	if($details -ne $null) {
		return $details
	} else {
		Write-Host -foregroundcolor 'red' "No Details available for $siteName."
		return $null
	}
}

function Is-Admin {
 $id = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
 $id.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Main