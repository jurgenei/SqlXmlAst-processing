<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://ns.ing.com/fn">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>
    <xsl:param name="folder-uri" select="'file:.'"/>
    <xsl:param name="select-pattern" select="'*.xml'"/>
    <!--
      | The whole collection of simplfied SQL2XML documents
      -->
    <xsl:variable name="docs" select="collection(concat($folder-uri, '?recurse=yes;select=', $select-pattern))"/>
    <!--
      | traverse all simplfied SQL2XML documents
      -->
    <xsl:template name="main" match="/">
        <toc>
            <xsl:element name="{name($docs[1]/*)}" namespace="{namespace-uri($docs[1]/*)}">
                <xsl:apply-templates select="$docs/*/node()"/>
            </xsl:element>
        </toc>
    </xsl:template>
    <!--
      | each procedure
      -->
    <xsl:template match="create-or-alter-procedure">
        <procedure name="{func-proc-name}">
            <xsl:copy-of select="/sql/@*"/>
            <!-- list all store procedure invokations called in this procedure -->
            <xsl:variable name="calls" as="node()*">
                <xsl:apply-templates select=".//execute-statement"/>
            </xsl:variable>
            <xsl:if test="$calls">
                <calls>
                    <xsl:for-each-group select="$calls" group-by="@name">
                        <xsl:for-each select="current-grouping-key()">
                            <call name="{.}"/>
                        </xsl:for-each>
                    </xsl:for-each-group>
                </calls>
            </xsl:if>
            <!-- list all tables touched in this procdure -->
            <xsl:variable name="tables" as="node()*">
                <xsl:apply-templates select=".//*[matches(local-name(),'table-name')]"/>
            </xsl:variable>
            <xsl:if test="$tables">
                <tables>
                    <xsl:for-each-group select="$tables" group-by="@name">
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
                </tables>
            </xsl:if>
            <xsl:variable name="exceptions" as="node()*">
                <xsl:apply-templates select=".//*[matches(local-name(),'select-list-elem')]"/>
            </xsl:variable>
            <xsl:if test="$exceptions">
                <exceptions>
                    <xsl:copy-of select="$exceptions"/>
                </exceptions>
            </xsl:if>
        </procedure>
    </xsl:template>


    <!--
      | match procedure calls in a procedure
      -->
    <xsl:template match="execute-statement[ancestor::create-or-alter-procedure]">
        <xsl:choose>
            <xsl:when test="execute-body/func-proc-name">
                <call name="{execute-body/func-proc-name}">
                    <xsl:apply-templates/>
                </call>
            </xsl:when>
            <xsl:otherwise>
                <call name="dynamic()"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <!--
      | match table touches in a procedure
      -->
    <!--
    <xsl:template match="*[matches(local-name(),'table-name') and ancestor::create-or-alter-procedure]">
        <xsl:variable name="crud" select="normalize-space(replace(replace(ancestor::*[
            matches(local-name(),'-statement')
            and not(matches(local-name(),'loop|block|if|security'))
            ][1]/local-name(),'-statement',''),'-from',''))"/>
        <xsl:variable name="mode">
            <xsl:choose>
                <xsl:when test="matches($crud,'insert|delete|update') and matches($crud,'select')">
                    <xsl:value-of select="'rw'"/>
                </xsl:when>
                <xsl:when test="matches($crud,'insert|delete|update')">
                    <xsl:value-of select="'wo'"/>
                </xsl:when>
                <xsl:when test="matches($crud,'select')">
                    <xsl:value-of select="'ro'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'none'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="table-name" select="descendant-or-self::*[local-name() eq 'table-name' or local-name() eq 'full-table-name']"/>
        <table name="{$table-name}" op="{$crud}" mode="{$mode}"/>
    </xsl:template>
    -->
    <xsl:template match="*[matches(local-name(),'table-name') and ancestor::create-or-alter-procedure]">
        <xsl:variable name="parent" select="../local-name()"/>
        <table name="{.}">
            <xsl:choose>
                <xsl:when test="matches($parent,'insert-statement|update-statement|delete-statement')">
                    <xsl:attribute name="op" select="replace($parent,'-statement','')"/>
                    <xsl:attribute name="mode">rw</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="op">read</xsl:attribute>
                    <xsl:attribute name="mode">ro</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </table>
    </xsl:template>
    <xsl:template match="select-list-elem[matches(.,'@exception_code') and ancestor::create-or-alter-procedure]">
        <xsl:variable name="exception_code">
            <xsl:analyze-string select="." regex="@exception_code=['&quot;](.+)['&quot;]$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:if test="string-length($exception_code) gt 1">
            <xsl:variable name="exception_category_node" select="../select-list-elem[matches(.,'@exception_category')]"/>
            <xsl:variable name="exception_category">
                <xsl:analyze-string select="if ($exception_category_node) then $exception_category_node else ''"
                                    regex="@exception_category=['&quot;](.+)['&quot;]$">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>#EMPTY</xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="solution_code_node" select="../select-list-elem[matches(.,'@solution_code')]"/>
            <xsl:variable name="solution_code">
                <xsl:analyze-string select="if ($solution_code_node) then $solution_code_node else ''"
                                    regex="@solution_code=['&quot;](.+)['&quot;]$">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>#EMPTY</xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <exception name="{$exception_code}" exception_category="{$exception_category}" solution_code="{$solution_code}"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>