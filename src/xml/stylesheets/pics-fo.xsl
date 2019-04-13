<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:f="http://ns.ing.com/fn"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">
    <xsl:output method="html" version="4.0"
                encoding="UTF-8" indent="yes"/>
    <xsl:param name="book-title" select="'unknown'"/>
    <xsl:param name="book-author" select="'unknown'"/>
    <xsl:param name="book-pubdate" select="'unknown'"/>
    <xsl:param name="plant-uri" select="'file:.'"/>
    <xsl:variable name="plant-toc" select="document(concat($plant-uri,'.xml'))" as="node()*"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="A4"
                                       page-width="21cm"
                                       page-height="29.7cm">
                    <fo:region-body
                            margin-bottom="1.5cm"
                            margin-right="2cm"
                            margin-left="2cm"
                            margin-top="1.5cm"
                            column-count="1"/>
                    <fo:region-before margin-left="2cm" margin-right="2cm" extent="1.0cm"/>
                    <fo:region-after margin-left="2cm" margin-right="2cm" extent="1.0cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="A4">
                <fo:static-content flow-name="xsl-region-before" text-align="end">
                    <fo:block margin-top="10pt" margin-right="20pt" font-size="10pt">
                        <fo:inline>
                            <fo:retrieve-marker
                                    retrieve-class-name="section.head.marker"
                                    retrieve-boundary="document"
                                    retrieve-position="first-including-carryover"/>
                        </fo:inline>
                        <fo:inline color="#0050B2">
                            <fo:retrieve-marker
                                    retrieve-class-name="topic.head.marker"
                                    retrieve-boundary="document"
                                    retrieve-position="first-including-carryover"/>
                        </fo:inline>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="xsl-region-after" text-align="end">
                    <fo:block font-size="8pt" margin-right="20pt">
                        <fo:inline color="#AAAAAA">
                            <xsl:value-of select="concat($book-title,' ', $book-pubdate,' ')"/>
                        </fo:inline>
                        <fo:inline>
                            <xsl:value-of select="' Page '"/>
                            <fo:page-number/>
                            <xsl:value-of select="' of '"/>
                            <fo:page-number-citation ref-id="TheVeryLastPage"/>
                        </fo:inline>
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:wrapper font-family="ING Me" font-size="8pt" text-align="left">
                        <fo:block id="by.processor">
                            <xsl:for-each-group select="/processors/processor" group-by="@category">
                                <!--
                                   <fo:marker marker-class-name="section.head.marker">
                                       <xsl:value-of select="current-grouping-key()"/>
                                   </fo:marker>
                                   -->
                                <!--
                                <xsl:value-of select="concat('Category ',current-grouping-key())"/>
                                -->
                                <fo:inline background-color="#ff6200"
                                           fox:border-radius="3pt"
                                >
                                    <fo:inline color="white" keep-with-next="always">
                                        <xsl:value-of select="fn:current-grouping-key()"/>
                                    </fo:inline>
                                    <xsl:apply-templates select="current-group()"/>
                                </fo:inline>
                            </xsl:for-each-group>
                        </fo:block>
                        <fo:block id="TheVeryLastPage"></fo:block>
                    </fo:wrapper>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    <!-- procedure
    -->
    <xsl:template match="processor">
        <xsl:variable name="name" select="@name"/>
        <xsl:if test="$plant-toc//entry[@name=$name]">
            <xsl:variable name="svg" select="concat($plant-uri,'/',$name,'.svg')"/>
            <xsl:variable name="svg-root" select="document($svg)/svg:svg" as="node()*"/>
            <xsl:variable name="width"
                          select="xs:decimal(fn:replace(fn:replace($svg-root/@width,'\.[0-9]+',''),'px',''))"
                          as="xs:decimal"/>
            <xsl:variable name="height"
                          select="xs:decimal(fn:replace(fn:replace($svg-root/@height,'\.[0-9]+',''),'px',''))"
                          as="xs:decimal"/>
            <fo:inline text-align="center" display-align="center" margin="0" padding="0" >
                <fo:instream-foreign-object height="{$height div 2.7}px"
                                            width="{$width div 2.7}px"
                                            border-style="solid"
                                            border-color="#ff6200"
                                            border-width="0.25pt"
                                            fox:border-radius="3pt"
                                            margin="0"
                                            padding="0"
                                            background-color="white">
                    <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
                    <xsl:attribute name="scaling">uniform</xsl:attribute>
                    <xsl:copy-of select="$svg-root"/>
                </fo:instream-foreign-object>
            </fo:inline>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>