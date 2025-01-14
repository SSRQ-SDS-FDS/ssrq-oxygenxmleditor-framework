<xsl:stylesheet xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:completion="http://ssrq-sds-fds.ch/xsl/oxyframework/functions/completion"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:url="http://ssrq-sds-fds.ch/xsl/oxyframework/functions/url"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="3.0">

    <xsl:param name="documentSystemID" as="xs:string"/>
    <xsl:param name="contextElementXPathExpression" as="xs:string"/>

    <!-- ToDo: API-URL tauschen, sobald Editio online ist! -->
    <xsl:param name="api-base-url" as="xs:string"
        select="'https://staging.editio.ssrq-online.ch/api/v1/entities'"/>

    <xsl:template name="start">
        <xsl:variable name="document" select="doc($documentSystemID)"/>
        <xsl:variable name="context">
            <xsl:evaluate xpath="$contextElementXPathExpression" context-item="$document"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0" as="element()"/>
        </xsl:variable>
        <xsl:apply-templates select="$context">
            <xsl:with-param name="doc-lang" select="$document/tei:TEI/@xml:lang"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="tei:persName | tei:placeName | tei:term">
        <xsl:param name="doc-lang" as="xs:string"/>
        <xsl:param name="context" as="element()" select="."/>
        <xsl:variable name="result" select="url:get-results-from-api(url:create-api-urls($api-base-url, $context, ./text()))" as="array(map(*))?"/>
        <items action="replace">
            <xsl:if test="exists($result)">
                <xsl:for-each select="$result?*">
                    <xsl:sort select="completion:get-entity-name(., $context, $doc-lang)"></xsl:sort>
                    <xsl:sequence select="completion:create-item-from-result(.?id, completion:get-entity-name(., $context, $doc-lang))"/>
                </xsl:for-each>
            </xsl:if>
        </items>
    </xsl:template>
    
    <xsl:function name="completion:create-item-from-result" as="element()">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:sequence>
            <item value="{$id}" annotation="{$name}"/>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:function name="completion:get-entity-name" as="xs:string?">
        <xsl:param name="result" as="map(*)"/>
        <xsl:param name="context" as="element()"/>
        <xsl:param name="doc-lang" as="xs:string"/>
        <xsl:sequence>
            <xsl:choose>
                <xsl:when test="$context/self::tei:persName">
                    <xsl:value-of select="
                        string-join((
                            ($result($doc-lang || '_surname'), $result?de_surname, $result?fr_surname, $result?it_surname, $result?lt_surname)[1],
                            ($result($doc-lang || '_name'), $result?de_name, $result?fr_name, $result?it_name, $result?lt_name)[1]
                           ), ', ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="($result($doc-lang || '_name'), $result?de_name, $result?fr_name, $result?it_name, $result?lt_name)[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:function>

    <xsl:function name="url:create-api-urls" as="xs:string+">
        <xsl:param name="base" as="xs:string"/>
        <xsl:param name="context" as="element()"/>
        <xsl:param name="query" as="xs:string?"/>
        <xsl:sequence>
            <xsl:for-each select="url:element-to-api-type($context)">
                <xsl:value-of
                    select="string-join(($api-base-url, .), '/') || '?query=' || encode-for-uri($query)"
                />
            </xsl:for-each>
        </xsl:sequence>
    </xsl:function>

    <xsl:function name="url:element-to-api-type" as="xs:string+">
        <xsl:param name="context" as="element()"/>
        <xsl:sequence>
            <xsl:choose>
                <xsl:when test="$context[self::tei:placeName]">
                    <xsl:value-of select="'places'"/>
                </xsl:when>
                <xsl:when test="$context[self::tei:persName]">
                    <xsl:value-of select="'persons'"/>
                </xsl:when>
                <xsl:when test="$context[self::tei:term]">
                    <xsl:sequence select="('keywords', 'lemmata')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="error(xs:QName('url:unsupported-entity-type'), 'Unsupported Type, can not be converted')"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:function>

    <xsl:function name="url:get-results-from-api" as="array(map(*))?">
        <xsl:param name="urls" as="xs:string+"/>
        <xsl:try>
            <xsl:sequence select="($urls ! json-doc(.)) => array:join()"/>
            <xsl:catch>
                <xsl:sequence select="()"/>
            </xsl:catch>
        </xsl:try>
    </xsl:function>
</xsl:stylesheet>
