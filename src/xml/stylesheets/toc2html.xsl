<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" version="4.0"
                encoding="UTF-8" indent="yes"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <html>
            <head>
                <style>
                    div.tree {
                    margin-left:10px;
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
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <!-- procedure -->
    <xsl:template match="procedure">
        <h1>
            <xsl:value-of select="@name"/>
        </h1>
        <table>
            <tr>
                <th>used tables</th>
                <th>called procedures</th>
            </tr>
            <tr>

                <td>
                    <ul>
                        <xsl:apply-templates select="tables/table"/>
                    </ul>
                </td>
                <td>
                    <ul>
                        <xsl:apply-templates select="calls/call"/>
                    </ul>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="table">
        <li>
            <xsl:value-of select="@name"/>
        </li>
    </xsl:template>
    <xsl:template match="call">
        <li>
            <xsl:value-of select="@name"/>
        </li>
    </xsl:template>
</xsl:stylesheet>