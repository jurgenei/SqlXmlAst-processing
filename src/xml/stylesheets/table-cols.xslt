<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://ing.com/vortex/sql/grammar" xmlns:g="http://ing.com/vortex/sql/grammar"
    xmlns:c="http://ing.com/vortex/sql/comments" xmlns:f="http://ing.com/vortex/sql/functions"
    xmlns:l="http://ing.com/vortex/sql/lineage" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="f xs g c">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="folder-uri" select="'file:.'"/>
    <xsl:param name="select-pattern" select="'*.xml'"/>
    <xsl:variable name="docs"
        select="collection(concat($folder-uri, '?recurse=yes;select=', $select-pattern))"/>
    <!--
      | The whole collection of simplfied SQL2XML documents
      -->
    <xsl:template match="/">
        <l:tables xmlns:l="http://ing.com/vortex/sql/lineage">
            <xsl:apply-templates select="$docs/*/g:sql"/>
        </l:tables>
    </xsl:template>
    <xsl:template match="g:create-table">
        <l:table name="{lower-case(g:id)}">
            <xsl:apply-templates select=".//g:column-definition/g:column-name/g:id"/>
        </l:table>
    </xsl:template>
    <xsl:template match="g:column-definition/g:column-name/g:id">
        <l:column name="{lower-case(.)}" colno="{position()}"/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
