<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://ing.com/vortex/sql/grammar" xmlns:c="http://ing.com/vortex/sql/comments"
    xmlns:f="http://ing.com/vortex/sql/functions" xmlns="http://www.w3.org/1999/xhtml">
    <xsl:output method="html" version="4.0" encoding="UTF-8" indent="no"/>
    <xsl:param name="xref-uri" select="'file://xref.xml'"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="c:c"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <html>
            <head>
                <style>
                    body {
                        font-family: "Ing Me", Times, serif;
                        background-color: Honeydew;
                    }
                    h1 {
                        margin: 2px;
                        padding: 2px;
                    }
                    .sql-body {
                        font-family: "Consolas";
                        white-space: pre;
                    }
                    .t {
                        font-weight: bold;
                    }
                    .id {
                        color: green;
                    }
                    .id-table {
                        color: Red;
                    }
                    .id-table-alias {
                        color: Red;
                        font-style: italic;
                    }
                    .id-column {
                        color: Purple;
                    }
                    .id-column-alias {
                        color: Purple;
                        font-style: italic;
                    }
                    .comment {
                        color: Gray;
                        background-color: Honeydew;
                    }
                    .const {
                        color: Blue;
                    }
                    .column-list {
                        background-color: LightSalmon;
                    }
                    .select-list-elements {
                        background-color: Khaki;
                    }
                    .table-ref {
                        background-color: Aquamarine;
                    }
                    .header {
                        border-radius: 5px;
                        background: Thistle;
                        padding: 1px 5px 1px 5px;
                    }</style>
            </head>
            <body>
                <xsl:apply-templates select="g:envelope/g:sql"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="g:sql">
        <h1>
            <xsl:value-of select="@path"/>
        </h1>
        <xsl:variable name="pn" select=".//g:create-procedure-body/g:procedure-name"/>
        <xsl:variable name="xref" select="doc($xref-uri)" as="node()*"/>
        <xsl:variable name="lookup" select="$xref//g:procedure[@name = $pn]"/>
        <xsl:choose>
            <xsl:when test="$lookup">
                <xsl:variable name="callees" select="$lookup//g:callee"/>
                <xsl:variable name="calls" select="$lookup//g:calls[not(@pkg)]/g:call"/>
                <xsl:variable name="tables" select="$lookup//g:table"/>
                <xsl:variable name="i" select="$tables[@use = 'select']"/>
                <xsl:variable name="x" select="$tables[matches(@use, 'select')]"/>
                <xsl:variable name="o" select="$tables[not(matches(@use, 'select'))]"/>
                <div class="header">
                    <xsl:if test="$callees or $calls or $tables">
                        <table>
                            <xsl:if test="$callees or $calls">
                                <tr>
                                    <td>
                                        <xsl:if test="$callees">
                                            <span class="t">called by: </span>
                                            <xsl:for-each select="$callees">
                                                <a href="{@name}.html">
                                                  <xsl:value-of select="@name"/>
                                                </a>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:value-of select="' '"/>
                                    </td>
                                    <td>
                                        <xsl:if test="$calls">
                                            <span class="t">calls: </span>
                                            <xsl:for-each
                                                select="$lookup//g:calls[not(@pkg)]/g:call">
                                                <a href="{@name}.html">
                                                  <xsl:value-of select="@name"/>
                                                </a>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:if>
                            <xsl:if test="$tables">
                                <tr>
                                    <td>
                                        <xsl:if test="$i">
                                            <span class="t">input: </span>
                                            <xsl:for-each select="$i">
                                                <a href="../tables/{@name}.html">
                                                  <xsl:value-of select="@name"/>
                                                </a>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:if test="$x">
                                            <span class="t">input/output: </span>
                                            <xsl:for-each select="$x">
                                                <a href="../tables/{@name}.html">
                                                  <xsl:value-of select="@name"/>
                                                </a>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:if test="$o">
                                            <span class="t">output: </span>
                                            <xsl:for-each select="$o">
                                                <a href="../tables/{@name}.html">
                                                  <xsl:value-of select="@name"/>
                                                </a>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:if>
                        </table>
                    </xsl:if>
                </div>
            </xsl:when>
        </xsl:choose>
        <div class="sql-body">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="g:*[@object]">
        <span class="{local-name(.)}-{@object}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="g:t">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="g:*">
        <span class="{local-name(.)}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="c:*">
        <xsl:choose>
            <xsl:when test=". = ' '">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <span class="comment">
                    <xsl:value-of select="."/>
                </span>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
</xsl:stylesheet>
