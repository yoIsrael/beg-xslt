<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="link">
  <xsl:param name="href" />
  <xsl:param name="content" />
  <a href="{$href}"><xsl:copy-of select="$content" /></a>
</xsl:template>

<xsl:template name="durationMins">
  <xsl:param name="duration" select="'PT0H0M'" />
  <xsl:variable name="d" 
                select="substring(normalize-space($duration), 3)" />
  <xsl:variable name="durationHours">
    <xsl:choose>
      <xsl:when test="contains($d, 'H')">
        <xsl:value-of select="substring-before($d, 'H')" />
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="durationMinutes">
    <xsl:choose>
      <xsl:when test="contains($d, 'M')">
        <xsl:choose>
          <xsl:when test="contains($d, 'H')">
            <xsl:value-of select="substring-before(
                                  substring-after($d, 'H'), 'M')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-before($d, 'M')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="($durationHours * 60) + $durationMinutes" />
</xsl:template>

<xsl:template name="totalDuration">
  <xsl:param name="programs" select="/.." />
  <xsl:param name="totalHours" select="0" />
  <xsl:param name="totalMinutes" select="0" />
  <xsl:choose>
    <xsl:when test="$programs">
      <xsl:variable name="duration" 
                    select="normalize-space($programs[1]/Duration)" />
      <xsl:variable name="hours">
        <xsl:choose>
          <xsl:when test="contains($duration, 'H')">
            <xsl:value-of select="substring-before(
                                  substring-after($duration, 'PT'), 
                                  'H')" />
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="minutes">
        <xsl:choose>
          <xsl:when test="contains($duration, 'M')">
            <xsl:choose>
              <xsl:when test="contains($duration, 'H')">
                <xsl:value-of select="substring-before(
                                      substring-after($duration, 'H'), 
                                      'M')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="substring-before(
                                      substring-after($duration, 'PT'), 
                                      'M')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="totalDuration">
        <xsl:with-param name="programs" 
                        select="$programs[position() > 1]" />
        <xsl:with-param name="totalHours" select="$totalHours + $hours" />
        <xsl:with-param name="totalMinutes"
                        select="$totalMinutes + $minutes" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="finalHours" 
                    select="$totalHours + floor($totalMinutes div 60)" />
      <xsl:variable name="finalMinutes"
                    select="($totalMinutes mod 60) div 60" />
      <xsl:value-of select="format-number($finalHours + $finalMinutes, '0.00')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="replace">
  <xsl:param name="string" />
  <xsl:param name="search" select="/.." />
  <xsl:choose>
    <xsl:when test="$string and $search">
      <xsl:variable name="nextSearch" 
                    select="$search/following-sibling::search[1]" />
      <xsl:choose>
        <xsl:when test="contains($string, $search)">
          <xsl:call-template name="replace">
            <xsl:with-param name="string" 
                            select="substring-before($string, $search)" />
            <xsl:with-param name="search"
                            select="$nextSearch" />
          </xsl:call-template>
          <xsl:copy-of 
            select="$search/following-sibling::replace[1]/node()" />
          <xsl:call-template name="replace">
            <xsl:with-param name="string" 
                            select="substring-after($string, $search)" />
            <xsl:with-param name="search" select="$search" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="replace">
            <xsl:with-param name="string" select="$string" />
            <xsl:with-param name="search" select="$nextSearch" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:key name="months" match="month" use="@num" />

<xsl:template name="formatDate">
  <xsl:param name="date" select="." />
  <xsl:variable name="year" select="substring($date, 1, 4)" />
  <xsl:variable name="month" select="substring($date, 6, 2)" />
  <xsl:variable name="day" select="substring($date, 9, 2)" />
  <xsl:variable name="time" select="substring($date, 12, 5)" />
  <xsl:value-of select="$time" />
  <xsl:text> on </xsl:text>
  <xsl:value-of select="number($day)" />
  <xsl:text> </xsl:text>
  <xsl:for-each select="document('months.xml')">
    <xsl:value-of select="key('months', number($month))/@abbr" />
  </xsl:for-each>
  <xsl:text> </xsl:text>
  <xsl:value-of select="$year" />
</xsl:template>

</xsl:stylesheet>