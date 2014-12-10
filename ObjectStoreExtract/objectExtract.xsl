<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:template match="/">
   		<html>
   			<body>
   				<h1>
   					<xsl:value-of select="/PSXApplication/PSXContentEditor/PSXDataSet/name" />
   					(<xsl:value-of select="/PSXApplication/PSXContentEditor/@contentType" />)
   				</h1>

				<p><strong>Table:</strong> <xsl:value-of select="//PSXContainerLocator/PSXTableSet/PSXTableRef/@name" />
				</p>
				
				<h2>Shared Field Sets</h2>
				<ul>
				<xsl:for-each select="//PSXContentEditorMapper/SharedFieldIncludes/SharedFieldGroupName">
					<li><xsl:value-of select="." /></li>
				</xsl:for-each>
				</ul>
				
				<h3>Excluding shared field names</h3>
				<ul>
				<xsl:for-each select="//PSXContentEditorMapper/SharedFieldIncludes/SharedFieldExcludes/FieldRef">
					<li><xsl:value-of select="." /></li>
				</xsl:for-each>
				</ul>
				
   				<h2>Fields</h2>
   				<table>
   					<thead>
   						<tr>
   							<th>Field</th>
							<th>Source</th>
   							<th>Label</th>
   							<th>UI Control</th>
   							<th>Length</th>
   							<th>Helptext</th>
   						</tr>
   					</thead>
   				<xsl:for-each select="//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping">

					<xsl:variable name="fieldName" select="FieldRef" />

					<tr>
   						<td><xsl:value-of select="$fieldName" /></td>
						
						<td>
							<xsl:choose>
								<xsl:when test="//PSXFieldSet/PSXField[@name=$fieldName]"><xsl:value-of select="//PSXFieldSet/PSXField[@name=$fieldName]/@type" /></xsl:when>
								<xsl:when test="starts-with($fieldName, 'sys_')">system</xsl:when>
								<xsl:otherwise>shared</xsl:otherwise>
							</xsl:choose>
						</td>

   						<!-- Labels are only available for local field definitions. -->
   						<td><xsl:value-of select="PSXUISet/Label/PSXDisplayText" /></td>
   						<td><xsl:value-of select="PSXUISet/PSXControlRef/@name" /></td>
   						<td><xsl:value-of select="PSXUISet/PSXControlRef/PSXParam[@name='size']/DataLocator/PSXTextLiteral/text" /></td>
   						<td><xsl:value-of select="PSXUISet/PSXControlRef/PSXParam[@name='helptext']/DataLocator/PSXTextLiteral/text" /></td>
					</tr>
   				</xsl:for-each>
   				</table>
			</body>
		</html>
   </xsl:template>
</xsl:stylesheet>