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
    $name = $_.Name
    echo "Extracting $name"
    $path = "$objectStore\$name"

    # Trim the leading "psx_ce" and the trailing .xml extension.
    $typeName = $name.Substring(6, $name.LastIndexOf(".") - 6)

    $output = "$outputStore\$typeName.htm"
    $transform.Transform($path, $output)
}
