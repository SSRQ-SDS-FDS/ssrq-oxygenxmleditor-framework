<xsl:stylesheet 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="3.0">
    
    <xsl:param name="documentSystemID" as="xs:string"/>
    <xsl:param name="contextElementXPathExpression" as="xs:string"/>
    
    <xsl:template name="start">
        <xsl:variable name="document" select="doc($documentSystemID)"/>
        <xsl:variable name="hand-notes" as="element()*" select="$document//tei:handNote[starts-with(@xml:id, 'id-ssrq')]"/>
        <xsl:if test="exists($hand-notes)">
            <items>
                <xsl:for-each select="$hand-notes">
                    <item value="{./@xml:id}" annotation="{./@scribe}"/>
                </xsl:for-each>
            </items>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
