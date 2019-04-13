<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://ns.ing.com/fn" version="2.0">
    <xsl:output method="text" version="1.0"
                encoding="UTF-8"/>

    <xsl:param name="folder-uri" select="'file:.'"/>


    <xsl:template match="/">
        <xsl:for-each select="distinct-values(/processors/processor/database/@name)">


            <xsl:variable name="database-name" select="."/>
            <!--
            <xsl:value-of select="$database-name"/>
            <xsl:value-of select="'&#10;'"/>
            -->

            <xsl:variable name="procedures" select="document(concat($folder-uri,'/',$database-name,'-toc.xml'))"
                          as="node()*"/>
            <xsl:apply-templates select="$procedures//procedure">
                <xsl:with-param name="database-name" select="$database-name"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="procedure">
        <xsl:param name="database-name"/>
        <xsl:if test="string-length(@name) gt 0">
            <xsl:variable name="procedure-name" select="@name"/>
            <xsl:variable name="path" select="@path"/>
            <xsl:variable name="lines" select="if (@numlines) then @numlines else '0'"/>
            <xsl:value-of select="string-join(($database-name,$procedure-name,$lines,$path),',')"/>
            <xsl:value-of select="'&#10;'"/>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>