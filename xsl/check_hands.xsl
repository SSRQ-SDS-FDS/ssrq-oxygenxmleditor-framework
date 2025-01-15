<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    
   <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="tei:handDesc"> 
        <xsl:variable name="hands" as="xs:string*" select="sort(distinct-values(ancestor::tei:TEI//@hand))"/>
        <xsl:variable name="ids" as="xs:string+" select="sort(tei:handNote/@xml:id)"/>
        <xsl:message select="'Hände: ' || $hands || ' = IDs: ' || $ids "/>
        <handDesc>
            <xsl:choose>
                <xsl:when test="deep-equal($hands, $ids)">
                    <xsl:message select="'I am deep equal.'"></xsl:message>
                    <xsl:apply-templates/>
                </xsl:when>
            </xsl:choose>
        </handDesc>
    </xsl:template>
    
    <xsl:template match="tei:physDesc[ancestor::tei:TEI//tei:*[@hand]][not(tei:handDesc)]"> 
        
    </xsl:template>
    
    <!-- 
    1. Aufgabe: Überprüfen aller @hand Attribute (unique)
    Gibt es @hand?
    Für jeden Wert in @hand muss geprüft werden, ob es ein passendes handNote mit @xml:id gibt.
    Wenn nein
        muss ein handNote angelegt werden
        
    Wenn noch keine handDesc existiert, muss diese angelegt werden (innerhalb von physDesc,
    an der passenden Stelle).
        
    2. Aufgabe: Wenn in @hand "perXYZ" steht, muss ein handNote mit einer neuen XML:ID
    erzeugt werden, wobei perXYZ in das Attribut @scribe wandert. Und der Wert in @hand
    mit der neuen ID ersetzt wird.
    <add hand="per123456">...</add>
    => <handNote xml:id="id-ssrq-..." scribe="per123456"/> + <add hand="id-ssrq-....">...</add>
    
    -->

</xsl:stylesheet>