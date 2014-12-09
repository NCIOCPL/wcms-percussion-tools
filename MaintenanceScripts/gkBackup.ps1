<#
    $source Location of the GateKeeper files which are being deployed.
#>
param ($source)

$APPLICATION_LIST = @("Admin", "CDRPreviewWS", "WebSvc", "ProcMgr", "XSL", "DTD")
$DEPLOY_BASE = "E:\Content\GateKeeper"
$BACKUP_BASE = "E:\backups-GK"

function Main {

    $subFolder = get-date -uformat "%Y%m%d-%H%M"
    $backupLocation = "$BACKUP_BASE\$subFolder"

    foreach( $app in $APPLICATION_LIST ) {
		$source = "$DEPLOY_BASE\$app"
		$destination = "$backupLocation\$app"
		
		Robocopy $source $destination /mir
    }

    Write-Host -foregroundcolor 'green' "Backed up to $backupLocation."
}


Main