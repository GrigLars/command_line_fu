<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml">

<xsl:output method="text" encoding="UTF-8"/>

<xsl:template match="/k3b_audio_project">
<xsl:apply-templates select="contents">
</xsl:apply-templates>
</xsl:template>


<xsl:template match="contents">
<xsl:apply-templates select="track">
</xsl:apply-templates>
</xsl:template>

<xsl:template match="track">
<xsl:value-of select="cd-text/artist"/>
<xsl:text> - </xsl:text>
<xsl:value-of select="cd-text/title"/>
<xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>
