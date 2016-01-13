<#
    $source Location of the CDE files which are being deployed.
#>
param ($source)

$SITE_LIST = @("CancerGov", "MobileCancerGov", "DCEG", "Imaging", "Proteomics", "TCGA")
$SUBSITE_LIST = @("Preview", "Live")
$DEPLOY_BASE = "E:\Content\PercussionSites\CDESites"

function Main ($sourceLocation) {
    if( -not $sourceLocation ) {
        Write-Host ""
        Write-Host -foregroundcolor "green" "You must specify the location of the CDE files to deploy."
        Write-Host ""
        exit
    }

    ValidateLocation $sourceLocation
    Deploy $sourceLocation
    Write-Host -foregroundcolor 'green' "Deployment completed."
}


function Deploy ($sourceLocation) {

    foreach( $site in $SITE_LIST ) {

        $source = "$sourceLocation\$site"

        foreach( $subsite in $SUBSITE_LIST ) {
            $destination = "$DEPLOY_BASE\$site\$subsite\code"
            
            Robocopy $source $destination /mir /xf *.config robots.txt *.pdb /xd localConfig
        }
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
        foreach( $site in $SITE_LIST ) {
            $location = "$sourceLocation\$site"

            $exists = Test-Path $location
            if( $exists )  {
                # Check for presence of files in source location.
                $location = $location + "\*"
                $exists = Test-Path $location
                if( -not $exists ) { $errors = $errors + "$location contains no files to deploy." }
            } else {
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
        foreach( $site in $SITE_LIST ) {
            foreach( $subsite in $SUBSITE_LIST ) {
                $location = "$DEPLOY_BASE\$site\$subsite\code"
                $exists = Test-Path $location
                if( -not $exists ) {$errors = $errors + "Deployment location $location not found."}
            }
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