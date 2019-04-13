<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://ns.ing.com/fn">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>
    <xsl:param name="folder-uri" select="'file:.'"/>
    <xsl:param name="toc"/>
    <xsl:param name="select-pattern" select="'*.xml'"/>
    <!--
      | The whole collection of simplfied SQL2XML documents
      -->
    <xsl:variable name="tables"
                  select="collection(concat($folder-uri, '/table?recurse=yes;select=', $select-pattern))"/>
    <xsl:variable name="views"
                  select="collection(concat($folder-uri, '/view?recurse=yes;select=', $select-pattern))"/>
    <xsl:variable name="toc-tables" select="document($toc)//table" as="node()*"/>
    <xsl:variable name="toc-views" select="$views//create-view//table-name" as="node()*"/>

    <!--
      | traverse all simplfied SQL2XML documents
      -->
    <xsl:template name="main" match="/">
        <toc>
            <tables>
                <xsl:apply-templates select="$tables//create-table"/>
            </tables>
            <views>
                <xsl:apply-templates select="$views//create-view"/>
            </views>
        </toc>
    </xsl:template>
    <!--
      | each table
      -->
    <xsl:template match="create-table">
        <xsl:variable name="name" select="table-name"/>
        <table name="{$name}" path="{/sql/@path}">
            <xsl:attribute name="used-in-procs" select="if ($toc-tables[@name = $name]) then 'yes' else 'no'"/>
            <xsl:attribute name="used-in-views" select="if ($toc-views[. = $name]) then 'yes' else 'no'"/>
        </table>
    </xsl:template>
    <xsl:template match="create-view">
        <view name="{view-name}" path="{/sql/@path}">
            <xsl:for-each select="distinct-values(.//table-name)">
                <table name="{.}"/>
            </xsl:for-each>
        </view>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>