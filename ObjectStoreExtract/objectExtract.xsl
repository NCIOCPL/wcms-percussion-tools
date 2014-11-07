<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:template match="/">
   		<html>
   			<body>
   				<h1>
   					<xsl:value-of select="/PSXApplication/PSXContentEditor/PSXDataSet/name" />
   					(<xsl:value-of select="/PSXApplication/PSXContentEditor/@contentType" />)
   				</h1>

   				<h2>Fields</h2>
   				<table>
   					<thead>
   						<tr>
   							<th>Field</th>
   							<th>Label</th>
   							<th>Type</th>
   							<th>Length</th>
   							<th>Helptext</th>
   						</tr>
   					</thead>
   				<xsl:for-each select="//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping">
   					<tr>
   						<td><xsl:value-of select="FieldRef" /></td>

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