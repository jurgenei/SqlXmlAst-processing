<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://ing.com/vortex/sql/grammar" xmlns:c="http://ing.com/vortex/sql/comments"
    xmlns:f="http://ing.com/vortex/sql/functions" xmlns="http://ing.com/vortex/sql/lin">
    <xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="xref-uri" select="'file://xref.xml'"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="c:c"/>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <lin>
            <xsl:apply-templates select="g:envelope/g:sql"/>
        </lin>
    </xsl:template>
    <xsl:template match="g:sql">
        <xsl:apply-templates select=".//g:create-procedure-body"/>
    </xsl:template>
    <xsl:template match="g:create-procedure-body">
        <procedure name="{g:procedure-name/g:id}">
            <xsl:apply-templates/>
        </procedure>
    </xsl:template>
    <xsl:template match="g:merge-statement">
        <merge target-table="{g:merge-target/g:id[1]}" alias="{g:merge-target/g:id[2]}"> </merge>
    </xsl:template>
    <xsl:template match="g:insert-statement">
        <insert target-table="{.//g:insert-into-clause/g:general-table-ref/g:id}"> 
            <xsl:apply-templates select=".//g:column-list/g:column-name" mode="insert"/>
        </insert>
    </xsl:template>
    <xsl:template match="g:column-name" mode="insert">
        <target-col name="{.}"/>
    </xsl:template>
    
    
    
    <xsl:template match="g:update-statement">
        <update target-table="{.//g:general-table-ref/g:id}">
            <xsl:apply-templates select=".//g:column-based-update-set-clause" mode="update"/>
        </update>
    </xsl:template>
    <xsl:template match="g:column-based-update-set-clause" mode="update">
        <target-col name="{g:column-name/g:id}"/>
    </xsl:template>
    
    

    <xsl:template match="text()"/>
</xsl:stylesheet>
