<#
	$objectStore - Path to where we find the object store.
    $outputStore - Where to put the generated files.
#>
param ($objectStore, $outputStore)

if(-not $objectStore -or -not $outputStore)
{
    Write-Host ""
    Write-Host 'You must specify $objectStore - Path to where we find the object store.'
    Write-Host '             and $outputStore - Path for storing the generated files.'
    exit
}



# Filespec for content item descriptor files.
$typeDefFilter = "psx_*.xml"

$transform = New-Object System.Xml.Xsl.XslCompiledTransform;
$transform.Load("objectExtract.xsl")



Get-ChildItem $objectStore -filter $typeDefFilter | ForEach-Object {

    # Just the simple filename.
    $fileName = $_.Name
    $path = "$objectStore\$fileName"

	[xml]$typeDefinition = Get-Content $path
	$typeName = $typeDefinition.PSXApplication.PSXContentEditor.PSXDataSet.name
	Write-Host -foregroundcolor 'blue' "Extracting $typeName"
	
    $output = "$outputStore\$typeName.htm"
	
	# Ideally, this should transform $typeDefinition instead of loading the
	# file a second time.
    $transform.Transform($path, $output)
}
