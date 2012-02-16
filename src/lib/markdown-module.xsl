<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
xmlns:doc="http://www.xqdoc.org/1.0"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
exclude-result-prefixes="xs doc fn"
version="2.0">

<xsl:output method="xml" encoding="UTF-8"/>

<xsl:param name="source" as="xs:string"/>

  <xsl:function name="doc:escape" as="xs:string">
    <xsl:param name="string"/>
    <xsl:sequence select="replace($string,'\*','\\*')"/>
  </xsl:function>

  <!-- generate module html //-->
  <xsl:template match="//doc:xqdoc">
    <dummy>
    <xsl:apply-templates select="doc:module"/>
    <xsl:text>

## Table of Contents
</xsl:text>
    <xsl:apply-templates select="* except doc:module" mode="toc"/>
    <xsl:text>

</xsl:text>
    <xsl:apply-templates select="* except doc:module"/>
    <xsl:text>


*Generated by [xquerydoc](https://github.com/xquery/xquerydoc)*
</xsl:text>
    </dummy>
  </xsl:template>

  <xsl:template match="doc:module">
    <xsl:apply-templates select="doc:uri"/>
    <xsl:apply-templates select="* except doc:uri"/>
  </xsl:template>

  <xsl:template match="doc:uri">
    <xsl:text># </xsl:text><xsl:value-of select="doc:escape(../@type)"/><xsl:text> module: </xsl:text><xsl:value-of select="doc:escape(.)"/><xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="doc:variables[empty(doc:variable[not(@private)])]" mode="toc #default"/>

  <xsl:template match="doc:variables">
    <xsl:text>
## Variables
</xsl:text>
      <xsl:apply-templates/>
    <xsl:text>

</xsl:text>
  </xsl:template>

  <xsl:template match="doc:variable[@private]"/>

  <xsl:template match="doc:variable">
    <xsl:text>
### &lt;a name="</xsl:text><xsl:sequence select="concat('var_', replace(doc:uri, ':', '_'))"/><xsl:text>"/&gt; $</xsl:text><xsl:value-of select="doc:uri"/><xsl:text>
</xsl:text>
    <xsl:text>```xquery
$</xsl:text><xsl:value-of select="doc:uri"/><xsl:text> as </xsl:text><xsl:value-of select="doc:escape(doc:type)"/><xsl:value-of select="doc:escape(doc:type/@occurrence)"/><xsl:text>
```
</xsl:text>
    <xsl:apply-templates select="doc:comment"/>
  </xsl:template>

  <xsl:template match="doc:functions[empty(doc:function[not(@private)])]" mode="toc #default"/>

  <xsl:template match="doc:functions">
    <xsl:text>
## Functions
</xsl:text>
      <xsl:apply-templates/>
    <xsl:text>

</xsl:text>
  </xsl:template>

  <xsl:template match="doc:function[@private]"/>

  <xsl:template match="doc:function">
    <xsl:text>
### &lt;a name="</xsl:text><xsl:sequence select="concat('func_', replace(doc:name, ':', '_'), '_', @arity)"/><xsl:text>"/&gt; </xsl:text><xsl:value-of select="doc:name"/><xsl:text>\#</xsl:text><xsl:value-of select="count(.//doc:parameter)"/><xsl:text>
</xsl:text>
    <xsl:text>```xquery
</xsl:text><xsl:value-of select="doc:name"/><xsl:value-of select="doc:signature"/><xsl:text>
```
</xsl:text>
    <xsl:apply-templates select="* except (doc:name|doc:signature)"/>
  </xsl:template>

  <xsl:template match="doc:parameters">
    <xsl:text>
#### Params
</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="doc:parameter">
    <xsl:text>
* </xsl:text>
    <xsl:value-of select="doc:name"/><xsl:text> as </xsl:text><xsl:value-of select="doc:escape(doc:type)"/><xsl:value-of select="doc:escape(doc:type/@occurrence)"/>
    <xsl:variable name="name" select="string(doc:name)"/>
    <xsl:for-each select="../../doc:comment/doc:param[starts-with(normalize-space(.), $name) or starts-with(normalize-space(.), concat('$',$name))]">
      <xsl:value-of select="doc:escape(substring-after(normalize-space(.), $name))"/>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="doc:return">
    <xsl:text>
#### Returns
</xsl:text>
    <xsl:text>* </xsl:text>
    <xsl:value-of select="doc:escape(doc:type)"/><xsl:value-of select="doc:escape(doc:type/@occurrence)"/>
    <xsl:for-each select="../doc:comment/doc:return">
      <xsl:text>: </xsl:text>
      <xsl:value-of select="doc:escape(normalize-space(.))"/>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="doc:comment">
    <xsl:apply-templates mode="custom"/>
  </xsl:template>

  <xsl:template match="doc:description" mode="custom">
    <xsl:apply-templates mode="custom"/>
    <xsl:text>

</xsl:text>
  </xsl:template>

  <xsl:template match="*:h1" mode="custom">
    <xsl:text>
# </xsl:text><xsl:apply-templates mode="custom"/>
  </xsl:template>

  <xsl:template match="*:ul" mode="custom">
     <xsl:text>
</xsl:text><xsl:apply-templates mode="custom"/>
  </xsl:template>

  <xsl:template match="*:li" mode="custom">
    <xsl:text>
* </xsl:text><xsl:apply-templates mode="custom"/>
  </xsl:template>

  <xsl:template match="*:p" mode="custom">
    <xsl:text>

</xsl:text>
    <xsl:apply-templates mode="custom"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="*:pre" mode="custom">
    <xsl:text>
    </xsl:text><xsl:value-of select="replace(.,'&#10;','&#10;    ')"/>
  </xsl:template>

  <xsl:template match="doc:author" mode="custom #default">
    <xsl:text>
Author: </xsl:text><xsl:value-of select="doc:escape(.)"/>
  </xsl:template>

  <xsl:template match="doc:version" mode="custom #default">
    <xsl:text>
Version: </xsl:text><xsl:value-of select="doc:escape(.)"/>
  </xsl:template>

  <xsl:template match="doc:see" mode="custom">
    <!-- See also: -->
    <!-- <xsl:for-each select="tokenize(.,'[ \t\r\n,]+')[. ne '']"> -->
    <!--   <xsl:if test="position() ne 1"><xsl:text>, </xsl:text></xsl:if> -->
    <!--   <xsl:choose> -->
    <!--     <xsl:when test="contains(.,'#')"> -->
    <!--       <a href="#{ concat('func_', replace(substring-before(.,'#'), ':', '_'), -->
    <!--         '_', substring-after(.,'#')) }"> -->
    <!--         <xsl:value-of select="."/> -->
    <!--       </a> -->
    <!--     </xsl:when> -->
    <!--     <xsl:when test="starts-with(.,'$')"> -->
    <!--       <a href="#{ concat('var_', replace(substring-after(.,'$'), ':', '_')) }"> -->
    <!--         <xsl:value-of select="."/> -->
    <!--       </a> -->
    <!--     </xsl:when> -->
    <!--     <xsl:otherwise> -->
    <!--       <xsl:value-of select="."/> -->
    <!--     </xsl:otherwise> -->
    <!--   </xsl:choose> -->
    <!-- </xsl:for-each> -->
  </xsl:template>

  <xsl:template match="doc:param" mode="custom"/>
  <xsl:template match="doc:return" mode="custom"/>

  <!--xsl:template match="doc:custom" mode="custom">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="doc:param" mode="custom">
    <xsl:apply-templates select="."/>
  </xsl:template>


  <xsl:template match="doc:version" mode="custom">
    <xsl:apply-templates select="."/>
  </xsl:template-->

  <xsl:template match="doc:control"/>

  <xsl:template match="text()" mode="custom #default">
    <xsl:value-of select="doc:escape(.)"/>
  </xsl:template>



  <!-- Table of Contents -->

  <xsl:template match="element()" mode="toc"/>

  <xsl:template match="doc:variables" mode="toc">
    <xsl:text>
* Variables: </xsl:text>
    <xsl:for-each select="doc:variable[not(@private)]">
      <xsl:if test="position() ne 1"><xsl:text>, </xsl:text></xsl:if>
      <xsl:text>[$</xsl:text><xsl:value-of select="doc:uri"/><xsl:text>](#</xsl:text><xsl:sequence select="concat('var_', replace(doc:uri, ':', '_'))"/><xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="doc:functions" mode="toc">
    <xsl:text>
* Functions: </xsl:text>
    <xsl:for-each select="doc:function[not(@private)]">
      <xsl:if test="position() ne 1"><xsl:text>, </xsl:text></xsl:if>
      <xsl:text>[</xsl:text><xsl:value-of select="doc:name"/><xsl:text>\#</xsl:text><xsl:value-of select="count(.//doc:parameter)"/>
      <xsl:text>](#</xsl:text><xsl:sequence select="concat('func_', replace(doc:name, ':', '_'), '_', @arity)"/><xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
