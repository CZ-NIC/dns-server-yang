<?xml version="1.0"?>

<!-- Program name: common.xsl

Copyright © 2015 by Ladislav Lhotka, CZ.NIC <lhotka@nic.cz>

Common XSLT templates.

==
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->

<stylesheet
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"
    xmlns:dnss="http://www.nic.cz/ns/yang/dns-server"
    version="1.0">
  <output method="text"/>
  <strip-space elements="*"/>

  <!-- Parameters & variables -->

  <param name="indent-step" select="4"/>
  <variable name="spaces">
    <text>                                        </text>
  </variable>
  
  <!-- Named templates -->

  <!-- Insert number of spaces corresponding to the $level of indentation -->
  <template name="indent">
    <param name="level" select="1"/>
    <value-of select="substring($spaces, 1, $level * $indent-step)"/>
  </template>
  
  <!-- Translate boolean values -->
  <template name="boolean">
    <param name="value" select="."/>
    <param name="true">yes</param>
    <param name="false">no</param>
    <choose>
      <when test="$value = 'true'">
	<value-of select="$true"/>
      </when>
      <otherwise>
	<value-of select="$false"/>
      </otherwise>
    </choose>
  </template>

  <!-- Insert value of $nodeset or the default -->
  <template name="value-or-default">
    <param name="nodeset"/>
    <param name="dflt"/>
    <choose>
      <when test="$nodeset">
	<apply-templates select="$nodeset" mode="value"/>
      </when>
      <otherwise>
	<value-of select="$dflt"/>
      </otherwise>
    </choose>
  </template>

  <!-- Insert section -->
  <template name="section">
    <param name="name" select="local-name()"/>
    <value-of select="concat('&#xA;', $name, ':&#xA;')"/>
  </template>

  <!-- Insert key-value pair -->
  <template name="key-value">
    <param name="level" select="1"/> <!-- level of indentation -->
    <param name="key" select="local-name()"/> <!-- key -->
    <param name="sep">: </param>	       <!-- separator -->
    <param name="quote"/>	               <!-- quote char -->
    <param name="value" select="."/>	       <!-- value -->
    <param name="dflt">__NO_DEFAULT__</param>  <!-- default value -->
    <param name="term" select="'&#xA;'"/>      <!-- terminator -->
    <if test="$value != $dflt">
      <call-template name="indent">
	<with-param name="level" select="$level"/>
      </call-template>
      <value-of select="concat($key, $sep, $quote, $value, $quote, $term)"/>
    </if>
  </template>

  <!-- Insert hash-style comment line -->
  <template name="hash-comment">
    <param name="text"/>
    <param name="level" select="0"/>
    <call-template name="indent">
      <with-param name="level" select="$level"/>
    </call-template>
    <text>#</text>
    <if test="string-length($text) &gt; 0">
      <value-of select="concat(' ', normalize-space($text))"/>
    </if>
    <text>&#xA;</text>
  </template>

  <!-- Strip prefix from $qn if present -->
  <template name="strip-prefix">
    <param name="qn" select="."/>
    <choose>
      <when test="contains($qn, ':')">
	<value-of select="substring-after($qn, ':')"/>
      </when>
      <otherwise>
	<value-of select="$qn"/>
      </otherwise>
    </choose>
  </template>

  <!-- Matching templates -->
  
  <!-- Root template -->
  <template match="/">
    <apply-templates select="//nc:*/dnss:dns-server"/>
  </template>

  <!-- Without a specific template, issue a warning. -->
  <template match="*">
    <message terminate="no">
      <value-of select="concat('Element ', name(), ' not handled.')"/>
    </message>
  </template>

</stylesheet>
