<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:completion="http://ssrq-sds-fds.ch/xsl/oxyframework/functions/completion"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:info="http://ssrq-sds-fds.ch/xsl/oxyframework/functions/info"
    xmlns:url="http://ssrq-sds-fds.ch/xsl/oxyframework/functions/url"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array" exclude-result-prefixes="xs math"
    version="3.0">


    <xsl:output method="text"/>

    <xsl:import href="./find_db_ids.xsl"/>

    <xsl:function name="info:create-entity-info" as="xs:string" visibility="public">
        <xsl:param name="context" as="element()"/>
        <xsl:param name="lang" as="xs:string"/>
        <xsl:sequence
            select="' ' || (info:display-entity-id($context), info:display-entity-info($context, $lang)) => string-join('; ')"
        />
    </xsl:function>

    <xsl:function name="info:display-entity-id" as="xs:string">
        <xsl:param name="context" as="element()"/>
        <xsl:sequence select="('ID:', $context/@ref) => string-join(' ')"/>
    </xsl:function>

    <xsl:function name="info:display-entity-info" as="xs:string">
        <xsl:param name="context" as="element()"/>
        <xsl:param name="lang" as="xs:string"/>
        <xsl:variable name="result"
            select="url:get-results-from-api(url:create-api-urls($api-base-url, $context, substring($context/@ref, 1, 9)))"
            as="array(map(*))?"/>
        <xsl:sequence>
            <xsl:choose>
                <xsl:when test="exists($result)">
                    <xsl:variable name="prefix" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$lang = 'fr'">
                                <xsl:value-of select="'Nom standard : '"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'Standardname: '"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of
                        select="$prefix || completion:create-tooltip($context, array:head($result), $lang)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'N.N. (DB error)'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:function>


</xsl:stylesheet>
