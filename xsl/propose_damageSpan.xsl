<xsl:stylesheet 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="3.0">
    
    <xsl:param name="documentSystemID" as="xs:string"/>
    <xsl:param name="contextElementXPathExpression" as="xs:string"/>
    
    <xsl:template name="start">
        <xsl:variable name="document" select="doc($documentSystemID)"/>
         <xsl:variable name="maximum" as="xs:double?"
            select="number(max($document//tei:damageSpan/substring(./@spanTo, 7)))"/>
        
        <xsl:choose>
            <xsl:when test="exists($maximum)">
                <items>
                        <item value="{'damage' || $maximum + 1}"/>
                </items>
            </xsl:when>
            <xsl:otherwise>
                <items>
                    <item value="damage1"/>
                </items>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
