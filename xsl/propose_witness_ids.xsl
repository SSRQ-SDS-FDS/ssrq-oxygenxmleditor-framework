<xsl:stylesheet 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="3.0">
    
    <xsl:param name="documentSystemID" as="xs:string"/>
    <xsl:param name="contextElementXPathExpression" as="xs:string"/>
    
    <xsl:template name="start">
        <xsl:variable name="document" select="doc($documentSystemID)"/>
        <xsl:variable name="witnesses" as="element(tei:witness)*" select="$document//tei:witness"/>
        <xsl:variable name="editions" as="element(tei:bibl)*" select="$document//tei:listBibl[@type = 'edition']/tei:bibl[@xml:id]"/>
        <xsl:if test="exists($witnesses)">
            <items>
                <!-- 
                     Sort the witnesses and use only those with an index gt 1; the first should always
                     be the current document
                 -->
                <xsl:for-each select="sort($witnesses, (), function($wit) {$wit/@n}) => subsequence(2)">
                    <item value="{./@xml:id}" annotation="{.//tei:msIdentifier/tei:idno/text()}"/>
                </xsl:for-each>
                <xsl:for-each select="$editions">
                    <item value="{./@xml:id}" annotation="{./string() => normalize-space()}"/>
                </xsl:for-each>
            </items>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
