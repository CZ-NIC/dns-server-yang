<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

<xsl:param name="i-d-name">draft-FOO</xsl:param>
<xsl:param name="i-d-rev">XX</xsl:param>
<xsl:param name="date">YYYY-MM-DD</xsl:param>
<xsl:variable name="mm-dd" select="substring-after($date,'-')"/>
<xsl:variable name="month">
  <xsl:variable name="mm" select="substring-before($mm-dd,'-')"/>
  <xsl:choose>
    <xsl:when test="$mm = 1">January</xsl:when>
    <xsl:when test="$mm = 2">February</xsl:when>
    <xsl:when test="$mm = 3">March</xsl:when>
    <xsl:when test="$mm = 4">April</xsl:when>
    <xsl:when test="$mm = 5">May</xsl:when>
    <xsl:when test="$mm = 6">June</xsl:when>
    <xsl:when test="$mm = 7">July</xsl:when>
    <xsl:when test="$mm = 8">August</xsl:when>
    <xsl:when test="$mm = 9">September</xsl:when>
    <xsl:when test="$mm = 10">October</xsl:when>
    <xsl:when test="$mm = 11">November</xsl:when>
    <xsl:when test="$mm = 12">December</xsl:when>
    <xsl:otherwise>***set date***</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="*|@*|text()|comment()|processing-instruction()">
  <xsl:copy>
    <xsl:apply-templates
	select="*|@*|text()|comment()|processing-instruction()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/rfc">
  <xsl:copy>
    <xsl:if test="not(@docName)">
      <xsl:attribute name="docName">
	<xsl:value-of select="concat($i-d-name,'-',$i-d-rev)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@ipr)">
      <xsl:attribute name="ipr">trust200902</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates
	select="*|@*|text()|comment()|processing-instruction()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/rfc/@docName">
  <xsl:attribute name="docName">
    <xsl:value-of select="concat(.,'-',$i-d-rev)"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="/rfc/front/date">
  <xsl:element name="date">
    <xsl:attribute name="day">
      <xsl:value-of select="substring-after($mm-dd,'-')"/>
    </xsl:attribute>
    <xsl:attribute name="month">
      <xsl:value-of select="$month"/>
    </xsl:attribute>
    <xsl:attribute name="year">
      <xsl:value-of select="substring-before($date,'-')"/>
    </xsl:attribute>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
