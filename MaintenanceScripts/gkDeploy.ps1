<#
    $source Location of the GateKeeper files which are being deployed.
#>
param ($source)

$APPLICATION_LIST = @("Admin", "CDRPreviewWS", "WebSvc", "ProcMgr", "XSL")
$DEPLOY_BASE = "E:\Content\GateKeeper"

function Main ($sourceLocation) {
    if( -not $sourceLocation ) {
        Write-Host ""
        Write-Host -foregroundcolor "green" "You must specify the location of the CDE files to deploy."
        Write-Host ""
        exit
    }

    ValidateLocation $sourceLocation
	Stop-Service "GateKeeper Process Manager"
    Deploy $sourceLocation
	Start-Service "GateKeeper Process Manager"
    Write-Host -foregroundcolor 'green' "Deployment completed."
}


function Deploy ($sourceLocation) {

    foreach( $app in $APPLICATION_LIST ) {

        $source = "$sourceLocation\$app"
		$destination = "$DEPLOY_BASE\$app"
		
		Robocopy $source $destination /mir /xf *.config robots.txt *.pdb
    }

}


function ValidateLocation ($sourceLocation) {
    $errors = @()

    # Check that source location exists
    $exists = Test-Path $sourceLocation
    if( -not $exists ) {
        $errors = $errors + "Location $sourceLocation not found."
    } else {
        # Check for per-site source folders
        foreach( $app in $APPLICATION_LIST ) {
            $location = "$sourceLocation\$app"
            $exists = Test-Path $location
            if( -not $exists )  {
                $errors = $errors + "$location not found."
            }
        }
    }


    # Check that destination exists.
    $exists = Test-Path $DEPLOY_BASE
    if( -not $exists ) {
        $errors = $errors + "Deployment base location $DEPLOY_BASE not found."
    } else {
        # Check for per-site destinations.    
        foreach( $app in $APPLICATION_LIST ) {
			$location = "$DEPLOY_BASE\$app"
			$exists = Test-Path $location
			if( -not $exists ) {$errors = $errors + "Deployment location $location not found."}
        }
    }


    # Report errors
    if($errors.length -gt 0) {
       $errors | Foreach {Write-Host -foregroundcolor 'yellow' $_}
       exit
    } else {
        Write-Host -foregroundcolor 'green' "Location validation passed."
    }
}


Main $source