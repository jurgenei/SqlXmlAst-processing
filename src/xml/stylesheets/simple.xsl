<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <sql>
            <xsl:copy-of select="sql/@*"/>
            <xsl:apply-templates select="sql/tsql-file/*"/>
        </sql>
    </xsl:template>
    <!-- id -->
    <xsl:template priority="1"
                  match="data-type|constant|comparison-operator|primitive-expression|assignment_operator|func-proc-name|full-column-name|go-statement|select-list-elem|table-alias|cursor-name">
        <xsl:element name="{local-name(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*[*[starts-with(local-name(.),'iq-')]]">
        <xsl:element name="{local-name(.)}">
            <xsl:attribute name="type">iq</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*[starts-with(local-name(.),'iq-')]" priority="1">
        <xsl:element name="{substring-after(local-name(.),'iq-')}">
            <xsl:attribute name="type">iq</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="id|simple-id">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <!-- thing with one expression -->
    <xsl:template match="*[count(*) = 1 and expression]">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- search condition with one predicate -->
    <xsl:template match="search-condition[count(*) = 1 and predicate]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="sql_clause|dml_clause|ddl_clause|another-statement|cfl-statement">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- varities of table-name -->

    <xsl:template match="delete-statement/id|truncate-table/id">
        <table-name>
            <xsl:value-of select="."/>
        </table-name>
    </xsl:template>
    <xsl:template match="full-table-name|table-name">
        <xsl:variable name="name" select="id[position()=last()]"/>
        <table-name>
            <xsl:value-of select="if ($name) then $name else ."/>
        </table-name>

    </xsl:template>
    <xsl:template match="table-alias">
        <table-alias>
            <xsl:value-of select="."/>
        </table-alias>
    </xsl:template>
    <xsl:template match="table-name-with-hint|as-table-alias">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="id[parent::column-definition or parent::column-name-list-with-order]">
        <column-name>
            <xsl:value-of select="."/>
        </column-name>
    </xsl:template>
    <xsl:template match="id[parent::iq-index]">
        <index-name>
            <xsl:value-of select="."/>
        </index-name>
    </xsl:template>

    <!-- varities of view -->
    <xsl:template match="create-view/simple-name">
       <view-name>
           <xsl:variable name="name" select="id[position()=last()]"/>
           <xsl:value-of select="if ($name) then $name else ."/>
       </view-name>
    </xsl:template>

    <xsl:template match="null-notnull|credential">
        <xsl:element name="{local-name(.)}">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>




    <!-- remove eof -->
    <xsl:template match="t[. = '&lt;EOF&gt;']" priority="1"/>
    <!-- other rules identity -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>