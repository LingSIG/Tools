<?xml version="1.0" encoding="utf-8"?>
<!-- tei2conllu.xsl -->
<!-- Version 1.0 -->
<!-- Andreas Nolda 2025-12-05 -->

<!-- This XSLT stylesheet converts linguistic data, marked up with attributes from the
     att.linguistic and att.linguistic.dependency attribute classes, from TEI to CoNLL-U. -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0">

<xsl:output method="text"
            encoding="UTF-8"/>

<xsl:strip-space elements="*"/>

<!-- templates -->

<xsl:template match="/">
  <xsl:apply-templates select="*[not(ancestor::tei:teiHeader)]" mode="conllu"/>
</xsl:template>

<!-- process children -->
<xsl:template match="*" mode="conllu">
  <xsl:apply-templates mode="conllu"/>
</xsl:template>

<!-- process parent elements of elements with @depN attribute
     (typically <s>, <cl>, and <phr>) -->
<xsl:template match="*[*[@depN]]" mode="conllu">
  <!-- ensure that each child has @depN and @depR, @depE, or @type="surface" attributes -->
  <xsl:if test="not(*[not(@depN and (@depR or @depE or @type='surface'))])">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number count="*[*[@depN]]"
                      level="any"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text># sent_id = </xsl:text>
    <xsl:value-of select="$id"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:text># text = </xsl:text>
    <xsl:apply-templates mode="conllu-text"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates mode="conllu-field"/>
    <xsl:text>&#xA;</xsl:text>
  </xsl:if>
</xsl:template>

<!-- process elements with @depN attribute
     (typically <w> and <pc>) -->
<xsl:template match="*[@depN]" mode="conllu-text">
  <xsl:if test="preceding-sibling::*[1][not(@join='right')]">
    <xsl:text>&#x20;</xsl:text>
  </xsl:if>
  <xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<xsl:template match="*[@depN]" mode="conllu-field">
  <!-- data -->
  <xsl:variable name="id"
                select="@depN"/>
  <xsl:variable name="form"
                select="normalize-space(.)"/>
  <xsl:variable name="lemma"
                select="@lemma"/>
  <xsl:variable name="upos">
    <xsl:call-template name="get-first-item">
      <xsl:with-param name="text"
                      select="normalize-space(@pos)"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="xpos">
    <xsl:call-template name="get-second-item">
      <xsl:with-param name="text"
                      select="normalize-space(@pos)"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="feats"
                select="@msd"/>
  <xsl:variable name="head">
    <xsl:call-template name="get-first-item">
      <xsl:with-param name="text"
                      select="@depR"/>
      <xsl:with-param name="sep">:</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="deprel">
    <xsl:call-template name="get-second-item">
      <xsl:with-param name="text"
                      select="@depR"/>
      <xsl:with-param name="sep">:</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="deps"
                select="@depE"/>
  <xsl:variable name="misc">
    <xsl:choose>
      <xsl:when test="@join='right'">
        <xsl:text>SpaceAfter=No</xsl:text>
      </xsl:when>
      <!-- ... -->
    </xsl:choose>
  </xsl:variable>
  <!-- output -->
  <!-- ID column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$id"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- FORM column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$form"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- LEMMA column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$lemma"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- UPOS column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$upos"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- XPOS column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$xpos"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- FEATS column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$feats"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- HEAD column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$head"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- DEPREL column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$deprel"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- DEPS column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$deps"/>
  </xsl:call-template>
  <xsl:text>&#x9;</xsl:text>
  <!-- MISC column -->
  <xsl:call-template name="output-field">
    <xsl:with-param name="text"
                    select="$misc"/>
  </xsl:call-template>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

<!-- ignore text -->
<xsl:template match="text()" mode="conllu"/>

<!-- helper templates -->

<xsl:template name="get-first-item">
  <xsl:param name="text"/>
  <xsl:param name="sep">
    <!-- Whitespace-only content is discarded unless it is enclosed in <xsl:text>. -->
    <xsl:text>&#x20;</xsl:text>
  </xsl:param>
  <xsl:choose>
    <xsl:when test="contains($text,$sep)">
      <xsl:value-of select="substring-before($text,$sep)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-second-item">
  <xsl:param name="text"/>
  <xsl:param name="sep">
    <!-- Whitespace-only content is discarded unless it is enclosed in <xsl:text>. -->
    <xsl:text>&#x20;</xsl:text>
  </xsl:param>
  <xsl:if test="contains($text,$sep)">
    <xsl:variable name="text-without-first-item"
                  select="substring-after($text,
                                          concat(substring-before($text,$sep),$sep))"/>
    <xsl:choose>
      <xsl:when test="contains($text-without-first-item,$sep)">
        <xsl:call-template name="get-first-item">
          <xsl:with-param name="text"
                          select="$text-without-first-item"/>
          <xsl:with-param name="sep"
                          select="$sep"/>
        </xsl:call-template>
        <xsl:message>
          <xsl:text>Warning: ignoring extraneous item(s) "</xsl:text>
          <xsl:value-of select="substring-after($text-without-first-item,
                                                concat(substring-before($text-without-first-item,$sep),$sep))"/>
          <xsl:text>"</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
      <xsl:value-of select="$text-without-first-item"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="output-field">
  <xsl:param name="text"/>
  <xsl:choose>
    <xsl:when test="string-length($text)&gt;0">
      <xsl:value-of select="$text"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>_</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>
