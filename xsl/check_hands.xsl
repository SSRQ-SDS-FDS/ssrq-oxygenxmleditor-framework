<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:hands="http://ssrq-sds-fds.ch/xsl/oxyframework/functions/hands"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:uuid="java:java.util.UUID"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
 
    <xsl:mode on-no-match="shallow-copy" name="notes"/>
    <xsl:mode on-no-match="shallow-copy" name="hands"/>
   
    
    <xsl:template match="/">
        <xsl:variable name="tei-with-hand-notes" as="node()+">
            <xsl:apply-templates select="/" mode="notes"/>
        </xsl:variable>
        <xsl:apply-templates select="$tei-with-hand-notes" mode="hands"/>
    </xsl:template>
    
    <xsl:template match="tei:handDesc" mode="notes"> 
        <xsl:variable name="hands" as="xs:string*" select="sort(distinct-values(./ancestor::tei:TEI//@hand))"/>
        <xsl:variable name="ids" as="xs:string+" select="sort(./tei:handNote/@xml:id)"/>
        <handDesc>
            <xsl:choose>
                <xsl:when test="hands:all-have-hand-notes($hands, $ids)">
                    <xsl:apply-templates mode="notes"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="notes"/>
                    <xsl:for-each select="hands:filter-refs-for-creation($hands, ./tei:handNote)">
                        <xsl:sequence select="hands:create-notes(.)"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </handDesc>
    </xsl:template>
    
    <xsl:template match="tei:physDesc[ancestor::tei:TEI//tei:*[@hand]][not(tei:handDesc)]" mode="notes"> 
        <xsl:variable name="hands" as="xs:string*" select="sort(distinct-values(./ancestor::tei:TEI//@hand))"/>
        <xsl:variable name="desc" as="element(tei:handDesc)">
            <handDesc>
                <xsl:for-each select="$hands">
                    <xsl:sequence select="hands:create-notes(.)"/>
                </xsl:for-each>
            </handDesc>
        </xsl:variable>
        <physDesc>
            <xsl:sequence select="(./tei:objectDesc, ./tei:bindingDesc, $desc, ./tei:sealDesc)"/>
        </physDesc>
    </xsl:template>
    
    <xsl:template match="@hand[starts-with(., 'per')]" mode="hands">
        <xsl:variable name="value" select="."/>
        <xsl:attribute name="hand" select="./ancestor::tei:TEI//tei:handNote[@scribe = $value]/@xml:id"/>
    </xsl:template>
    
    <xsl:function name="hands:all-have-hand-notes" as="xs:boolean">
        <xsl:param name="hand-references" as="xs:string*"/>
        <xsl:param name="hand-ids" as="xs:string+"/>
        <xsl:sequence select="every $ref in $hand-references satisfies $ref = $hand-ids"/>
    </xsl:function>
    
    <xsl:function name="hands:create-notes" as="element(tei:handNote)">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence>
            <xsl:choose>
                <xsl:when test="starts-with($id, 'per')">
                    <handNote xml:id="{'id-ssrq-' || uuid:randomUUID()}" scribe="{$id}"/>
                </xsl:when>
                <xsl:otherwise>
                    <handNote xml:id="{$id}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:function name="hands:filter-refs-for-creation" as="xs:string*">
        <xsl:param name="hand-references" as="xs:string*"/>
        <xsl:param name="hand-notes" as="element(tei:handNote)+"/>
        <xsl:sequence select="filter($hand-references, function($ref) {empty($hand-notes[./@scribe = $ref or ./@xml:id = $ref])})"/>
    </xsl:function>
    

</xsl:stylesheet>
