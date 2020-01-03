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
            <xsl:variable name="tables-views"
                          select="document(concat($folder-uri,'/',$database-name,'-tables_views.xml'))"
                          as="node()*"/>
             <xsl:apply-templates select="$procedures//procedure">
                 <xsl:with-param name="database-name" select="$database-name"/>
             </xsl:apply-templates>
            <xsl:apply-templates select="$tables-views//view">
                <xsl:with-param name="database-name" select="$database-name"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>



    <xsl:template match="procedure">
        <xsl:param name="database-name"/>
        <xsl:variable name="procedure-name" select="@name"/>
        <xsl:for-each select="calls/call">
            <xsl:variable name="procedure-call-name" select="@name"/>
            <xsl:value-of select="string-join(($database-name,'procedure',$procedure-name,'procedure',$procedure-call-name),',')"/>
            <xsl:value-of select="'&#10;'"/>
        </xsl:for-each>
        <xsl:for-each select="distinct-values(tables/table/@name)">
            <xsl:variable name="table-name" select="."/>
            <xsl:value-of select="string-join(($database-name,'procedure',$procedure-name,'table',$table-name),',')"/>
            <xsl:value-of select="'&#10;'"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="view">
        <xsl:param name="database-name"/>
        <xsl:variable name="view-name" select="@name"/>
        <xsl:for-each select="table">
            <xsl:variable name="table-name" select="@name"/>
            <xsl:value-of select="string-join(($database-name,'view',$view-name,'table',$table-name),',')"/>
            <xsl:value-of select="'&#10;'"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>