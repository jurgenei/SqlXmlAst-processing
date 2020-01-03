<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="2.0">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>

    <xsl:template match="sql-script">
            <envelope-header>
                <xsl:apply-templates select="@*|node()" mode="header"/>
            </envelope-header>
            <envelope-body>
                <xsl:apply-templates select="@*|node()"/>
            </envelope-body>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()" mode="header">
        <xsl:apply-templates mode="header"/>
    </xsl:template>
    <xsl:template match="insert-into-clause/*//t" mode="header">
        <insert><xsl:value-of select="."/></insert>
    </xsl:template>
    <xsl:template match="from-clause/*//t" mode="header">
        <from><xsl:value-of select="."/></from>
    </xsl:template>


</xsl:stylesheet>