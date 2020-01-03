<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:g="http://ing.com/vortex/sql/grammar"
                xmlns:c="http://ing.com/vortex/sql/comments"
                xmlns:s="http://ing.com/vortex/sql/semrel"
                xmlns:e="http://ing.com/vortex/sql/envelope"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
>
    <xsl:output method="xhtml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:preserve-space elements="c:*"/>
    <xsl:template match="/">
        <e:doc xmlns="http://ing.com/vortex/sql/grammar"
               xmlns:s="http://ing.com/vortex/sql/semrel"
               xmlns:c="http://ing.com/vortex/sql/comments"
               xmlns:e="http://ing.com/vortex/sql/envelope"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        >
            <xsl:variable name="simple" as="node()*">
                <xsl:apply-templates select="@*|node()" mode="simple"/>
            </xsl:variable>
            <e:header>
                <rdf:RDF>
                    <xsl:apply-templates select="$simple" mode="header"/>
                </rdf:RDF>
            </e:header>
            <e:body xmlns:h="http://www.w3.org/1999/xhtml">
                <xsl:apply-templates select="$simple"/>
            </e:body>
        </e:doc>
    </xsl:template>
    <!-- simple -->
    <xsl:template match="g:search-condition|g:table-source-item-joined|g:table-name-with-hint|
       g:derived-table|g:as-table-alias|g:as-column-alias|g:subquery" mode="simple">
        <xsl:apply-templates mode="simple"/>
    </xsl:template>
    <xsl:template match="sql_clause/*" mode="simple">
        <xsl:apply-templates mode="simple"/>
    </xsl:template>
    <xsl:template match="g:id[g:simple-id]" mode="simple">
        <xsl:copy>
            <xsl:apply-templates mode="simple" select="g:simple-id/g:*"/>
        </xsl:copy>
        <xsl:apply-templates mode="simple" select="g:simple-id/c:*"/>
    </xsl:template>
    <xsl:template match="g:column-alias[g:*]|table-alias[g:*]" mode="simple">
        <xsl:copy>
            <xsl:apply-templates mode="simple" select="g:*"/>
        </xsl:copy>
        <xsl:apply-templates mode="simple" select="c:*"/>
    </xsl:template>
    <xsl:template match="@*|node()" mode="simple">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="simple"/>
        </xsl:copy>
    </xsl:template>

    <!-- header -->
    <xsl:template match="@*|node()" mode="header">
        <xsl:apply-templates select=".//g:create-or-alter-procedure" mode="header"/>
    </xsl:template>
    <xsl:template match="g:create-or-alter-procedure" mode="header">
        <s:procedure name="{g:func-proc-name//g:t}">

            <!-- handle calls -->
            <xsl:variable name="calls" as="node()*">
                <xsl:apply-templates select=".//g:execute-statement" mode="header"/>
            </xsl:variable>
            <xsl:if test="$calls">
                <s:calls>
                    <xsl:for-each-group select="$calls" group-by="@name">
                        <xsl:sort select="@name"/>
                        <xsl:for-each select="current-grouping-key()">
                            <s:call name="{.}"/>
                        </xsl:for-each>
                    </xsl:for-each-group>
                </s:calls>
            </xsl:if>

            <!-- handle tables -->
            <xsl:variable name="tables" as="node()*">
                <xsl:for-each select=".//(g:insert-statement|g:update-statement|g:delete-statement|g:merge-statement)">
                    <table name="{g:ddl-object//g:t}" op="{replace(local-name(),'-.*','')}"/>
                </xsl:for-each>
                <xsl:for-each select=".//g:table-source-item/g:table-name/g:id">
                    <table name="{.}" op="select"/>
                </xsl:for-each>
                <xsl:for-each select=".//g:t[. eq 'INTO']">
                    <xsl:variable name="table" select="following-sibling::g:table-name[1]/g:id" as="node()*"/>
                    <xsl:if test="not(empty($table))">
                        <table name="{$table}" op="create"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="$tables">
                <s:tables>
                    <xsl:for-each-group select="$tables" group-by="@name">
                        <xsl:sort select="@name"/>
                        <xsl:variable name="ops" select="current-group()/@op" as="node()*"/>
                        <s:table name="{current-grouping-key()}" ops="{distinct-values($ops)}"/>
                    </xsl:for-each-group>
                </s:tables>
            </xsl:if>
            <!-- handle joins -->
            <xsl:variable name="joins" as="node()*">
                <xsl:apply-templates select="g:*" mode="join"/>
            </xsl:variable>
            <xsl:if test="$joins">
                <s:joins>
                    <xsl:sequence select="$joins"/>
                </s:joins>
            </xsl:if>
        </s:procedure>
    </xsl:template>

    <xsl:template match="text()" mode="join"/>
    <xsl:template match="g:*" mode="join">
        <xsl:apply-templates mode="join"/>
    </xsl:template>
    <xsl:template match="g:table-source-item[following-sibling::g:join-part]" mode="join">
        <s:join>
            <xsl:variable name="joins" as="node()*">
                <s:table name="{g:table-name/g:id}" table-alias="{g:table-alias/g:id}"/>
                <xsl:apply-templates select="following-sibling::g:join-part" mode="join">
                    <xsl:with-param name="first" select="g:table-name/g:id" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:for-each select="$joins[self::s:col]">
                <xsl:variable name="alias" select="@table-alias"/>
                <s:col table="{$joins[self::s:table][@table-alias=$alias]/@name}" table-alias="{$alias}" column="{@column}"/>
            </xsl:for-each>
        </s:join>
    </xsl:template>
    <xsl:template match="g:full-column-name" mode="join">
        <xsl:param name="first" as="node()*" tunnel="yes"/>
        <xsl:if test="$first">
            <s:col table-alias="{g:table-name/g:id}" column="{g:id}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="g:table-source-item" mode="join">
        <xsl:param name="first" as="node()*" tunnel="yes"/>
        <xsl:if test="$first">
            <s:table name="{g:table-name/g:id}" table-alias="{g:table-alias/g:id}"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="g:execute-statement" mode="header">
        <xsl:choose>
            <xsl:when test="g:execute-body/g:func-proc-name">
                <s:call name="{g:execute-body/g:func-proc-name//g:t}"/>
            </xsl:when>
            <xsl:otherwise>
                <s:call name="dynamic()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- header -->
    <xsl:template match="g:column-elem/g:table-name" mode="header" priority="1"/>
    <xsl:template match="g:full-column-name/g:table-name" mode="header" priority="1"/>
    <xsl:template match="g:column-elem" mode="header">
        <s:table name="{.//g:id//g:t}"/>
    </xsl:template>
    <xsl:template match="g:table-name|g:full-table-name" mode="header">
        <s:table name="{.//g:t}"/>
    </xsl:template>

    <!-- normal mode -->
    <xsl:template match="g:sql-script">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="c:*/text()">
        <xsl:call-template name="split-text">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>


    <!-- named templates -->

    <xsl:template name="split-text">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="matches($text,'\n')">
                <xsl:for-each select="tokenize($text,'\r?\n' )">
                    <xsl:value-of select="."/>
                    <h:br/>
                    <xsl:value-of select="'&#x0a;'"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>