##
## This script is meant to run after the Nightly Full Publishing jobs

function showUsage {
	write-host ""
	write-host "usage: PageInstructionOlderFileCheck.ps1 <site-name> <Live|Preview>"
	write-host "	site-name: The name of the site to check. Something like CancerGov or TCGA"
	write-host "	Live|Preview: Live to check the live site content, Preview to check the preview site content."
	write-host ""
}

####### Check Arguments
if ((($args[0] -eq "-help") -OR ($args[0] -eq "--help") -OR ($args[0] -eq "/?")) -OR ($args.length -ne 2)) {
	showUsage
	break
}

$site_name = $args[0]
$live_or_prev = $args[1]

$publishedContentPath = "E:\publishing\PercussionSites\CDESites\${site_name}\${live_or_prev}\PublishedContent\PageInstructions"
$publishDate = Get-Date -format "yyyyMMdd"
$fileCollection = @{};

foreach ($file in Get-ChildItem -Path $publishedContentPath -Recurse -Include *.xml) {

	## Get Information about the file for outputting
	$fileFullName = $file.FullName
	$fileName = $file.Name
	$fileLastWrite = $file.LastWriteTime.ToString("yyyyMMdd")

	##Save Off the file info
	$fileInfo = @{FullName = $fileFullName; Name=$fileName; Date=$fileLastWrite}

	##Add This element to the hash table
	if ($fileCollection.ContainsKey($fileLastWrite)) {
		$fileCollection[$fileLastWrite] += $fileInfo
	} else {
		$fileCollection.Add($fileLastWrite, @($fileInfo))
	}	

	##Find the Homepage since it will hold the correct last publish date
	if ($fileName -eq "DefaultHomePage.xml") {
		$publishDate = $fileLastWrite		
	}	
}

## Loop through the keys in order to find those files which are older than the last full publish job
Write-Host "Publish Date: $publishDate"
foreach ($key in $fileCollection.Keys) {
	if ($key -lt $publishDate) {
		foreach ($tmpfileInfo in $fileCollection[$key]) {
			Write-Host $tmpfileInfo.Date "," $tmpfileInfo.FullName
		}
	}
}	
