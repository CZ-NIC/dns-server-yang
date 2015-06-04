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
    <param name="bool" select="."/>
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
    <param name="name" select="local-name()"/>
    <value-of select="concat($name, ':&#xA;')"/>
  </template>

  <template name="section-first">
    <param name="name" select="local-name()"/>
    <if test="position() = 1">
      <call-template name="section">
	<with-param name="name" select="$name"/>
      </call-template>
    </if>
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
    <param name="name" select="local-name()"/>
    <param name="value" select="."/>
    <value-of select="concat('  - ', $name, ': ', $value, '&#xA;')"/>
  </template>

  <template name="comment">
    <param name="text"/>
    <text>#</text>
    <if test="string-length($text) &gt; 0">
      <value-of select="concat(' ', normalize-space($text))"/>
    </if>
    <text>&#xA;</text>
  </template>

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
    <apply-templates select="dnss:key"/>
    <apply-templates select="dnss:access-control-list"/>
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

  <template match="dnss:name|knot:name">
    <call-template name="list-key">
      <with-param name="name">id</with-param>
    </call-template>
  </template>
  
  <!-- server -->
  
  <template match="dnss:server-options">
    <call-template name="section">
      <with-param name="name">server</with-param>
    </call-template>
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:chaos-identity"/>
    <apply-templates select="dnss:nsid-identity"/>
    <apply-templates select="dnss:listen-endpoint"/>
    <apply-templates select="dnss:resources"/>
    <apply-templates select="dnss:filesystem-paths"/>
    <apply-templates select="dnss:privileges"/>
    <apply-templates select="dnss:response-rate-limiting"/>
    <apply-templates select="knot:async-start"/>
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

  <template match="knot:tcp-idle-timeout">
    <call-template name="parameter">
      <with-param name="dflt" select="20"/>
    </call-template>
  </template>

  <template match="knot:tcp-handshake-timeout">
    <call-template name="parameter">
      <with-param name="dflt" select="5"/>
    </call-template>
  </template>

  <template match="knot:tcp-reply-timeout">
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
      <with-param name="name">rate-limit-table-size</with-param>
      <with-param name="dflt" select="393241"/>
    </call-template>
  </template>

  <!-- key -->

  <template match="dnss:key">
    <call-template name="section-first"/>
    <apply-templates select="dnss:name"/>
    <apply-templates select="dnss:description"/>
    <call-template name="parameter">
      <with-param name="name">algorithm</with-param>
      <with-param name="value">
	<call-template name="value-or-default">
	  <with-param name="nodeset" select="dnss:algorithm"/>
	  <with-param name="dflt">hmac-md5</with-param>
	</call-template>
      </with-param>
    </call-template>
    <apply-templates select="dnss:secret"/>
  </template>

  <template match="dnss:algorithm" mode="value">
    <variable name="alg">
      <call-template name="strip-prefix"/>
    </variable>
    <choose>
      <when test="$alg = 'HMAC-MD5.SIG-ALG.REG.INT'">hmac-md5</when>
      <otherwise>
	<value-of select="$alg"/>
      </otherwise>
    </choose>
  </template>

  <!-- acl -->

  <template match="dnss:access-control-list">
    <call-template name="section-first">
      <with-param name="name">acl</with-param>
    </call-template>
    <apply-templates select="dnss:name"/>
    <apply-templates select="dnss:description"/>
    <if test="dnss:access-list-entry"/>
  </template>

  <!-- Directly translated parameters -->
  
  <template match="dnss:secret
		   |knot:tcp-workers
		   |knot:udp-workers
		   |knot:background-workers
		   |knot:async-start">
    <call-template name="parameter"/>
  </template>

  <template match="knot:async-start">
    <call-template name="parameter">
      <with-param name="value">
	<call-template name="on-off"/>
      </with-param>
    </call-template>
  </template>
  
  <!-- Without a specific template, issue a warning. -->
  <template match="*">
    <message terminate="no">
      <value-of select="concat('Element ', name(), ' not handled.')"/>
    </message>
  </template>

</stylesheet>
