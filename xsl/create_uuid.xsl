<xsl:stylesheet
    xmlns:uuid="java:java.util.UUID"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    exclude-result-prefixes="xs" version="3.0">
    
    <xsl:param name="documentSystemID" as="xs:string"/>
    <xsl:param name="contextElementXPathExpression" as="xs:string"/>

    <xsl:template name="start">
        <items>
            <item value="{'id-ssrq-' || uuid:randomUUID()}"/>
        </items>
    </xsl:template>
    
</xsl:stylesheet>
