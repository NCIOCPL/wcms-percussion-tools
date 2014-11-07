<#
	Path to where we find the object store.  On any of our standard WCMS installations, this will
	always be e:\Rhythmyx\ObjectStore
#>
$OBJECT_STORE = "C:\WCMTeam\Tools\ObjectStoreExtract\FullStore"
$OUTPUT_STORE = "C:\WCMTeam\Tools\ObjectStoreExtract\OutputStore"

# Filespec for content item descriptor files.
$typeDefFilter = "psx_*.xml"

$transform = New-Object System.Xml.Xsl.XslCompiledTransform;
$transform.Load("objectExtract.xsl")



Get-ChildItem $OBJECT_STORE -filter $typeDefFilter | ForEach-Object {

    # Just the simple filename.
    $name = $_.Name
    echo "Extracting $name"
    $path = "$OBJECT_STORE\$name"

    # Trim the leading "psx_ce" and the .xml extension.
    $typeName = $name.Substring(6, $name.LastIndexOf(".") - 6)

    $output = "$OUTPUT_STORE\$typeName.htm"
    $transform.Transform($path, $output)
}
