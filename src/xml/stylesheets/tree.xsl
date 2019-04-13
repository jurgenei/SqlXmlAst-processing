<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://ns.ing.com/fn">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="folder-uri" select="'file:.'"/>
    <xsl:template match="processors">
        <xsl:variable name="processors" as="node()*">
            <xsl:apply-templates/>
        </xsl:variable>
        <processors>
            <databases>
                <xsl:for-each select="distinct-values(processor/database/@name)">
                    <xsl:variable name="database" select="."/>
                    <xsl:variable name="doc" select="document(concat($folder-uri,'/',$database,'-toc.xml'))"
                                  as="node()*"/>
                    <xsl:variable name="tables-views"
                                  select="document(concat($folder-uri,'/',$database,'-tables_views.xml'))"
                                  as="node()*"/>
                    <database name="{$database}">
                        <tables>
                            <xsl:variable name="tables" as="node()*">
                                <xsl:for-each select="$doc//table">
                                    <table name="{@name}" procedure="{ancestor::procedure/@name}" mode="{@mode}"/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:for-each-group select="$tables" group-by="@name">
                                <xsl:variable name="name" select="current-grouping-key()"/>
                                <table name="{$name}">
                                    <xsl:variable name="t" select="$tables-views//toc/tables/table[@name = $name]"/>
                                    <xsl:if test="$t">
                                        <xsl:copy-of select="$t/@*"/>
                                    </xsl:if>
                                    <xsl:for-each select="current-group()">
                                        <xsl:variable name="procedure" select="@procedure"/>
                                        <procedure name="{$procedure}" mode="{@mode}">
                                            <xsl:for-each
                                                    select="$processors[.//database[@name=$database]//call[@name=$procedure]]">
                                                <processor name="{@name}"/>
                                            </xsl:for-each>
                                        </procedure>
                                    </xsl:for-each>
                                </table>
                            </xsl:for-each-group>
                        </tables>
                        <xsl:copy-of select="$tables-views//toc/views"/>
                    </database>
                </xsl:for-each>
            </databases>
            <xsl:copy-of select="$processors"/>
        </processors>
    </xsl:template>
    <!-- remove top level tag -->
    <xsl:template match="database">
        <xsl:variable name="name" select="@name"/>
        <xsl:variable name="doc" select="document(concat($folder-uri,'/',@name,'-toc.xml'))" as="node()*"/>
        <database name="{@name}">
            <xsl:variable name="tree" as="node()*">
                <xsl:for-each select="calls/call">
                    <xsl:copy-of select="fn:call-tree($doc,@name)"/>
                </xsl:for-each>
            </xsl:variable>
            <!-- gather all table references -->
            <xsl:variable name="unduped-tabs" as="node()*">
                <xsl:copy-of select="fn:tables($doc,$tree)"/>
                <xsl:copy-of select="tables/table"/>
            </xsl:variable>
            <xsl:variable name="tables" as="node()*">
                <xsl:for-each-group select="$unduped-tabs" group-by="@name">
                    <xsl:variable name="key" select="current-grouping-key()"/>
                    <xsl:variable name="groups" select="current-group()" as="node()*"/>
                    <xsl:variable name="modes" select="string-join(distinct-values($groups/@mode),' ')"/>
                    <table name="{$key}">
                        <xsl:attribute name="mode">
                            <xsl:choose>
                                <xsl:when test="contains($modes,'rw')">rw</xsl:when>
                                <xsl:when test="contains($modes,'ro') and contains($modes,'wo')">rw</xsl:when>
                                <xsl:when test="contains($modes,'ro')">ro</xsl:when>
                                <xsl:when test="contains($modes,'wo')">wo</xsl:when>
                                <xsl:otherwise>none</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </table>
                </xsl:for-each-group>
            </xsl:variable>
            <calls>
                <xsl:copy-of select="$tree"/>
            </calls>
            <tables>
                <xsl:for-each select="$tables">
                    <xsl:sort select="@name"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </tables>
        </database>
    </xsl:template>
    <!-- function to construct call tree -->
    <xsl:function name="fn:call-tree">
        <xsl:param name="doc" as="node()*"/>
        <xsl:param name="name"/>
        <xsl:variable name="proc" select="$doc//procedure[@name=$name]"/>
        <call name="{$name}">
            <xsl:if test="$proc/@path">
                <xsl:attribute name="path" select="$proc/@path"/>
            </xsl:if>
            <xsl:if test="$proc/exceptions">
                <xsl:copy-of select="$proc/exceptions"/>
            </xsl:if>
            <xsl:for-each select="$proc/calls/call">
                <xsl:copy-of select="fn:call-tree($doc,@name)" exclude-result-prefixes="fn"/>
            </xsl:for-each>
        </call>
    </xsl:function>
    <xsl:function name="fn:tables">
        <xsl:param name="doc" as="node()*"/>
        <xsl:param name="tree" as="node()*"/>
        <xsl:for-each select="$tree//call,$tree">
            <xsl:variable name="name" select="@name"/>
            <xsl:copy-of select="$doc//procedure[@name=$name]/tables/table[not(starts-with(@name,'#'))]"/>
        </xsl:for-each>
    </xsl:function>
    <!-- id -->
    <xsl:template match="@*|node()">
        <xsl:copy exclude-result-prefixes="fn">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>