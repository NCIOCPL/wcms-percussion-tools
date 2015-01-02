<#
	$oldStore - Path to where we find the object store.
    $outputStore - Where to put the generated files.
#>
param ($old, $new)

$OutputFile = "ComparisonReport.htm"

function Main($oldPath, $newPath) {

    if(-not $oldPath -or -not $newPath)
    {
        Write-Host ""
        Write-Host 'You must specify $oldPath - Path to the old object store.'
        Write-Host '             and $newPath - Path to the new object store.'
        exit
    }

    $oldStore = "$oldPath\ObjectStore"
    $newStore = "$newPath\ObjectStore"

    StartComparisonReport

    $oldFileList = GetTypeFileList($oldStore)
    $newFileList = GetTypeFileList($newStore)

    $reconciledList = CompareFileLists $oldFileList $newFileList
    CompareTypes $oldStore $newStore $reconciledList

    EndComparisonReport
}

<#
    Compare the fields of types which are found in both the old and the new objectStores.

    $oldPath - Path to the old objectStore
    $newPath - Path to the new objectStore
    $reconciledFileList - List of type definition files which exist in both objectStores.
#>
function CompareTypes($oldPath, $newPath, $reconciledFileList) {

    BeginCompare "Changes to Types"

    foreach( $file in $reconciledFileList ) {
        Write-Host $file
        [xml]$oldDoc = Get-Content "$oldPath\$file"
        [xml]$newDoc = Get-Content "$newPath\$file"

        $type = GetTypeFromFilename $file

        BeginCompare $type

        CompareSharedFields $type $oldDoc $newDoc
        CompareFields $type $oldDoc $newDoc

        EndCompare
    }

    EndCompare
}

<#
    Compare shared field information between an old and new type definition.

    $type - The name of the type being compared.
    $oldDoc - XML document containing the type's old defitionn.
    $newDoc - XML document containing the type's new defitionn.
#>
function CompareSharedFields( $type, $oldDoc, $newDoc ) {

    # Shared field Sets
    $addedFieldSets = CompareValueLists "//PSXContentEditorMapper/SharedFieldIncludes/SharedFieldGroupName" $newDoc $oldDoc
    $removedFieldSets = CompareValueLists "//PSXContentEditorMapper/SharedFieldIncludes/SharedFieldGroupName" $oldDoc $newDoc

    WriteCompareDValueList "Added Shared Field Sets" $addedFieldSets
    WriteCompareDValueList "Removed Shared Field Sets" $removedFieldSets

    # Shared field name exclusions.
    $addedFieldExclusions = CompareValueLists "//PSXContentEditorMapper/SharedFieldIncludes/SharedFieldExcludes/FieldRef" $newDoc $oldDoc
    $removedFieldExclusions = CompareValueLists "//PSXContentEditorMapper/SharedFieldIncludes/SharedFieldExcludes/FieldRef" $oldDoc $newDoc

    WriteCompareDValueList "New Shared Field Name Exclusions" $addedFieldExclusions
    WriteCompareDValueList "Removed Shared Field Name Exclusions" $removedFieldExclusions

}


<#
    Compare the fields between an old and new type definition.

    $type - The name of the type being compared.
    $oldDoc - XML document containing the type's old defitionn.
    $newDoc - XML document containing the type's new defitionn.
#>
function CompareFields($type, $oldDoc, $newDoc) {

    if( -not $type )  {  Throw '$type paramameter is null.' }
    if( -not $oldDoc )  {  Throw '$oldDoc paramameter is null.' }
    if( -not $newDoc )  {  Throw '$newDoc paramameter is null.' }

    $addedFields = @()
    $removedFields = @()
    $changedFields = @()

    # Loop through the old set of fields, listing any that are missing or have changed.
    foreach($field in $oldDoc.SelectNodes("//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping")) {
        $fieldName = $field.FieldRef
        $newField = $newDoc.SelectSingleNode("//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping/FieldRef[text() = '$fieldName']")

        if($newField) {

            #Field exists on both sides.  Compare details.
            $difference = $null


            $controlTypeDesc = "Control type"
            $controlTypeQuery = "//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping[FieldRef/text() = '$fieldName']/PSXUISet/PSXControlRef/@name"


            $labelDesc = "Label"
            $labelQuery = "//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping[FieldRef/text() = '$fieldName']/PSXUISet/Label/PSXDisplayText/text()"

            $maxlengthDesc = "Max length"
            $maxlengthQuery = "//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping[FieldRef/text() = '$fieldName']/PSXUISet/PSXControlRef/PSXParam[@name='maxlength']/DataLocator/PSXTextLiteral/text/text()"

            $helptextDesc = "Helptext"
            $helptextQuery = "//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping[FieldRef/text() = '$fieldName']/PSXUISet/PSXControlRef/PSXParam[@name='helptext']/DataLocator/PSXTextLiteral/text/text()"

            $descriptionList = @($controlTypeDesc, $labelDesc, $maxlengthDesc, $helptextDesc)
            $nodeQueryList = @($controlTypeQuery, $labelQuery, $maxlengthQuery, $helptextQuery)

            for($i = 0; $i -lt $descriptionList.length; $i++) {
                $query = $nodeQueryList[$i]
                $result = CompareNodeValues $oldDoc $newDoc $query
                if($result) {
                    $description = $descriptionList[$i]
                    $difftext = GetFieldDifferenceText $description $result
                    $difference = $difference + $difftext
                }
            }


            # Record any found differences
            if($difference -ne $null) {
                $changedFields = $changedFields + "$fieldName - $difference"
            }

        } else {
            # Field not found.
            $removedFields = $removedFields + $fieldName
        }
    }

    # Loop through the new set of fields to find any additions.
    foreach($field in $newDoc.SelectNodes("//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping")) {
        $fieldName = $field.FieldRef
        $oldField = $oldDoc.SelectSingleNode("//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping/FieldRef[text() = '$fieldName']")

        if(-not $oldField) {
            $addedFields = $addedFields + $fieldName
        }
    }


    if($addedFields.length -gt 0) {
        BeginCompare "Added Fields"
        foreach($field in $addedFields) {
            WriteComparison $field
        }
        EndCompare
    }

    if($removedFields.length -gt 0) {
        BeginCompare "Removed Fields"
        foreach($field in $removedFields) {
            WriteComparison $field
        }
        EndCompare
    }

    if($changedFields.length -gt 0) {
        BeginCompare "Changed Fields"
        foreach($field in $changedFields) {
            WriteComparison $field
        }
        EndCompare
    }

}


function GetFieldDifferenceText($description, $difference) {
    $text = ""
    $old = $difference.oldValue
    $new = $difference.newValue

    if ($old -and $new) {
        $text = "$description changed from '$old' to '$new'. "
    } elseif (-not $old -and $new) {
        $text = "$description node added. "
    } elseif ($old -and -not $new) {
        $text = "$description node removed. "
    } else {
        Write-Error "Logic Error. Old and New values are both null in GetFieldDifferenceText."
    }

    return $text
}


function CompareNodeValues($oldDoc, $newDoc, $pathQuery) {
    $difference = $null

    $oldValue = $oldDoc.SelectSingleNode($pathQuery)
    $newValue = $newDoc.SelectSingleNode($pathQuery)

    if($oldValue) {$oldValue = $oldValue.Value}
    if($newValue) {$newValue = $newValue.Value}

    if( $oldValue -ne $newValue) {
        # Neither value exists, return an empty difference.
        $difference = New-Object 'System.Object'
        $difference | add-member -membertype noteProperty -name "oldValue" -value $oldValue
        $difference | add-member -membertype noteProperty -name "newValue" -value $newValue
    }

    return $difference
}


<#
    Compare a set of values between two XML documents, returning a list of values which appear in
    the reference document, but not in the one being compared.

    $xPath - xPath expression for finding the values.
    $reference - The original (baseline) version of the document.
    $compared - The version of the document being compared.
#>
function CompareValueLists( $xPath, $reference, $compared ) {

    $missingValueList = @()

    # Look for values in $reference which don't appear in $compared
    foreach( $node in $reference.SelectNodes( "$xPath" ) ) {
        $nodeValue = $node.InnerText
        $newNode = $compared.SelectSingleNode( "$xPath[text() = '$nodeValue']" )
        if ( -Not $newNode ) {
            $missingValueList = $missingValueList + $nodeValue
        }
    }

    return $missingValueList
}

function WriteCompareDValueList($label, $valueList) {

    if( $valueList.length -gt 0 ) {
        BeginCompare $label
        foreach($value in $valueList) {
            WriteComparison $value
        }
        EndCompare
    }
}


<#
    Compare the old and new lists of files.
    Types which aren't found in both locations are recorded in the ouptut file.

    Returns a list of files which are found in both locations.
#>
function CompareFileLists($oldFileList, $newFileList) {
    $mergedList = @()

    $newTypes = @()
    $removedTypes = @()


    #Find items in the old list missing from the new one.
    $lookup = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach($file in $newFileList) { $junk = $lookup.Add($file) }

    foreach($file in $oldFileList) {
        if (-not $lookup.Contains($file)) {
            $type = GetTypeFromFilename $file
            $removedTypes = $removedTypes + $type
        }
    }

    #find items in the new list that didn't exist before.
    $lookup = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach($file in $oldFileList) { $junk = $lookup.Add($file) }

    foreach($file in $newFileList) {
        if (-not $lookup.Contains($file)) {
            $type = GetTypeFromFilename $file
            $newTypes = $newTypes + $type
        } else {
            $mergedList += $file
        }
    }

    if($newTypes.length -gt 0 ) {
        BeginCompare "New Types"
        foreach($field in $newTypes) {
            WriteComparison $field
        }
        EndCompare
    }

    if($removedTypes.length -gt 0) {
        BeginCompare "Removed Types"
        foreach($field in $removedTypes) {
            WriteComparison $field
        }
        EndCompare
    }

    return $mergedList
}

<# Returns an array of file names from the location specified in $path #>
function GetTypeFileList($path) {
    # Filespec for content item descriptor files.
    $typeDefFilter = "psx_*.xml"

    $fileList = @()
    Get-ChildItem $path -filter $typeDefFilter -name | ForEach-Object { $fileList = $fileList + $_ }
    return $fileList
}

function GetTypeFromFilename($filename) {
    # Trim the leading "psx_ce" and the trailing .xml extension.
    $typeName = $filename.Substring(6, $filename.LastIndexOf(".") - 6)
    return $typeName
}

function BeginCompare($title) {
    $html = "<section><p><strong>$title</strong></p><ul>"
    Write-Host $title":"
    Add-Content $OutputFile -Value $html
}

function EndCompare() {
    $html = "</ul></section>"
    Add-Content $OutputFile -Value $html
}

function WriteComparison($message) {
    Write-Host $message
    $html = "<li>$message</li>"
    Add-Content $OutputFile -Value $html
}


function StartComparisonReport() {
    $html = "<html><body><h1>Comparing location $old to $new</h1>"
    $junk = New-Item -Name $OutputFile -type File -force
    Add-Content $OutputFile -Value $html
}

function EndComparisonReport() {
    $html = "</body></html>"
    Add-Content $OutputFile -Value $html
}


Main $old $new