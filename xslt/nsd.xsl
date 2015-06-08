<?xml version="1.0"?>

<!-- Program name: nsd.xsl

Copyright © 2015 by Ladislav Lhotka, CZ.NIC <lhotka@nic.cz>

Translates XML instance configuration to NSD 4.1.1 config file.

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
    xmlns:dnss="http://www.nic.cz/ns/yang/dns-server"
    xmlns:nsd="http://www.nic.cz/ns/yang/nsd"
    version="1.0">
  <output method="text"/>
  <strip-space elements="*"/>
  <include href="common.xsl"/>

  <key name="remote" match="/dnss:dns-server/dnss:remote-server"
       use="dnss:name"/>

  <key name="acl" match="/dnss:dns-server/dnss:access-control-list"
       use="dnss:name"/>

  <!-- Named templates -->

  <template name="address-port">
    <value-of select="dnss:ip-address|nsd:ip-address"/>
    <if test="dnss:port">
      <text>@</text>
      <value-of select="dnss:port|nsd:port"/>
    </if>
  </template>

  <template name="zone-options">
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:name"/>
    <apply-templates select="dnss:file"/>
    <apply-templates select="dnss:master"/>
    <apply-templates select="dnss:notify"/>
    <apply-templates select="dnss:access-control-list"/>
  </template>

  <!-- Matching templates -->

  <template match="dnss:dns-server">
    <call-template name="hash-comment">
      <with-param name="text">
	Configuration of NSD DNS server
      </with-param>
    </call-template>
    <call-template name="hash-comment">
      <with-param name="text">
	(generated automatically from XML configuration)
      </with-param>
    </call-template>
    <call-template name="hash-comment"/>
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:server-options"/>
    <apply-templates select="dnss:key"/>
<!--    <apply-templates select="dnss:access-control-list"/>
    <apply-templates select="dnss:remote-server"/>
    <apply-templates select="dnss:query-module"/>
    <apply-templates select="dnss:zones"/>
-->
  </template>

  <template match="dnss:dns-server/dnss:description">
    <call-template name="hash-comment">
      <with-param name="text" select="."/>
    </call-template>
  </template>

  <template match="dnss:description|nsd:description">
    <call-template name="hash-comment">
      <with-param name="text" select="."/>
      <with-param name="level" select="1"/>
    </call-template>
  </template>

  <template match="dnss:name|nsd:name">
    <call-template name="key-value">
      <with-param name="name">name</with-param>
      <with-param name="quote">"</with-param>
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
    <choose>
      <when test="dnss:response-rate-limiting">
	<apply-templates select="dnss:response-rate-limiting"/>
      </when>
      <otherwise>
	<call-template name="key-value">
	  <with-param name="key">rrl-ratelimit</with-param>
	  <with-param name="value" select="0"/>
	</call-template>
      </otherwise>
    </choose>
  </template>

  <template match="dnss:chaos-identity">
    <apply-templates select="dnss:id-server"/>
    <apply-templates select="dnss:version"/>
  </template>

  <template match="dnss:id-server">
    <call-template name="key-value">
      <with-param name="key">identity</with-param>
      <with-param name="quote">"</with-param>
    </call-template>
  </template>

  <template match="dnss:chaos-identity/dnss:version">
    <call-template name="key-value">
      <with-param name="key">hide-version</with-param>
      <with-param name="value">no</with-param>
    </call-template>
  </template>

  <template match="dnss:nsid-identity">
    <apply-templates select="dnss:nsid"/>
  </template>

  <template match="dnss:nsid">
    <call-template name="key-value">
      <with-param name="quote">"</with-param>
    </call-template>
  </template>

  <template match="dnss:listen-endpoint">
    <call-template name="key-value">
      <with-param name="key">ip-address</with-param>
      <with-param name="value">
	<call-template name="address-port"/>
      </with-param>
    </call-template>
  </template>

  <template match="dnss:resources">
    <apply-templates select="dnss:max-tcp-clients
			     |dnss:max-udp-size"/>
  </template>

  <template match="dnss:max-tcp-clients">
    <call-template name="key-value">
      <with-param name="key">tcp-count</with-param>
      <with-param name="dflt" select="100"/>
    </call-template>
  </template>

  <template match="dnss:max-udp-size">
    <call-template name="key-value">
      <with-param name="key">ipv4-edns-size</with-param>
    </call-template>
    <call-template name="key-value">
      <with-param name="key">ipv6-edns-size</with-param>
    </call-template>
  </template>

  <template match="dnss:filesystem-paths">
    <apply-templates select="dnss:run-time-dir"/>
    <apply-templates select="dnss:pid-file"/>
  </template>

  <template match="dnss:run-time-dir">
    <call-template name="key-value">
      <with-param name="key">zonesdir</with-param>
    </call-template>
  </template>

  <template match="dnss:pid-file">
    <call-template name="key-value">
      <with-param name="key">pidfile</with-param>
    </call-template>
  </template>

  <template match="dnss:privileges">
    <apply-templates select="dnss:user"/>
  </template>

  <template match="dnss:user">
    <call-template name="key-value">
      <with-param name="key">user</with-param>
      <with-param name="value">
	<value-of select="."/>
	<if test="../dnss:group">
	  <text>.</text>
	  <value-of select="../dnss:group"/>
	</if>
      </with-param>
      <with-param name="dflt">root</with-param>
    </call-template>
  </template>
  
  <template match="dnss:response-rate-limiting">
    <call-template name="key-value">
      <with-param name="key">rate-limit</with-param>
      <with-param name="value">
	<call-template name="value-or-default">
	  <with-param name="nodeset"
		      select="dnss:responses-per-second"/>
	  <with-param name="dflt" select="5"/>
	</call-template>
      </with-param>
      <with-param name="dflt" select="200"/>
    </call-template>
    <call-template name="key-value">
      <with-param name="key">rrl-slip</with-param>
      <with-param name="value">
	<call-template name="value-or-default">
	  <with-param name="nodeset" select="dnss:slip"/>
	  <with-param name="dflt" select="1"/>
	</call-template>
      </with-param>
    </call-template>
    <apply-templates select="dnss:table-size"/>
  </template>

  <template match="dnss:table-size">
    <call-template name="key-value">
      <with-param name="key">rrl-size</with-param>
      <with-param name="dflt" select="393241"/>
    </call-template>
  </template>

  <!-- key -->

  <template match="dnss:dns-server/dnss:key">
    <call-template name="section"/>
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:name"/>
    <call-template name="key-value">
      <with-param name="key">algorithm</with-param>
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

  <!-- log -->

  <!-- control -->

  <!-- pattern & zone -->

  <template match="dnss:zones">
    <apply-templates select="dnss:template"/>
    <apply-templates select="dnss:zone"/>
  </template>

  <template match="dnss:zones/dnss:template">
    <call-template name="section">
      <with-param name="name">pattern</with-param>
    </call-template>
    <call-template name="zone-options"/>
  </template>

  <template match="dnss:zone">
    <call-template name="section"/>
    <apply-templates select="dnss:template"/>
    <call-template name="zone-options"/>
  </template>

  <template match="dnss:template">
    <call-template name="key-value">
      <with-param name="key">include-pattern</with-param>
    </call-template>
  </template>

  <template match="dnss:file">
    <call-template name="key-value">
      <with-param name="key">zonefile</with-param>
    </call-template>
  </template>

  <template match="dnss:notify">
    <call-template name="yaml-list">
      <with-param name="name">notify</with-param>
      <with-param name="nodeset" select="dnss:recipient"/>
    </call-template>
  </template>

  <template match="dnss:any-to-tcp">
    <call-template name="key-value">
      <with-param name="key">disable-any</with-param>
      <with-param name="value">
	<call-template name="on-off"/>
      </with-param>
    </call-template> 
  </template>

  <template match="dnss:dnssec-signing">
    <call-template name="key-value">
      <with-param name="key">dnssec-signing</with-param>
      <with-param name="value">
	<call-template name="value-or-default">
	  <with-param name="nodeset" select="dnss:enabled"/>
	  <with-param name="dflt">on</with-param>
	</call-template>
      </with-param>
      <with-param name="dflt">off</with-param>
    </call-template>
  </template>
  
  <template match="dnss:journal">
    <apply-templates select="dnss:zone-file-sync-delay"/>
    <apply-templates select="dnss:from-differences"/>
    <apply-templates select="maximum-journal-size"/>
  </template>

  <template match="dnss:zone-file-sync-delay">
    <call-template name="key-value">
      <with-param name="key">zonefile-sync</with-param>
      <with-param name="dflt" select="0"/>
    </call-template>
  </template>
  
  <template match="dnss:from-differences">
    <call-template name="key-value">
      <with-param name="key">ixfr-from-differences</with-param>
      <with-param name="value">
	<call-template name="on-off"/>
      </with-param>
      <with-param name="dflt">off</with-param>
    </call-template>
  </template>
  
  <template match="dnss:maximum-journal-size">
    <call-template name="key-value">
      <with-param name="key">max-journal-size</with-param>
    </call-template>
  </template>

  <template match="dnss:query-module" mode="value">
    <variable name="typ">
      <call-template name="strip-prefix">
	<with-param name="qn" select="dnss:type"/>
      </call-template>
    </variable>
    <value-of select="concat('&quot;', $typ, '/', dnss:name, '&quot;')"/>
  </template>

  <!-- Directly translated parameters -->

  <template match="dnss:secret">
    <call-template name="key-value"/>
  </template>

<!--  <template match="dnss:key
		   |dnss:template">
    <call-template name="key-value">
      <with-param name="quoted" select="1"/>
    </call-template>
  </template>

  <template match="knot:async-start
		   |knot:semantic-checks">
    <call-template name="key-value">
      <with-param name="value">
	<call-template name="on-off"/>
      </with-param>
    </call-template>
  </template>

  <template match="dnss:access-control-list
		   |dnss:master
		   |dnss:recipient
		   " mode="value">
    <value-of select="concat('&quot;', ., '&quot;')"/>
  </template>
-->

  <template match="dnss:enabled" mode="value">
    <call-template name="on-off"/>
  </template>
  
<!--  <template match="knot:stdout
		   |knot:stderr
		   |knot:syslog" mode="value">
    <value-of select="local-name()"/>
  </template>
-->

</stylesheet>
