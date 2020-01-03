<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://ing.com/vortex/sql/grammar" xmlns:c="http://ing.com/vortex/sql/comments"
    xmlns:f="http://ing.com/vortex/sql/functions" xmlns="http://www.w3.org/1999/xhtml">
    <xsl:output method="html" version="4.0" encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="c:c"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <html>
            <head>
                <style>
                    body {
                        font-family: "Ing Me", Times, serif;
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
                    }
                    .const {
                        color: Blue;
                    }
                </style>
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
            <xsl:when test="matches(.,'^\s+$')">
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
