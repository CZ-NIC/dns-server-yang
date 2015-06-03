<?xml version="1.0"?>

<!-- Program name: knot.xsl

Copyright © 2014 by Ladislav Lhotka, CZ.NIC <lhotka@nic.cz>

Translates XML instance configuration to Knot DNS 2.0 config file.

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
    xmlns:tsig="http://www.nic.cz/ns/yang/tsig-algorithms"
    xmlns:knot="http://www.nic.cz/ns/yang/knot-dns"
    version="1.0">
  <output method="text"/>
  <strip-space elements="*"/>

  <!-- Address family of the configuration -->
  <variable name="dnss-root" select="//nc:*/dnss:dns-server"/>

  <!-- Named templates -->
  
  <template name="on-off">
    <param name="bool"/>
    <choose>
      <when test="$bool = 'true'">on</when>
      <otherwise>off</otherwise>
    </choose>
  </template>

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

  <template name="section">
    <param name="sname" select="local-name()"/>
    <value-of select="concat($sname, ':&#xA;')"/>
  </template>
  
  <template name="parameter">
    <param name="name" select="local-name()"/>
    <param name="value" select="."/>
    <param name="quoted" select="0"/>
    <param name="dflt">__NO_DEFAULT__</param>
    <if test="$value != $dflt">
      <value-of select="concat('    ', $name, ': ')"/>
      <if test="$quoted">"</if>
      <value-of select="$value"/>
      <if test="$quoted">"</if>
      <text>&#xA;</text>
    </if>
  </template>
  
  <template name="list-key">
    <param name="kname" select="local-name()"/>
    <param name="kvalue" select="."/>
    <value-of select="concat('  - ', $kname, ': ', $kvalue, '&#xA;')"/>
  </template>

  <template name="comment">
    <param name="text"/>
    <text>#</text>
    <if test="string-length($text) &gt; 0">
      <value-of select="concat(' ', normalize-space($text))"/>
    </if>
    <text>&#xA;</text>
  </template>

  <!-- Root element -->

  <template match="/">
    <apply-templates select="//nc:*/dnss:dns-server"/>
  </template>
  
  <template match="dnss:dns-server">
    <call-template name="comment">
      <with-param name="text">
	Configuration of Knot DNS server
      </with-param>
    </call-template>
    <call-template name="comment">
      <with-param name="text">
	(generated automatically from XML configuration)
      </with-param>
    </call-template>
    <call-template name="comment"/>
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:server-options"/>
  </template>

  <template match="dnss:dns-server/dnss:description">
    <call-template name="comment">
      <with-param name="text" select="."/>
    </call-template>
  </template>
  
  <template match="dnss:description|knot:description">
    <call-template name="parameter">
      <with-param name="name">comment</with-param>
      <with-param name="value" select="normalize-space(.)"/>
      <with-param name="quoted" select="1"/>
    </call-template>
  </template>
  
  <template match="dnss:server-options">
    <call-template name="section">
      <with-param name="sname">server</with-param>
    </call-template>
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:chaos-identity"/>
    <apply-templates select="dnss:nsid-identity"/>
    <apply-templates select="dnss:listen-endpoint"/>
    <apply-templates select="dnss:resources"/>
    <apply-templates select="dnss:filesystem-paths"/>
    <apply-templates select="dnss:privileges"/>
    <apply-templates select="dnss:response-rate-limiting"/>
    <apply-templates select="knot:asynchronous-start"/>
  </template>

  <template match="dnss:chaos-identity">
    <apply-templates select="dnss:id-server"/>
    <apply-templates select="dnss:version"/>
  </template>

  <template match="dnss:id-server">
    <call-template name="parameter">
      <with-param name="name">identity</with-param>
      <with-param name="quoted" select="1"/>
    </call-template>
  </template>

  <template match="dnss:chaos-identity/dnss:version">
    <call-template name="parameter">
      <with-param name="quoted" select="1"/>
    </call-template>
  </template>
  
  <template match="dnss:nsid-identity">
    <apply-templates select="dnss:nsid"/>
  </template>

  <template match="dnss:nsid">
    <call-template name="parameter">
      <with-param name="quoted" select="1"/>
    </call-template>
  </template>

  <template match="dnss:listen-endpoint">
    <call-template name="parameter">
      <with-param name="name">listen</with-param>
      <with-param name="value">
	<value-of select="dnss:ip-address"/>
	<if test="dnss:port">
	  <text>@</text>
	  <value-of select="dnss:port"/>
	</if>
      </with-param>
    </call-template>
  </template>

  <template match="dnss:resources">
    <apply-templates select="dnss:max-tcp-clients
			     |dnss:max-udp-size
			     |knot:*"/>
  </template>

  <template match="dnss:max-tcp-clients">
    <call-template name="parameter">
      <with-param name="dflt" select="100"/>
    </call-template>
  </template>

  <template match="dnss:max-udp-size">
    <call-template name="parameter">
      <with-param name="name">max-udp-payload</with-param>
      <with-param name="dflt">100</with-param>
    </call-template>
  </template>

  <template match="knot:max-transfers">
    <call-template name="parameter">
      <with-param name="name">transfers</with-param>
      <with-param name="dflt">10</with-param>
    </call-template>
  </template>

  <template match="knot:max-conn-idle">
    <call-template name="parameter">
      <with-param name="dflt" select="20"/>
    </call-template>
  </template>

  <template match="knot:max-conn-handshake">
    <call-template name="parameter">
      <with-param name="dflt" select="5"/>
    </call-template>
  </template>

  <template match="knot:max-conn-reply">
    <call-template name="parameter">
      <with-param name="dflt" select="10"/>
    </call-template>
  </template>

  <template match="dnss:filesystem-paths">
    <apply-templates select="dnss:run-time-dir|dnss:pid-file"/>
  </template>

  <template match="dnss:run-time-dir">
    <call-template name="parameter">
      <with-param name="name">rundir</with-param>
    </call-template>
  </template>

  <template match="dnss:pid-file">
    <call-template name="parameter">
      <with-param name="name">pidfile</with-param>
    </call-template>
  </template>

  <template match="dnss:privileges">
    <call-template name="parameter">
      <with-param name="name">user</with-param>
      <with-param name="value">
	<value-of select="dnss:user"/>
	<if test="dnss:group and dnss:group != 'root'">
	  <text>:</text>
	  <value-of select="dnss:group"/>
	</if>
      </with-param>
      <with-param name="dflt">root</with-param>
    </call-template>
  </template>
  
  <template match="dnss:response-rate-limiting">
    <call-template name="parameter">
      <with-param name="name">rate-limit</with-param>
      <with-param name="value">
	<call-template name="value-or-default">
	  <with-param name="nodeset"
		      select="dnss:responses-per-second"/>
	  <with-param name="dflt" select="5"/>
	</call-template>
      </with-param>
    </call-template>
    <apply-templates select="dnss:slip|dnss:table-size"/>
  </template>

  <template match="dnss:slip">
    <call-template name="parameter">
      <with-param name="name">rate-limit-slip</with-param>
    </call-template>
  </template>

  <template match="dnss:table-size">
    <call-template name="parameter">
      <with-param name="name">rate-limit-size</with-param>
      <with-param name="dflt" select="393241"/>
    </call-template>
  </template>

  <!-- Directly translated parameters -->
  
  <template match="knot:workers
		   |knot:background-workers
		   |knot:asynchronous-start">
    <call-template name="parameter"/>
  </template>
  
  <!-- Without a specific template, issue a warning. -->
  <template match="*">
    <message terminate="no">
      <value-of select="concat('Element ', name(), ' not handled.')"/>
    </message>
  </template>

</stylesheet>
