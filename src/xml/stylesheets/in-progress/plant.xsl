<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://ns.ing.com/fn" version="2.0">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>
    <!-- remove top level tag -->
    <xsl:variable name="entities" select="/process-model/entities/entitity" as="node()*"/>
    <xsl:variable name="flows" select="/process-model/flows/flow" as="node()*"/>

    <!--
    Determine each uniq entity
      -->
    <xsl:template match="/process-model">
        <plant>
            <xsl:variable name="nodes" as="node()*">
                <xsl:apply-templates select="flows/flow/@from"/>
                <xsl:apply-templates select="flows/flow/@to"/>
            </xsl:variable>
            <xsl:for-each-group select="$nodes" group-by="@name">
                <xsl:call-template name="render-entity">
                    <xsl:with-param name="entity" select="current-grouping-key()"/>
                </xsl:call-template>
            </xsl:for-each-group>
        </plant>
    </xsl:template>
    <xsl:template match="@from | @to">
        <node name="{.}"/>
    </xsl:template>
    <!--
    Render an entity
      -->
    <xsl:template name="render-entity">
        <xsl:param name="entity"/>
        <xsl:variable name="type" select="fn:entity-type($entity)"/>
        <entry name="{$entity}" type="{$type}"/>
        <xsl:result-document href="plant/{$entity}.puml" method="text">
            <xsl:value-of select="'@startuml&#10;'"/>
            <xsl:value-of select="'!include H:/Projects/plantuml/ing.iuml&#10;'"/>
            <xsl:value-of select="'skinparam nodesep 20&#10;'"/>
            <xsl:value-of select="'skinparam ranksep 20&#10;'"/>
            <xsl:value-of select="'skinparam shadowing false&#10;'"/>
            <xsl:value-of select="'scale max 240*180&#10;'"/>
            <xsl:variable name="nodes" as="node()*">
                <xsl:apply-templates select="$flows/@from[../@to = $entity]"/>
                <xsl:apply-templates select="$flows/@to[../@from = $entity]"/>
            </xsl:variable>
            <xsl:value-of select="concat($type,' &quot;**',$entity,'**&quot; as ',$entity,'&#10;')"/>
            <!--
            <xsl:value-of select="concat($type,' &quot;',$entity,'&quot; as ',$entity,'&#10;')"/>
            -->
            <xsl:for-each-group select="$nodes" group-by="@name">
                <xsl:variable name="this" select="current-grouping-key()"/>
                <xsl:variable name="type" select="fn:entity-type($this)"/>
                <xsl:value-of select="concat($type,' ', $this ,'&#10;')"/>
            </xsl:for-each-group>
            <xsl:for-each select="$flows[@to = $entity]">
                <xsl:choose>
                    <xsl:when test="fn:entity-type(@to) = 'database' or fn:entity-type(@from) = 'database'">
                        <xsl:value-of select="concat(@from,' --> ',@to,'&#10;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(@from,' -> ',@to,'&#10;')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="$flows[@from = $entity]">
                <xsl:choose>
                    <xsl:when test="fn:entity-type(@to) = 'database' or fn:entity-type(@from) = 'database'">
                        <xsl:value-of select="concat(@from,' --> ',@to,'&#10;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(@from,' -> ',@to,'&#10;')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:value-of select="'@enduml&#10;'"/>
        </xsl:result-document>
    </xsl:template>
    <xsl:function name="fn:entity-type">
        <xsl:param name="name"/>
        <xsl:variable name="type" select="$entities[@name = $name]/@type"/>
        <xsl:value-of select="if ($type) then $type else 'component'"/>
    </xsl:function>
</xsl:stylesheet>