<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <graph>
            <xsl:apply-templates select="//procedure" mode="node"/>
            <xsl:apply-templates select="//procedure" mode="link"/>
        </graph>
    </xsl:template>
    <!-- id -->
    <xsl:template match="procedure" mode="node">
        <node key="{@name}"/>
    </xsl:template>
    <xsl:template match="procedure" mode="link">
        <xsl:variable name="from" select="@name"/>
        <xsl:for-each select="calls/call/@name">
          <link from="{$from}" to="{.}"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>