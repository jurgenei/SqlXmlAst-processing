<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" version="4.0"
                encoding="UTF-8" indent="yes"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <html>
            <head>
                <style>
                    div.tree {
                    margin-left: 15px;
                    }
                    div.tree {
                    margin-left: 25px;
                    }
                    div.table {
                    margin-left: 25px;
                    }
                    proc_body {
                    margin-left: 30px;
                    }
                    body {
                    font-family: "Ing Me", Times, serif;
                    }
                    th, td {
                    vertical-align: top;
                    }
                </style>
            </head>
            <body>
                <h1>vortex SQL index</h1>
                <div>
                    <xsl:for-each select="/processors/processor">
                        <a href="{concat('#',@name)}">
                            <xsl:value-of select="@name"/>
                        </a>
                        <xsl:if test="not(position() = last())">
                            <xsl:value-of select="', '"/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <!-- procedure -->
    <xsl:template match="processor">
        <h1>
            <a name="{@name}"/>
            <xsl:value-of select="@name"/>
        </h1>
        <div class="proc_body">
            <xsl:apply-templates select="database"/>
        </div>
    </xsl:template>
    <xsl:template match="database">
        <h2>
            <xsl:value-of select="@name"/>
            <xsl:value-of select="' database'"/>
        </h2>
        <table>
            <tr>
                <td>
                    <h3>call tree</h3>
                    <div class="tree">
                        <xsl:apply-templates select="calls/call"/>
                    </div>
                </td>
                <td>
                    <h3>used tables</h3>
                    <div class="table">
                        <xsl:for-each select="tables/table/@name">
                            <xsl:value-of select="."/>
                            <xsl:if test="not(position() = last())">
                                <xsl:value-of select="', '"/>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="call">
        <h4>
            <xsl:value-of select="@name"/>
        </h4>
        <xsl:apply-templates select="call" mode="tree"/>
    </xsl:template>
    <xsl:template match="call[@name ='log_msg']" mode="tree"/>
    <xsl:template match="call[@name ='get_exception_info']" mode="tree"/>
    <xsl:template match="call[@name ='ret_log']" mode="tree"/>
    <xsl:template match="call[starts-with(@name,'insert_dmi_log')]" mode="tree"/>
    <xsl:template match="call" mode="tree">
        <div>
            <xsl:value-of select="@name"/>
        </div>
        <div class="tree">
            <xsl:apply-templates select="call" mode="tree"/>
        </div>
    </xsl:template>
</xsl:stylesheet>