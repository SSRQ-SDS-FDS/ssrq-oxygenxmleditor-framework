<xsl:stylesheet 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="3.0">
    
    <xsl:param name="documentSystemID" as="xs:string"/>
    <xsl:param name="contextElementXPathExpression" as="xs:string"/>
    
    <xsl:template name="start">
        <xsl:variable name="document" select="doc($documentSystemID)"/>
        <xsl:variable name="context">
            <xsl:evaluate xpath="$contextElementXPathExpression" context-item="$document"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0" as="element()"/>
        </xsl:variable>
        <xsl:apply-templates select="$context">
            <xsl:with-param name="doc" select="$document"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="tei:addSpan | tei:damageSpan | tei:delSpan">
        <xsl:param name="doc" as="document-node()"/>
        <xsl:variable name="context-name" as="xs:string" select="./name()"/>
        <xsl:variable 
            name="maximum" 
            as="xs:double?"
            select="
            $doc//tei:*[./name() = $context-name]/replace(@spanTo, '\w+(\d)+', '$1')
            => max()
            => number()
            "/>
        <xsl:variable name="prefix" select="$context-name => substring-before('Span')"/>
        <items>
            <item value="{if (exists($maximum)) then $prefix || $maximum + 1 else $prefix || '1'}"/>
        </items>
    </xsl:template>
    
    <xsl:template match="tei:anchor">
        <xsl:param name="doc" as="document-node()"/>
        <items>
            <xsl:for-each select="($doc//tei:delSpan|$doc//tei:damageSpan|$doc//tei:addSpan)[empty(id(./@spanTo))]">
                <item value="{./@spanTo}"/>
            </xsl:for-each>
        </items>
    </xsl:template>

    
</xsl:stylesheet>
