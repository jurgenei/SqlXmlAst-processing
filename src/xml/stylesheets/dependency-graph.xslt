<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://ing.com/vortex/sql/grammar" xmlns:g="http://ing.com/vortex/sql/grammar"
    xmlns:c="http://ing.com/vortex/sql/comments" xmlns:f="http://ing.com/vortex/sql/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="f xs g">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="folder-uri" select="'file:.'"/>
    <xsl:param name="select-pattern" select="'*.xml'"/>
    <!--
      | The whole collection of simplfied SQL2XML documents
      -->
    <xsl:template match="/">
        <toc>
            <xsl:variable name="docs"
                select="collection(concat($folder-uri, '?recurse=yes;select=', $select-pattern))"/>
            <xsl:variable name="p" as="node()*">
                <xsl:apply-templates select="$docs/*/g:sql"/>
            </xsl:variable>
            <procedures>
                <xsl:apply-templates select="$p" mode="xref">
                    <xsl:with-param name="p" select="$p" as="node()*" tunnel="yes"/>
                </xsl:apply-templates>
            </procedures>
            <tables>
                <xsl:for-each-group select="$p//g:table" group-by="@name">
                    <table name="{current-grouping-key()}">
                        <xsl:for-each select="current-group()">
                            <procedure name="{ancestor::g:procedure/@name}" use="{@use}"/>
                        </xsl:for-each>
                    </table>
                </xsl:for-each-group>
            </tables>
        </toc>
    </xsl:template>
    <xsl:template match="@* | node()" mode="xref">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="xref"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="g:procedure" mode="xref">
        <xsl:param name="p" tunnel="yes" as="node()*"/>
        <xsl:element name="procedure">
            <xsl:apply-templates select="@* | node()" mode="xref"/>
            <xsl:variable name="n" select="@name"/>
            <xsl:variable name="callees" select="$p//g:call[@name = $n]"/>
            <xsl:if test="not(empty($callees))">
                <callees>
                    <xsl:for-each select="$callees">
                        <callee name="{ancestor-or-self::g:procedure/@name}"/>
                    </xsl:for-each>
                </callees>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="g:sql">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="g:create-procedure-body">
        <procedure name="{lower-case(g:procedure-name)}">
            <xsl:attribute name="path" select="ancestor::g:*/@path"/>
            <!-- call stack: dedup and group -->
            <xsl:variable name="f" as="node()*">
                <xsl:apply-templates select=".//g:function-call/g:routine-name" mode="call-stack"/>
            </xsl:variable>
            <xsl:variable name="undup" as="node()*">
                <xsl:for-each-group select="$f" group-by="@name">
                    <xsl:copy-of select="current-group()[1]"/>
                </xsl:for-each-group>
            </xsl:variable>
            <xsl:for-each-group select="$undup"
                group-by="
                    if (matches(@name, '\.')) then
                        'util'
                    else
                        ''">
                <xsl:sort select="current-grouping-key()"/>
                <calls>
                    <xsl:if test="current-grouping-key() ne ''">
                        <xsl:attribute name="pkg" select="current-grouping-key()"/>
                    </xsl:if>
                    <xsl:copy-of select="current-group()"/>
                </calls>
            </xsl:for-each-group>
            <!-- object use -->
            <uses>
                <xsl:variable name="t" as="node()*">
                    <xsl:apply-templates/>
                </xsl:variable>
                <xsl:for-each-group select="$t" group-by="@name">
                    <xsl:sort select="current-grouping-key()"/>
                    <table name="{current-grouping-key()}"
                        use="{string-join(distinct-values(current-group()/@use),',')}"/>
                </xsl:for-each-group>
            </uses>
        </procedure>
    </xsl:template>
    <xsl:template match="g:routine-name" mode="call-stack">
        <call name="{lower-case(.)}"/>
    </xsl:template>
    <xsl:template match="g:from-clause">
        <xsl:apply-templates select=".//g:id[@object = 'table']" mode="from-clause"/>
    </xsl:template>
    <xsl:template match="g:id" mode="from-clause">
        <table name="{.}" use="select"/>
    </xsl:template>
    <xsl:template match="g:merge-target">
        <table name="{g:id[position() = 1]}" use="merge"/>
    </xsl:template>
    <xsl:template match="g:insert-into-clause">
        <xsl:apply-templates select=".//g:id[@object = 'table']" mode="into-clause"/>
    </xsl:template>
    <xsl:template match="g:id" mode="into-clause">
        <table name="{.}" use="insert"/>
    </xsl:template>
    <xsl:template match="g:delete-statement">
        <xsl:apply-templates select=".//g:id[@object = 'table']" mode="delete-statement"/>
    </xsl:template>
    <xsl:template match="g:id" mode="delete-statement">
        <table name="{.}" use="delete"/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
