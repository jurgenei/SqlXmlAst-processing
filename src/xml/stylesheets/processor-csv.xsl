<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://ns.ing.com/fn" version="2.0">
    <xsl:output method="text" version="1.0"
                encoding="UTF-8"/>
    <xsl:template match="/">
        <xsl:apply-templates select="processors/processor"/>
    </xsl:template>
    <xsl:template match="processor">
        <xsl:apply-templates select="database">
            <xsl:with-param name="processor-name" select="@name"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="database">
        <xsl:param name="processor-name"/>
        <xsl:variable name="database-name" select="@name"/>
        <xsl:for-each select="distinct-values(calls//call/@name)">
            <xsl:value-of select="string-join(($database-name,$processor-name,'procedure',.),',')"/>
            <xsl:value-of select="'&#10;'"/>
        </xsl:for-each>
        <xsl:for-each select="distinct-values(tables//table/@name)">
            <xsl:value-of select="string-join(($database-name,$processor-name,'table',.),',')"/>
            <xsl:value-of select="'&#10;'"/>
        </xsl:for-each>
    </xsl:template>
 </xsl:stylesheet>