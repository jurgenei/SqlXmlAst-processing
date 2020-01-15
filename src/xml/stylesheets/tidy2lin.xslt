<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://ing.com/vortex/sql/grammar" xmlns:c="http://ing.com/vortex/sql/comments"
    xmlns:f="http://ing.com/vortex/sql/functions" 
    xmlns:l="http://ing.com/vortex/sql/lineage" exclude-result-prefixes="f g c">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="xref-uri"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="c c:c"/>

   
   
   
    <!-- remove top level tag -->
    <xsl:template match="/">
        <l:lineage>
            <xsl:apply-templates select="g:envelope/g:sql"/>
        </l:lineage>
    </xsl:template>
    <xsl:template match="g:sql">
        <xsl:apply-templates select=".//g:create-procedure-body"/>
    </xsl:template>
    <xsl:template match="g:create-procedure-body">
        <l:procedure name="{g:procedure-name/g:id}">
            <xsl:apply-templates/>
        </l:procedure>
    </xsl:template>

    <xsl:template match="g:merge-statement">
        <xsl:variable name="a" as="node()*">
            <xsl:apply-templates select="f:merge-statement(.)" mode="catsql"/>
        </xsl:variable>
        <xsl:apply-templates select="$a" mode="tidy"/>
    </xsl:template>
    <xsl:template match="g:insert-statement">
        <xsl:variable name="a" as="node()*">
            <xsl:apply-templates select="f:insert-statement(.)" mode="catsql"/>
        </xsl:variable>
        <xsl:apply-templates select="$a" mode="tidy"/>
    </xsl:template>
    <xsl:template match="g:update-statement">
        <xsl:variable name="a" as="node()*">
            <xsl:apply-templates select="f:update-statement(.)" mode="catsql"/>
        </xsl:variable>
        <xsl:apply-templates select="$a" mode="tidy"/>
    </xsl:template>

    <!-- 
        handle merge statement 
    -->


    <xsl:function name="f:merge-statement">
        <xsl:param name="source" as="node()*"/>
        <xsl:variable name="to" select="$source/g:merge-target/g:table" as="node()*"/>
        <!-- from part -->
        <xsl:variable name="select-statement" select="$source//g:select-statement" as="node()*"/>
        <xsl:variable name="source-cols"
            select="$select-statement//g:select-list-elements/g:expression" as="node()*"/>
        <l:merge to-table="{$to}">
            <xsl:sequence select="f:insert-select($source-cols, (), $to)"/>
        </l:merge>
    </xsl:function>


    <!-- 
        handle insert statement 
    -->


    <xsl:function name="f:insert-statement">
        <xsl:param name="source" as="node()*"/>
        <xsl:variable name="into-clause" select="$source//g:insert-into-clause" as="node()*"/>

        <!-- to part -->
        <xsl:variable name="to" select="$into-clause//g:table" as="node()*"/>
        <xsl:variable name="target-cols" as="node()*">
            <xsl:apply-templates select="$into-clause//g:column-list/g:column-name/g:column"
                mode="clean"/>
        </xsl:variable>

        <!-- from part -->
        <xsl:variable name="select-statement" select="$source//g:select-statement" as="node()*"/>
        <xsl:variable name="source-cols"
            select="$select-statement//g:select-list-elements/g:expression" as="node()*"/>

        <!-- results -->
        <l:insert to-table="{$to}">
            <!--
            <test source-cols="{count($source-cols)}" target-cols="{count($target-cols)}"/>
            -->
            <xsl:sequence select="f:insert-select($source-cols, $target-cols, $to)"/>
        </l:insert>
    </xsl:function>


    <xsl:function name="f:insert-select">
        <xsl:param name="source" as="node()*"/>
        <xsl:param name="target" as="node()*"/>
        <xsl:param name="to" as="node()*"/>
        <xsl:choose>
            <xsl:when test="count($target) gt 0">
                <xsl:sequence select="f:zip-select($source, $target, $to)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tables" select="doc($xref-uri)//l:tables/l:table" as="node()*"/>
                <xsl:variable name="tab" select="$tables[@name=$to]" as="node()*"/>
                <xsl:sequence select="f:zip-select-no-target($source, $to,1,$tab)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="f:zip-select">
        <xsl:param name="source" as="node()*"/>
        <xsl:param name="target" as="node()*"/>
        <xsl:param name="to" as="node()*"/> 
        
        <xsl:choose>
            <xsl:when test="not(empty($source)) and not(empty($target))">
                <xsl:variable name="first-source" select="$source[1]"/>
                <xsl:variable name="rest-source" select="$source[position() gt 1]"/>
                <xsl:variable name="first-target" select="$target[1]"/>
                <xsl:variable name="rest-target" select="$target[position() gt 1]"/>
                <l:column name="{$first-target}" to-table="{$to}">
                    <xsl:apply-templates select="$first-source" mode="clean"/>
                </l:column>
                <xsl:sequence select="f:zip-select($rest-source, $rest-target, $to)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="f:zip-select-no-target">
        <xsl:param name="source" as="node()*"/>
        <xsl:param name="to" as="node()*"/>
        <xsl:param name="count"/>
        <xsl:param name="tab" as="node()*"/>
        <xsl:choose>
            <xsl:when test="not(empty($source))">
                <xsl:variable name="first-source" select="$source[1]"/>
                <xsl:variable name="rest-source" select="$source[position() gt 1]"/>
                <xsl:variable name="name" select="$tab/l:column[@colno=$count]/@name"/>
                <l:column colno="{$count}" name="{$name}" to-table="{$to}">
                    <xsl:apply-templates select="$first-source" mode="clean"/>
                </l:column>
                <xsl:sequence select="f:zip-select-no-target($rest-source, $to, $count + 1,$tab)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <!--      
      handle update statement 
    -->



    <xsl:function name="f:update-statement">
        <xsl:param name="source" as="node()*"/>
        <!-- to part -->
        <xsl:variable name="to" select="$source/g:general-table-ref" as="node()*"/>
        <xsl:variable name="set-clauses"
            select="$source/g:update-set-clause/g:column-based-update-set-clause"/>
        <!-- results -->
        <l:update  to-table="{$to}">
            <xsl:sequence select="f:zip-update($to, $set-clauses,$source)"/>
        </l:update>
    </xsl:function>

    <xsl:function name="f:zip-update">
        <xsl:param name="to" as="node()*"/>
        <xsl:param name="source" as="node()*"/>
        <xsl:param name="set-clauses" as="node()*"/>
        <xsl:for-each select="$set-clauses">
            <l:column name="{g:column-name/g:column}" to-table="{$to}">
                <xsl:apply-templates select="g:expression" mode="clean"/>
            </l:column>
        </xsl:for-each>
    </xsl:function>
    <!--
    clean mode
    -->
    <xsl:template match="*" mode="clean">
        <xsl:element name="{local-name(.)}">
            <xsl:apply-templates select="@* | node()" mode="clean"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*" mode="clean">
        <xsl:copy-of select="."/>
    </xsl:template>
    <!--
    <xsl:template match="c:*" mode="clean"/>
    -->
    <xsl:template match="c:*" mode="clean">
        <xsl:element name="{local-name(.)}">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text()" mode="clean">
        <xsl:value-of select="."/>
    </xsl:template>


    <xsl:template match="g:t[text() = '.']" mode="clean"/>


    <xsl:template match="g:expression[count(g:*) = 1]" mode="clean">
        <xsl:apply-templates mode="clean"/>
    </xsl:template>

    <xsl:template match="g:table-alias" mode="clean">
        <xsl:variable name="alias" select="."/>
        <xsl:element name="l:{local-name(.)}">
            <xsl:attribute name="table" select="f:table-for-alias($alias, .)"/>
            <xsl:apply-templates select="@* | node()" mode="clean"/>
        </xsl:element>

    </xsl:template>


    <xsl:function name="f:table-for-alias">
        <xsl:param name="alias" as="node()*"/>
        <xsl:param name="context" as="node()*"/>
        <xsl:sequence
            select="
                (
                $context/ancestor::g:*[g:table and g:table-alias = $alias]/g:table,
                $context/ancestor::g:*/g:from-clause//g:table
                )[1]"
        />
    </xsl:function>
    <xsl:template match="g:column" mode="clean">
        <xsl:element name="{local-name(.)}">
            <xsl:attribute name="from-table" select="(ancestor::g:*/g:from-clause//g:table)[1]"/>
            <xsl:apply-templates select="@* | node()" mode="clean"/>
        </xsl:element>
    </xsl:template>




    <xsl:template match="l:column | l:column-alias | l:table | l:const | l:insert | l:update | l:merge " priority="1" mode="catsql">
        <xsl:element name="l:{local-name(.)}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="catsql"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="l:column[preceding-sibling::l:table-alias]" priority="2" mode="catsql">
        <xsl:variable name="alias" select="preceding-sibling::l:table-alias/text()"/>
        <xsl:element name="{local-name(.)}">
            <xsl:copy-of select="@*"/>
            <xsl:if test="$alias and @from-table ne $alias">
                <xsl:attribute name="table-alias" select="$alias"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="catsql"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="l:table-alias" priority="6" mode="catsql"/>
    <xsl:template match="*" mode="catsql">
        <xsl:apply-templates select="@* | node()" mode="catsql"/>
    </xsl:template>
    <xsl:template match="text()" mode="catsql">
        <xsl:value-of select="."/>
    </xsl:template>




    <xsl:template match="l:*" mode="tidy">
        <xsl:element name="l:{local-name(.)}" >
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="tidy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="text()[matches(., '\s')]" mode="tidy">
        <xsl:variable name="sp-before"
            select="
                if (matches(., '^\s')) then
                    ' '
                else
                    ''"/>
        <xsl:variable name="sp-after"
            select="
                if (matches(., '\s$')) then
                    ' '
                else
                    ''"/>
        <xsl:value-of select="string-join(($sp-before, normalize-space(.), $sp-after), '')"/>
    </xsl:template>
    <xsl:template match="text()" mode="tidy">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <!--
    default strip naked text
    -->


    <xsl:template match="text()"/>
</xsl:stylesheet>
