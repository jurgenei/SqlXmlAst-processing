<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:f="http://ns.ing.com/fn"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
                version="2.0">
    <xsl:output method="html" version="4.0"
                encoding="UTF-8" indent="yes"/>
    <xsl:param name="book-title" select="'unknown'"/>
    <xsl:param name="book-author" select="'unknown'"/>
    <xsl:param name="book-pubdate" select="'unknown'"/>
    <xsl:param name="plant-uri" select="'file:.'"/>
    <xsl:variable name="plant-toc" select="document(concat($plant-uri,'.xml'))" as="node()*"/>
    <xsl:variable name="symbols" as="node()*">
        <symbol char="&#xf04b;" description="procedure called by processor"/>
        <symbol char="&#x0f06e;" description="read only access"/>
        <symbol char="&#x0f044;" description="read/write access"/>
        <symbol char="&#x0f00d;" description="unindentified access"/>
        <symbol char="&#xf274;" description="calls logging procedure"/>
        <symbol char="&#xF0E7;" description="contains dynamic sql"/>
        <symbol char="&#xF071;" description="vortex exception"/>
    </xsl:variable>
    <!-- remove top level tag -->
    <xsl:template match="/">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="A4"
                                       page-width="21cm"
                                       page-height="29.7cm">
                    <fo:region-body
                            margin-bottom="1.5cm"
                            margin-right="2cm"
                            margin-left="2cm"
                            margin-top="1.5cm"
                            column-count="2"/>
                    <fo:region-before margin-left="2cm" margin-right="2cm" extent="1.0cm"/>
                    <fo:region-after margin-left="2cm" margin-right="2cm" extent="1.0cm"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="A4-1col"
                                       page-width="21cm"
                                       page-height="29.7cm">
                    <fo:region-body
                            margin-bottom="1.5cm"
                            margin-right="2cm"
                            margin-left="2cm"
                            margin-top="1.5cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:bookmark-tree>

                <fo:bookmark internal-destination="by.processor">
                    <fo:bookmark-title>Processors</fo:bookmark-title>
                    <xsl:for-each-group select="/processors/processor" group-by="@category">
                        <fo:bookmark internal-destination="{current-grouping-key()}">
                            <fo:bookmark-title>
                                <xsl:value-of select="current-grouping-key()"/>
                            </fo:bookmark-title>
                            <xsl:for-each select="current-group()">
                                <fo:bookmark internal-destination="{@name}">
                                    <fo:bookmark-title>
                                        <xsl:value-of select="@name"/>
                                    </fo:bookmark-title>
                                </fo:bookmark>
                            </xsl:for-each>
                        </fo:bookmark>
                    </xsl:for-each-group>
                </fo:bookmark>

                <fo:bookmark internal-destination="by.table">
                    <fo:bookmark-title>Tables</fo:bookmark-title>
                    <xsl:for-each select="/processors/databases/database">
                        <xsl:variable name="dbtables" select="@name"/>
                        <fo:bookmark internal-destination="{@name}">
                            <fo:bookmark-title>
                                <xsl:value-of select="@name"/>
                            </fo:bookmark-title>
                            <xsl:for-each-group
                                    select="tables/table[not(.//processor/@name) and not(starts-with(@name,'#'))]"
                                    group-by="concat(@used-in-procs,@used-in-views)">
                                <xsl:variable name="group" select="current-grouping-key()"/>
                                <fo:bookmark internal-destination="{@name}.{$group}">
                                    <fo:bookmark-title>
                                        <xsl:choose>
                                            <xsl:when test="$group eq 'nono'">decom</xsl:when>
                                            <xsl:when test="$group eq 'noyes'">view only use</xsl:when>
                                            <xsl:when test="$group eq 'yesno'">procedure only use</xsl:when>
                                            <xsl:when test="$group eq 'yesyes'">procedure/view use</xsl:when>
                                            <xsl:otherwise>to be classified</xsl:otherwise>
                                        </xsl:choose>
                                    </fo:bookmark-title>
                                </fo:bookmark>
                            </xsl:for-each-group>
                        </fo:bookmark>
                    </xsl:for-each>
                </fo:bookmark>
            </fo:bookmark-tree>
            <fo:page-sequence master-reference="A4-1col">
                <fo:flow flow-name="xsl-region-body">
                    <fo:wrapper font-family="ING Me" font-size="12pt" text-align="center">
                        <fo:block margin-top="120pt" font-size="28pt" font-family="ING Me" color="#0050B2">
                            <xsl:value-of select="$book-title"/>
                        </fo:block>
                        <fo:block>
                            <xsl:value-of select="$book-author"/>
                        </fo:block>
                        <fo:block>
                            <xsl:value-of select="$book-pubdate"/>
                        </fo:block>
                        <fo:block margin-top="60pt" text-align="left" font-size="8pt">
                            <fo:block color="#0050B2">
                                <xsl:value-of select="'Legenda'"/>
                            </fo:block>
                            <xsl:for-each select="$symbols">
                                <fo:block>
                                    <fo:inline font-family="FontAwesome" color="#0050B2">
                                        <xsl:value-of select="@char"/>
                                    </fo:inline>
                                    <xsl:value-of select="concat(' ',@description)"/>
                                </fo:block>
                            </xsl:for-each>
                        </fo:block>
                    </fo:wrapper>
                </fo:flow>
            </fo:page-sequence>
            <fo:page-sequence master-reference="A4">
                <fo:static-content flow-name="xsl-region-before" text-align="end">
                    <fo:block margin-top="10pt" margin-right="20pt" font-size="10pt">
                        <fo:inline>
                            <fo:retrieve-marker
                                    retrieve-class-name="section.head.marker"
                                    retrieve-boundary="document"
                                    retrieve-position="first-including-carryover"/>
                        </fo:inline>
                        <fo:inline color="#0050B2">
                            <fo:retrieve-marker
                                    retrieve-class-name="topic.head.marker"
                                    retrieve-boundary="document"
                                    retrieve-position="first-including-carryover"/>
                        </fo:inline>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="xsl-region-after" text-align="end">
                    <fo:block font-size="8pt" margin-right="20pt">
                        <fo:inline color="#AAAAAA">
                            <xsl:value-of select="concat($book-title,' ', $book-pubdate,' ')"/>
                        </fo:inline>
                        <fo:inline>
                            <xsl:value-of select="' Page '"/>
                            <fo:page-number/>
                            <xsl:value-of select="' of '"/>
                            <fo:page-number-citation ref-id="TheVeryLastPage"/>
                        </fo:inline>
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:wrapper font-family="ING Me" font-size="12pt" text-align="justify">
                        <fo:block id="by.processor">
                            <xsl:for-each-group select="/processors/processor" group-by="@category">
                                <fo:block id="{current-grouping-key()}"
                                          font-weight="bold"
                                          font-size="22pt"
                                          space-after.optimum="6pt"
                                          space-before.optimum="16pt"
                                          span="all"
                                          margin-bottom="60pt"
                                          margin-top="60pt"
                                          keep-with-next="always"
                                          page-break-before="always">
                                    <fo:marker marker-class-name="section.head.marker">
                                        <xsl:value-of select="current-grouping-key()"/>
                                    </fo:marker>
                                    <xsl:value-of select="concat('Category ',current-grouping-key())"/>
                                </fo:block>
                                <xsl:apply-templates select="current-group()"/>
                            </xsl:for-each-group>
                        </fo:block>
                        <fo:block id="by.table"
                                  font-weight="bold"
                                  font-size="22pt"
                                  space-after.optimum="6pt"
                                  space-before.optimum="16pt"
                                  span="all"
                                  margin-bottom="60pt"
                                  margin-top="60pt"
                                  keep-with-next="always"
                                  page-break-before="always">
                            <xsl:value-of select="'By Table'"/>
                        </fo:block>

                        <xsl:for-each select="/processors/databases/database">
                            <xsl:variable name="dbtables" select="@name"/>
                            <xsl:variable name="section" select="concat($dbtables,' tables')"/>
                            <fo:block id="{@name}"
                                      font-weight="bold"
                                      font-size="12pt"
                                      color="#0050B2"
                                      space-after.optimum="6pt"
                                      space-before.optimum="16pt"
                                      span="all"
                                      border-after-style="solid"
                                      border-after-color="#0050B2"
                                      border-after-width="0.25pt"
                                      margin-bottom="4pt"
                                      margin-top="4pt"
                                      keep-with-next="always">
                                <xsl:if test="position() gt 1">
                                    <xsl:attribute name="page-break-before">always</xsl:attribute>
                                </xsl:if>
                                <fo:marker marker-class-name="section.head.marker">
                                    <xsl:value-of select="$dbtables"/>
                                </fo:marker>
                                <xsl:value-of select="concat('Tables ',$dbtables)"/>
                            </fo:block>
                            <fo:block>
                                <xsl:for-each select="tables/table[.//processor/@name and not(starts-with(@name,'#'))]">
                                    <xsl:sort select="@name"/>
                                    <xsl:call-template name="handle-table"/>
                                </xsl:for-each>
                            </fo:block>
                            <fo:block>
                                <xsl:for-each-group
                                        select="tables/table[not(.//processor/@name) and not(starts-with(@name,'#'))]"
                                        group-by="concat(@used-in-procs,@used-in-views)">
                                    <xsl:variable name="group" select="current-grouping-key()"/>
                                    <fo:block id="{@name}.{$group}"
                                              font-weight="bold"
                                              font-size="12pt"
                                              color="#0050B2"
                                              space-after.optimum="6pt"
                                              space-before.optimum="16pt"
                                              span="all"
                                              border-after-style="solid"
                                              border-after-color="#0050B2"
                                              border-after-width="0.25pt"
                                              margin-bottom="4pt"
                                              margin-top="4pt"
                                              keep-with-next="always">
                                        <xsl:variable name="use">
                                            <xsl:choose>
                                                <xsl:when test="$group eq 'nono'">not used, subject for decom</xsl:when>
                                                <xsl:when test="$group eq 'noyes'">used in view only</xsl:when>
                                                <xsl:when test="$group eq 'yesno'">used in procedure only</xsl:when>
                                                <xsl:when test="$group eq 'yesyes'">used in procedures and views
                                                </xsl:when>
                                                <xsl:otherwise>to be classified</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <fo:marker marker-class-name="topic.head.marker">
                                            <xsl:value-of select="$use"/>
                                        </fo:marker>
                                        <xsl:value-of select="concat('Tables ',$dbtables,' ',$use)"/>
                                    </fo:block>
                                    <fo:block font-size="8pt" text-align="left">
                                        <xsl:for-each select="current-group()">
                                            <xsl:sort select="@name"/>
                                            <xsl:value-of select="replace(@name,'_','_&#8203;')"/>
                                            <xsl:if test="not(position() = last())">
                                                <xsl:value-of select="', '"/>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </fo:block>
                                </xsl:for-each-group>
                            </fo:block>
                        </xsl:for-each>
                        <fo:block id="TheVeryLastPage"></fo:block>
                    </fo:wrapper>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    <xsl:template name="handle-table">
        <fo:block font-size="8pt" text-indent="-8pt" start-indent="8pt" text-align="left">
            <fo:marker marker-class-name="topic.head.marker">
                <xsl:value-of select="@name"/>
            </fo:marker>
            <fo:inline font-weight="bold">
                <xsl:value-of select="concat(replace(@name,'_','_&#8203;'),' ')"/>
            </fo:inline>
            <xsl:variable name="count" select="count(distinct-values(.//processor[@name]))"/>
            <xsl:for-each-group select=".//processor[@name]" group-by="@name">
                <xsl:variable name="processor" select="current-grouping-key()"/>
                <xsl:if test="$count gt 1">
                    <xsl:if test="position() gt 1">
                        <xsl:value-of select="' '"/>
                    </xsl:if>
                    <xsl:value-of select="concat(position(), ') ')"/>
                </xsl:if>
                <fo:inline color="#0050B2">
                    <xsl:value-of select="replace($processor,'_','_&#8203;')"/>
                </fo:inline>
                <xsl:value-of select="': '"/>
                <xsl:for-each select="current-group()">
                    <xsl:variable name="table" select=".."/>
                    <xsl:value-of select="replace($table/@name,'_','_&#8203;')"/>
                    <fo:inline font-family="FontAwesome" color="#0050B2">
                        <xsl:choose>
                            <xsl:when test="$table/@mode='ro'">&#x0f06e;</xsl:when>
                            <xsl:when test="$table/@mode='wo'">&#x0f044;</xsl:when>
                            <xsl:when test="$table/@mode='rw'">&#x0f044;</xsl:when>
                            <xsl:otherwise>&#x0f00d;</xsl:otherwise>
                        </xsl:choose>
                    </fo:inline>
                    <xsl:if test="not(position() = last())">
                        <xsl:value-of select="', '"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each-group>
        </fo:block>
    </xsl:template>
    <!-- procedure
    -->
    <xsl:template match="processor">
        <fo:block id="{@name}"
                  font-weight="bold"
                  font-size="12pt"
                  color="#0050B2"
                  space-after.optimum="6pt"
                  space-before.optimum="16pt"
                  span="all"
                  border-after-style="solid"
                  border-after-color="#0050B2"
                  border-after-width="0.25pt"
                  margin-bottom="4pt"
                  margin-top="4pt"
                  keep-with-next="always">
            <fo:marker marker-class-name="topic.head.marker">
                <xsl:value-of select="@name"/>
            </fo:marker>
            <xsl:value-of select="@name"/>
        </fo:block>
        <fo:block>
            <xsl:variable name="name" select="@name"/>
            <xsl:if test="$plant-toc//entry[@name=$name]">
                <xsl:variable name="svg" select="concat($plant-uri,'/',$name,'.svg')"/>
                <xsl:variable name="svg-root" select="document($svg)/svg:svg" as="node()*"/>
                <xsl:variable name="width" select="fn:replace($svg-root/@width,'\.[0-9]+','')"/>
                <xsl:variable name="height" select="fn:replace($svg-root/@height,'\.[0-9]+','')"/>

                <fo:instream-foreign-object height="{$height}" width="{$width}">
                    <xsl:copy-of select="$svg-root"/>
                </fo:instream-foreign-object>
            </xsl:if>
        </fo:block>
        <fo:block margin-bottom="4pt">
            <xsl:apply-templates select="database"/>
        </fo:block>
    </xsl:template>
    <xsl:template match="database">
        <xsl:if test="calls/call">
            <fo:block color="#0050B2" font-size="8pt"
                      keep-with-next="always">
                <xsl:variable name="count" select="count(calls//call)"/>
                <xsl:variable name="count-distinct" select="count(distinct-values(calls//call/@name))"/>
                <xsl:choose>
                    <xsl:when test="$count= 1">
                        <xsl:value-of select="concat(@name,' call tree with 1 procedure')"/>
                    </xsl:when>
                    <xsl:when test="$count gt $count-distinct">
                        <xsl:value-of
                                select="concat(@name,' call tree with ',$count, ' procedures (distinct ', $count-distinct,')')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(@name,' call tree with ',$count, ' procedures')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:block>
            <fo:block margin-bottom="4pt">
                <xsl:apply-templates select="calls/call"/>
            </fo:block>
        </xsl:if>
        <xsl:variable name="write-tables" select="tables/table[@mode = 'rw']" as="node()*"/>
        <xsl:variable name="read-tables" select="tables/table[@mode = 'ro']" as="node()*"/>
        <xsl:if test="$write-tables">
            <xsl:variable name="table-count" select="count($write-tables)"/>
            <fo:block color="#0050B2" font-size="8pt"
                      keep-with-next="always">
                <xsl:value-of
                        select="concat('writes ',$table-count, if ($table-count = 1) then ' table' else ' tables',' to ', @name)"/>
            </fo:block>
            <fo:block margin-bottom="4pt"
                      font-size="8pt"
                      text-align="left">
                <xsl:for-each select="$write-tables">
                    <xsl:value-of select="replace(@name,'_','_&#8203;')"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:value-of select="', '"/>
                    </xsl:if>
                </xsl:for-each>
            </fo:block>
        </xsl:if>
        <xsl:if test="$read-tables">
            <xsl:variable name="table-count" select="count($read-tables)"/>
            <fo:block color="#0050B2" font-size="8pt"
                      keep-with-next="always">
                <xsl:value-of
                        select="concat('reads ',$table-count, if ($table-count = 1) then ' table' else ' tables', ' from ',@name )"/>
            </fo:block>
            <fo:block margin-bottom="4pt"
                      font-size="8pt"
                      text-align="left">
                <xsl:for-each select="$read-tables">
                    <xsl:value-of select="replace(@name,'_','_&#8203;')"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:value-of select="', '"/>
                    </xsl:if>
                </xsl:for-each>
            </fo:block>
        </xsl:if>


    </xsl:template>
    <xsl:template match="call">
        <fo:block font-size="8pt">
            <fo:block>
                <fo:inline font-family="FontAwesome" color="#0050B2">&#xf04b;</fo:inline>
                <xsl:value-of select="concat(' ',@name)"/>
                <xsl:if test="some $m in call/@name satisfies matches($m,'^log_|_log$|_log_')">
                    <xsl:value-of select="' '"/>
                    <fo:inline font-family="FontAwesome" color="#0050B2">&#xf274;</fo:inline>
                </xsl:if>
                <xsl:if test="some $m in call/@name satisfies $m eq 'dynamic()'">
                    <xsl:value-of select="' '"/>
                    <fo:inline font-family="FontAwesome" color="#0050B2">&#xF0E7;</fo:inline>
                </xsl:if>
            </fo:block>
            <xsl:variable name="tree" as="node()*">
                <xsl:apply-templates select="call" mode="tree"/>
            </xsl:variable>
            <xsl:if test="$tree">
                <fo:block margin-left="14pt" margin-bottom="4pt">
                    <xsl:apply-templates select="call" mode="tree"/>
                </fo:block>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <xsl:template match="call[matches(@name,'^log_|_log$|_log_')]" mode="tree"/>
    <xsl:template match="call[@name = 'get_exception_info']" mode="tree"/>
    <xsl:template match="call[@name = 'dynamic()']" mode="tree"/>
    <xsl:template match="call" mode="tree">
        <fo:block text-align="left">
            <xsl:value-of select="@name"/>
            <xsl:if test="some $m in call/@name satisfies matches($m,'^log_|_log$|_log_')">
                <xsl:value-of select="' '"/>
                <fo:inline font-family="FontAwesome" color="#0050B2">&#xf274;</fo:inline>
            </xsl:if>
            <xsl:if test="some $m in call/@name satisfies $m eq 'dynamic()'">
                <xsl:value-of select="' '"/>
                <fo:inline font-family="FontAwesome" color="#0050B2">&#xF0E7;</fo:inline>
            </xsl:if>
            <xsl:if test="exceptions">
                <xsl:value-of select="' '"/>
                <fo:inline font-family="FontAwesome" color="#0050B2">&#xF071;</fo:inline>
            </xsl:if>
        </fo:block>
        <xsl:if test="exceptions">
            <fo:block font-style="italic" font-size="6pt" text-indent="3pt" margin-left="8pt" margin-right="30pt" fox:border-radius="3pt"
                      border-style="none"
                      background-color="#e8e8e8">
                <xsl:for-each select="exceptions/exception">
                    <fo:block>
                        <xsl:value-of select="concat(@exception_category,'_',@name,'_',@solution_code)"/>
                    </fo:block>
                </xsl:for-each>
            </fo:block>
        </xsl:if>
        <fo:block margin-left="8pt" font-size="8pt">
            <xsl:apply-templates select="call" mode="tree"/>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>