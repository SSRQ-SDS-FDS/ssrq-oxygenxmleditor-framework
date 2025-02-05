<xsl:stylesheet xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:completion="http://ssrq-sds-fds.ch/xsl/oxyframework/functions/completion"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
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

    <xsl:template match="tei:orgName  | tei:persName | tei:placeName | tei:term">
        <xsl:param name="doc-lang" as="xs:string"/>
        <xsl:param name="context" as="element()" select="."/>
        <xsl:variable name="result" select="url:get-results-from-api(url:create-api-urls($api-base-url, $context, ./text()))" as="array(map(*))?"/>
        <items action="replace">
            <xsl:if test="exists($result)">
                <xsl:for-each select="$result?*">
                    <xsl:sort select="completion:get-entity-name(., $context, $doc-lang)"></xsl:sort>
                    <xsl:sequence select="completion:create-item-from-result(.?id, completion:create-tooltip($context, ., $doc-lang))"/>
                </xsl:for-each>
            </xsl:if>
        </items>
    </xsl:template>
    
    <xsl:function name="completion:create-tooltip" as="xs:string">
        <xsl:param name="context" as="element()"/>
        <xsl:param name="data" as="map(*)"/>
        <xsl:param name="lang" as="xs:string"/>
        <xsl:sequence>
            <xsl:variable name="name" select="completion:get-entity-name($data, $context, $lang)"/>
            <xsl:choose>
                <xsl:when test="$context/self::tei:orgName">
                    <xsl:choose>
                        <!-- If the result is an info about an org, the map contains a key 'de_types' -->
                        <xsl:when test="'de_types' = map:keys($data)">
                            <xsl:variable name="org-types" as="array(xs:string)">
                                <xsl:choose>
                                    <xsl:when test="$lang = 'fr'">
                                        <xsl:sequence select="$data?fr_types"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="$data?de_types"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:value-of select="$name || ' (' || string-join($org-types, ', ') || ')'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$name || '(' || (if ($lang = 'fr') then 'famille' else 'Familie') || ')'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$context/self::tei:persName">
                    <xsl:variable name="date-start" as="xs:string?" select="
                        if (exists($data?birth)) 
                        then 
                            '*' || $data?birth 
                        else if (exists($data?first_mention)) 
                        then 
                            $data?first_mention 
                        else ()"/>
                    <xsl:variable name="date-end" as="xs:string?" select="
                        if (exists($data?death)) 
                        then 
                        '†' || $data?death 
                        else if (exists($data?last_mention)) 
                        then 
                        $data?last_mention 
                        else ()"/>
                    <xsl:choose>
                        <xsl:when test="$date-start or $date-end">
                            <xsl:value-of select="string-join(($name, $data?sex), ', ') || ' (' || string-join(($date-start, $date-end), '-') || ')'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="string-join(($name, $data?sex), ', ')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$context/self::tei:placeName">
                    <xsl:variable name="place-type" select="($data($lang || '_place_types'), $data?de_place_types, $data?fr_place_types)[1]"/>
                    <xsl:value-of select="$name || ' (' || string-join($place-type, ', ') || ')'"/>
                </xsl:when>
                <xsl:when test="$context/self::tei:term">
                    <xsl:variable name="definition" select="($data($lang || '_definition'), $data?de_definition, $data?fr_definition)[1]"/>
                    <xsl:value-of select="$name || ' (' || $definition || ')'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:function name="completion:create-item-from-result" as="element()">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="tooltip" as="xs:string"/>
        <xsl:sequence>
            <item value="{$id}" annotation="{$tooltip}"/>
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
                <xsl:when test="$context[self::tei:orgName]">
                    <xsl:sequence select="('families', 'organizations')"/>
                </xsl:when>
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
