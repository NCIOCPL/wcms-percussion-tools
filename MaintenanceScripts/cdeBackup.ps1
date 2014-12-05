<#
    $source Location of the CDE files which are being deployed.
#>
param ($source)

$SITE_LIST = @("CancerGov", "MobileCancerGov", "CCOP", "DCEG", "Imaging", "Proteomics", "TCGA")
$SUBSITE_LIST = @("Preview", "Live")
$DEPLOY_BASE = "c:\temp\deploy"
$BACKUP_BASE = "c:\temp\backup"

function Main {

    $subFolder = get-date -uformat "%Y%m%d-%H%M"
    $backupLocation = "$BACKUP_BASE\$subFolder"

    foreach( $site in $SITE_LIST ) {


        foreach( $subsite in $SUBSITE_LIST ) {

            $source = "$DEPLOY_BASE\$site\$subsite\code"
            $destination = "$backupLocation\$site\$subsite\code"
            
            Robocopy $source $destination /mir
        }
    }

    Write-Host -foregroundcolor 'green' "Backed up to $backupLocation."
}



Main