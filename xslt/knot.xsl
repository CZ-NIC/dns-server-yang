<?xml version="1.0"?>

<!-- Program name: knot.xsl

Copyright © 2015 by Ladislav Lhotka, CZ.NIC <lhotka@nic.cz>

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
    xmlns:dnss="http://www.nic.cz/ns/yang/dns-server"
    xmlns:knot="http://www.nic.cz/ns/yang/knot-dns"
    version="1.0">
  <output method="text"/>
  <strip-space elements="*"/>
  <include href="common.xsl"/>

  <!-- Named templates -->

  <template name="on-off">
    <param name="value" select="."/>
    <call-template name="boolean">
      <with-param name="value" select="$value"/>
      <with-param name="true">on</with-param>
      <with-param name="false">off</with-param>
    </call-template>
  </template>

  <template name="list-key">
    <param name="name" select="local-name()"/>
    <param name="value" select="."/>
    <param name="quote"/>
    <value-of select="concat('  - ', $name, ': ')"/>
    <value-of select="concat($quote, $value, $quote)"/>
    <text>&#xA;</text>
  </template>

  <template name="yaml-list">
    <param name="name"/>
    <param name="nodeset"/>
    <if test="count($nodeset) &gt; 0">
      <call-template name="key-value">
	<with-param name="key" select="$name"/>
	<with-param name="value">
	  <if test="count($nodeset) &gt; 1">[</if>
	  <for-each select="$nodeset">
	    <apply-templates select="." mode="value"/>
	    <if test="position() != last()">, </if>
	  </for-each>
	  <if test="count($nodeset) &gt; 1">]</if>
	</with-param>
      </call-template>
    </if>
  </template>

  <template name="address-port">
    <value-of select="dnss:ip-address|knot:ip-address"/>
    <if test="dnss:port">
      <text>@</text>
      <value-of select="dnss:port|knot:port"/>
    </if>
  </template>

  <template name="zone-options">
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:file"/>
    <apply-templates select="dnss:zones-dir"/>
    <call-template name="yaml-list">
      <with-param name="name">master</with-param>
      <with-param name="nodeset" select="dnss:master"/>
    </call-template>
    <apply-templates select="dnss:notify"/>
    <call-template name="yaml-list">
      <with-param name="name">acl</with-param>
      <with-param name="nodeset" select="dnss:access-control-list"/>
    </call-template>
    <apply-templates select="knot:semantic-checks"/>
    <apply-templates select="dnss:any-to-tcp"/>
    <apply-templates select="dnss:dnssec-signing"/>
    <apply-templates select="dnss:journal"/>
    <call-template name="yaml-list">
      <with-param name="name">module</with-param>
      <with-param name="nodeset" select="dnss:query-module"/>
    </call-template>
  </template>

  <!-- Matching templates -->

  <template match="dnss:dns-server">
    <call-template name="hash-comment">
      <with-param name="text">
	Configuration of Knot DNS server
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
    <apply-templates select="dnss:access-control-list"/>
    <apply-templates select="dnss:remote-server"/>
    <apply-templates select="knot:log"/>
    <apply-templates select="knot:control-socket"/>
    <apply-templates select="dnss:query-module"/>
    <apply-templates select="dnss:zones"/>
  </template>

  <template match="dnss:dns-server/dnss:description">
    <call-template name="hash-comment">
      <with-param name="text" select="."/>
    </call-template>
  </template>

  <template match="dnss:description|knot:description">
    <call-template name="key-value">
      <with-param name="key">comment</with-param>
      <with-param name="value" select="normalize-space(.)"/>
      <with-param name="quote">"</with-param>
    </call-template>
  </template>

  <template match="dnss:name|knot:name">
    <call-template name="list-key">
      <with-param name="name">id</with-param>
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
    <call-template name="yaml-list">
      <with-param name="name">listen</with-param>
      <with-param name="nodeset" select="dnss:listen-endpoint"/>
    </call-template>
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
    <call-template name="key-value">
      <with-param name="key">identity</with-param>
      <with-param name="quote">"</with-param>
    </call-template>
  </template>

  <template match="dnss:chaos-identity/dnss:version">
    <call-template name="key-value">
      <with-param name="quote">"</with-param>
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

  <template match="dnss:listen-endpoint" mode="value">
    <call-template name="address-port"/>
  </template>

  <template match="dnss:resources">
    <apply-templates select="dnss:max-tcp-clients
			     |dnss:max-udp-size
			     |knot:*"/>
  </template>

  <template match="dnss:max-tcp-clients">
    <call-template name="key-value">
      <with-param name="dflt" select="100"/>
    </call-template>
  </template>

  <template match="dnss:max-udp-size">
    <call-template name="key-value">
      <with-param name="key">max-udp-payload</with-param>
      <with-param name="dflt">100</with-param>
    </call-template>
  </template>

  <template match="knot:tcp-idle-timeout">
    <call-template name="key-value">
      <with-param name="dflt" select="20"/>
    </call-template>
  </template>

  <template match="knot:tcp-handshake-timeout">
    <call-template name="key-value">
      <with-param name="dflt" select="5"/>
    </call-template>
  </template>

  <template match="knot:tcp-reply-timeout">
    <call-template name="key-value">
      <with-param name="dflt" select="10"/>
    </call-template>
  </template>

  <template match="dnss:filesystem-paths">
    <apply-templates select="dnss:run-time-dir|dnss:pid-file"/>
  </template>

  <template match="dnss:run-time-dir">
    <call-template name="key-value">
      <with-param name="key">rundir</with-param>
    </call-template>
  </template>

  <template match="dnss:pid-file">
    <call-template name="key-value">
      <with-param name="key">pidfile</with-param>
    </call-template>
  </template>

  <template match="dnss:privileges">
    <call-template name="key-value">
      <with-param name="key">user</with-param>
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
    <call-template name="key-value">
      <with-param name="key">rate-limit</with-param>
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
    <call-template name="key-value">
      <with-param name="key">rate-limit-slip</with-param>
    </call-template>
  </template>

  <template match="dnss:table-size">
    <call-template name="key-value">
      <with-param name="key">rate-limit-table-size</with-param>
      <with-param name="dflt" select="393241"/>
    </call-template>
  </template>

  <!-- key -->

  <template match="dnss:dns-server/dnss:key">
    <call-template name="section-first"/>
    <apply-templates select="dnss:name"/>
    <apply-templates select="dnss:description"/>
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

  <!-- acl -->

  <template match="dnss:access-control-list">
    <call-template name="section-first">
      <with-param name="name">acl</with-param>
    </call-template>
    <apply-templates select="dnss:name"/>
    <apply-templates select="dnss:description"/>
    <call-template name="yaml-list">
      <with-param name="name">address</with-param>
      <with-param name="nodeset" select="dnss:network"/>
    </call-template>
    <call-template name="yaml-list">
      <with-param name="name">key</with-param>
      <with-param name="nodeset" select="dnss:key"/>
    </call-template>
    <call-template name="yaml-list">
      <with-param name="name">action</with-param>
      <with-param name="nodeset" select="dnss:operation"/>
    </call-template>
    <apply-templates select="dnss:action"/>
  </template>

  <template match="dnss:access-control-list/dnss:network" mode="value">
    <value-of select="dnss:ip-prefix"/>
  </template>

  <template match="dnss:action">
    <call-template name="key-value">
      <with-param name="key">deny</with-param>
      <with-param name="value">
	<choose>
	  <when test=". = 'allow'">off</when>
	  <otherwise>on</otherwise>
	</choose>
      </with-param>
      <with-param name="dflt">off</with-param>
    </call-template>
  </template>

  <!-- remote -->

  <template match="dnss:remote-server">
    <call-template name="section-first">
      <with-param name="name">remote</with-param>
    </call-template>
    <apply-templates select="dnss:name"/>
    <apply-templates select="dnss:description"/>
    <apply-templates select="dnss:remote"/>
    <apply-templates select="dnss:local"/>
    <apply-templates select="dnss:key"/>
  </template>

  <template match="dnss:remote">
    <call-template name="key-value">
      <with-param name="key">address</with-param>
      <with-param name="value">
	<call-template name="address-port"/>
      </with-param>
    </call-template>
  </template>

  <template match="dnss:local">
    <call-template name="key-value">
      <with-param name="key">via</with-param>
      <with-param name="value">
	<call-template name="address-port"/>
      </with-param>
    </call-template>
  </template>

  <!-- log -->

  <template match="knot:log">
    <call-template name="section-first"/>
    <apply-templates select="knot:description"/>
    <call-template name="list-key">
      <with-param name="name">target</with-param>
      <with-param name="value">
	<apply-templates select="knot:stdout|knot:stderr
				 |knot:syslog|knot:file" mode="value"/>
      </with-param>
    </call-template>
    <apply-templates select="knot:server"/>
    <apply-templates select="knot:zone"/>
    <apply-templates select="knot:any"/>
  </template>

  <!-- control -->

  <template match="knot:control-socket">
    <call-template name="section">
      <with-param name="name">control</with-param>
    </call-template>
    <call-template name="key-value">
      <with-param name="key">listen</with-param>
      <with-param name="value">
	<choose>
	  <when test="knot:unix">
	    <value-of select="knot:unix"/>
	  </when>
	  <when test="knot:ip-address">
	    <call-template name="address-port"/>
	  </when>
	  <otherwise>knot.sock</otherwise>
	</choose>
      </with-param>
      <with-param name="dflt">knot.sock</with-param>
    </call-template>
    <call-template name="yaml-list">
      <with-param name="name">acl</with-param>
      <with-param name="nodeset" select="knot:access-control-list"/>
    </call-template>
  </template>

  <!-- query modules -->

  <template match="dnss:query-module">
    <variable name="typ">
      <call-template name="strip-prefix">
	<with-param name="qn" select="dnss:type"/>
      </call-template>
    </variable>
    <call-template name="section">
      <with-param name="name" select="concat('mod-', $typ)"/>
    </call-template>
    <apply-templates select="dnss:name"/>
    <apply-templates select="." mode="content"/>
  </template>

  <template match="dnss:query-module[dnss:type='knot:dnstap']"
	    mode="content">
    <apply-templates select="knot:dnstap"/>
  </template>
  
  <template match="knot:dnstap">
    <call-template name="key-value">
      <with-param name="key">sink</with-param>
      <with-param name="value">
	<apply-templates select="knot:file|knot:unix-socket"
			 mode="value"/>
      </with-param>
    </call-template>
  </template>

  <template match="dnss:query-module/knot:unix-socket"
	    mode="value">
    <value-of select="concat('&quot;unix:', ., '&quot;')"/>
  </template>
  
  <template match="dnss:query-module[dnss:type='knot:synth-record']"
	    mode="content">
    <apply-templates select="knot:synth-record"/>
  </template>
  
  <template match="knot:synth-record">
    <apply-templates select="knot:record-type"/>
    <apply-templates select="knot:prefix"/>
    <apply-templates select="knot:origin"/>
    <apply-templates select="knot:ttl"/>
    <apply-templates select="knot:network"/>
  </template>

  <template match="knot:record-type">
    <call-template name="key-value">
      <with-param name="key">type</with-param>
    </call-template>
  </template>
  
  <template match="dnss:query-module[dnss:type='knot:dnsproxy']"
	    mode="content">
    <apply-templates select="knot:dnsproxy"/>
  </template>

  <template match="knot:dnsproxy">
    <apply-templates select="knot:remote-server"/>
  </template>

  <template match="knot:remote-server">
    <call-template name="key-value">
      <with-param name="key">remote</with-param>
      <with-param name="value">
	<call-template name="address-port"/>
      </with-param>
    </call-template>
  </template>
  
  <template match="dnss:query-module[dnss:type='knot:rosedb']"
	    mode="content">
    <apply-templates select="knot:rosedb"/>
  </template>
  
  <template match="knot:rosedb">
    <apply-templates select="knot:db-dir"/>
  </template>
  
  <template match="knot:db-dir">
    <call-template name="key-value">
      <with-param name="key">dbdir</with-param>
      <with-param name="quote">"</with-param>
    </call-template>
  </template>
  
  <!-- template & zone -->

  <template match="dnss:zones">
    <apply-templates select="dnss:template"/>
    <apply-templates select="dnss:zone"/>
  </template>

  <template match="dnss:zones/dnss:template">
    <call-template name="section-first"/>
    <apply-templates select="dnss:name"/>
    <call-template name="zone-options"/>
  </template>

  <template match="dnss:zone">
    <call-template name="section-first"/>
    <apply-templates select="dnss:domain"/>
    <apply-templates select="dnss:template"/>
    <call-template name="zone-options"/>
  </template>

  <template match="dnss:zone/dnss:domain">
    <call-template name="list-key"/>
  </template>

  <template match="dnss:zones-dir">
    <call-template name="key-value">
      <with-param name="key">storage</with-param>
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
    <apply-templates select="knot:kasp-db"/>
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

  <template match="dnss:secret
		   |knot:any
		   |knot:async-start
		   |knot:background-workers
		   |knot:network
		   |knot:origin
		   |knot:prefix
		   |knot:server
		   |knot:tcp-workers
		   |knot:ttl
		   |knot:udp-workers
		   |knot:zone">
    <call-template name="key-value"/>
  </template>

  <template match="dnss:key
		   |dnss:file
		   |knot:kasp-db 
		   |dnss:template">
    <call-template name="key-value">
      <with-param name="quote">"</with-param>
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
		   |knot:access-control-list
		   |knot:file
		   " mode="value">
    <value-of select="concat('&quot;', ., '&quot;')"/>
  </template>

  <template match="dnss:enabled" mode="value">
    <call-template name="on-off"/>
  </template>
  
  <template match="knot:stdout
		   |knot:stderr
		   |knot:syslog" mode="value">
    <value-of select="local-name()"/>
  </template>

</stylesheet>
