DNS-server-YANG
==============

Generic [YANG](https://tools.ietf.org/html/draft-ietf-netmod-rfc6020bis-05)
data model for a DNS server. 

Make Targets
------------

Below is a description of “public” make targets. Only _xsltproc_ is
needed for `all`, `knot` and `nsd`, other targets require
[pyang](https://github.com/mbj4668/pyang) to be installed. The
`validate` target also requires
[Jing](http://www.thaiopensource.com/relaxng/jing.html) to be
installed. Alternatively, _xmllint_ can be used instead, if the `-j`
flag is removed from the `validate` action.

* `all`: generate the YANG modules in the normal compact format;

* `json`: translate XML instance configuration (`example-data.xml`) to
  JSON format, see
  [draft-ietf-netmod-yang-json-03](https://tools.ietf.org/html/draft-ietf-netmod-yang-json);

* `knot`: translate XML instance to Knot DNS v2 configuration;

* `nsd`: translate XML instance to (partial) NSD configuration;

* `rnc`: generate RELAX NG schema in the compact syntax;

* `model.tree`: generate ASCII tree diagram of the data model.

Data Tree
---------

```
module: dns-server
   +--ro dns-server-state
   |  +--ro server
   |  +--ro zone* [domain]
   |     +--ro domain                   inet:domain-name
   |     +--ro dnssig:dnssec-signing
   |        +--ro dnssig:key* [key-id]
   |           +--ro dnssig:key-id       key-id
   |           +--ro dnssig:key-tag      uint16
   |           +--ro dnssig:algorithm    dsalg:dnssec-algorithm
   |           +--ro dnssig:length       uint16
   |           +--ro dnssig:publish?     yang:date-and-time
   |           +--ro dnssig:activate?    yang:date-and-time
   |           +--ro dnssig:retire?      yang:date-and-time
   |           +--ro dnssig:remove?      yang:date-and-time
   |           +--ro dnssig:created?     yang:date-and-time
   |           +--ro dnssig:flags?       bits
   +--rw dns-server
      +--rw description?           string
      +--rw server-options
      |  +--rw description?              string
      |  +--rw chaos-identity!
      |  |  +--rw id-server?   string
      |  |  +--rw version?     string
      |  +--rw nsid-identity!
      |  |  +--rw nsid?   string
      |  +--rw listen-endpoint* [name]
      |  |  +--rw name          string
      |  |  +--rw ip-address    inet:ip-address
      |  |  +--rw port?         inet:port-number
      |  +--rw resources
      |  |  +--rw max-tcp-clients?              uint16
      |  |  +--rw max-udp-size?                 uint16
      |  |  +--rw knot:tcp-workers?             uint8
      |  |  +--rw knot:udp-workers?             uint8
      |  |  +--rw knot:background-workers?      uint8
      |  |  +--rw knot:tcp-idle-timeout?        uint32
      |  |  +--rw knot:tcp-handshake-timeout?   uint32
      |  |  +--rw knot:tcp-reply-timeout?       uint32
      |  +--rw filesystem-paths
      |  |  +--rw run-time-dir?   fs-path
      |  |  +--rw pid-file?       fs-path
      |  +--rw privileges!
      |  |  +--rw user     string
      |  |  +--rw group?   string
      |  +--rw response-rate-limiting!
      |  |  +--rw responses-per-second?   uint16
      |  |  +--rw slip?                   uint8
      |  |  +--rw table-size?             uint32
      |  +--rw knot:async-start?         boolean
      +--rw access-control-list* [name]
      |  +--rw name           string
      |  +--rw description?   string
      |  +--rw network* [name]
      |  |  +--rw name         string
      |  |  +--rw ip-prefix    inet:ip-prefix
      |  |  +--rw port?        inet:port-number {acl-entry-port}?
      |  +--rw key*           key-ref
      |  +--rw operation*     enumeration
      |  +--rw action?        enumeration
      +--rw remote-server* [name]
      |  +--rw name           string
      |  +--rw description?   string
      |  +--rw remote
      |  |  +--rw ip-address    inet:ip-address
      |  |  +--rw port?         inet:port-number
      |  +--rw local!
      |  |  +--rw ip-address    inet:ip-address
      |  |  +--rw port?         inet:port-number
      |  +--rw key?           key-ref
      +--rw key* [name]
      |  +--rw name           string
      |  +--rw description?   string
      |  +--rw algorithm?     identityref
      |  +--rw secret         binary
      +--rw query-module* [type name]
      |  +--rw type                 identityref
      |  +--rw name                 string
      |  +--rw description?         string
      |  +--rw knot:dnstap!
      |  |  +--rw (sink)
      |  |     +--:(file)
      |  |     |  +--rw knot:file?          dnss:fs-path
      |  |     +--:(unix-socket)
      |  |        +--rw knot:unix-socket?   dnss:fs-path
      |  +--rw knot:synth-record!
      |  |  +--rw knot:record-type    enumeration
      |  |  +--rw knot:prefix         string
      |  |  +--rw knot:origin?        inet:domain-name
      |  |  +--rw knot:ttl?           uint16
      |  |  +--rw knot:network?       inet:ip-prefix
      |  +--rw knot:dnsproxy!
      |  |  +--rw knot:remote-server
      |  |     +--rw knot:ip-address    inet:ip-address
      |  |     +--rw knot:port?         inet:port-number
      |  +--rw knot:rosedb!
      |     +--rw knot:db-dir?   dnss:fs-path
      +--rw zones
      |  +--rw template* [name]
      |  |  +--rw name                     string
      |  |  +--rw default?                 boolean
      |  |  +--rw description?             string
      |  |  +--rw zones-dir?               fs-path
      |  |  +--rw file?                    fs-path
      |  |  +--rw master*                  remote-ref
      |  |  +--rw notify
      |  |  |  +--rw recipient*   remote-ref
      |  |  +--rw access-control-list*     acl-ref
      |  |  +--rw serial-update-method?    enumeration
      |  |  +--rw any-to-tcp?              boolean {any-to-tcp}?
      |  |  +--rw journal
      |  |  |  +--rw maximum-journal-size?   uint64
      |  |  |  +--rw zone-file-sync-delay?   uint32
      |  |  |  +--rw from-differences?       boolean {journal-from-differences}?
      |  |  +--rw query-module* [type name]
      |  |  |  +--rw type    -> /dns-server/query-module/type
      |  |  |  +--rw name    -> /dns-server/query-module[type=current()/../type]/name
      |  |  +--rw dnssig:dnssec-signing!
      |  |  |  +--rw dnssig:enabled?   boolean
      |  |  |  +--rw dnssig:policy?    -> /dnss:dns-server/dnssig:sign-policy/name
      |  |  |  +--rw knot:kasp-db?     string
      |  |  +--rw knot:semantic-checks?    boolean
      |  +--rw zone* [domain]
      |     +--rw domain                   inet:domain-name
      |     +--rw template?                -> /dns-server/zones/template/name
      |     +--rw description?             string
      |     +--rw zones-dir?               fs-path
      |     +--rw file?                    fs-path
      |     +--rw master*                  remote-ref
      |     +--rw notify
      |     |  +--rw recipient*   remote-ref
      |     +--rw access-control-list*     acl-ref
      |     +--rw serial-update-method?    enumeration
      |     +--rw any-to-tcp?              boolean {any-to-tcp}?
      |     +--rw journal
      |     |  +--rw maximum-journal-size?   uint64
      |     |  +--rw zone-file-sync-delay?   uint32
      |     |  +--rw from-differences?       boolean {journal-from-differences}?
      |     +--rw query-module* [type name]
      |     |  +--rw type    -> /dns-server/query-module/type
      |     |  +--rw name    -> /dns-server/query-module[type=current()/../type]/name
      |     +--rw dnssig:dnssec-signing!
      |     |  +--rw dnssig:enabled?   boolean
      |     |  +--rw dnssig:policy?    -> /dnss:dns-server/dnssig:sign-policy/name
      |     |  +--rw knot:kasp-db?     string
      |     +--rw knot:semantic-checks?    boolean
      +--rw dnssig:sign-policy* [name]
      |  +--rw dnssig:name                 string
      |  +--rw dnssig:algorithm?           dsalg:dnssec-algorithm
      |  +--rw dnssig:ksk-length?          uint16
      |  +--rw dnssig:zsk-length?          uint16
      |  +--rw dnssig:dnskey-ttl?          dnss:rr-ttl
      |  +--rw dnssig:zsk-lifetime?        lifetime
      |  +--rw dnssig:rrsig-lifetime?      lifetime
      |  +--rw dnssig:rrsig-refresh?       uint32
      |  +--rw dnssig:nsec3?               boolean
      |  +--rw dnssig:soa-min-ttl?         dnss:rr-ttl
      |  +--rw dnssig:zone-max-ttl?        dnss:rr-ttl
      |  +--rw dnssig:propagation-delay?   uint32
      +--rw knot:log* [name]
      |  +--rw knot:name           string
      |  +--rw knot:description?   string
      |  +--rw (target)
      |  |  +--:(stdout)
      |  |  |  +--rw knot:stdout?        empty
      |  |  +--:(stderr)
      |  |  |  +--rw knot:stderr?        empty
      |  |  +--:(syslog)
      |  |  |  +--rw knot:syslog?        empty
      |  |  +--:(file)
      |  |     +--rw knot:file?          dnss:fs-path
      |  +--rw knot:server?        severity
      |  +--rw knot:zone?          severity
      |  +--rw knot:any?           severity
      +--rw knot:control-socket
         +--rw (socket-type)?
         |  +--:(unix)
         |  |  +--rw knot:unix?                  dnss:fs-path
         |  +--:(network)
         |     +--rw knot:ip-address             inet:ip-address
         |     +--rw knot:port?                  inet:port-number
         +--rw knot:access-control-list*   acl-ref
rpcs:
   +---x start-server
   |  +--ro output
   |     +--ro pid    uint32
   +---x stop-server
   +---x restart-server
   |  +--ro output
   |     +--ro pid    uint32
   +---x reload-server
module: dnssec-signing
rpcs:
   +---x generate-key
      +---w input
      |  +---w algorithm             dsalg:dnssec-algorithm
      |  +---w length                uint16
      |  +---w publish?              yang:date-and-time
      |  +---w activate?             yang:date-and-time
      |  +---w retire?               yang:date-and-time
      |  +---w remove?               yang:date-and-time
      |  +---w secure-entry-point?   boolean
      +--ro output
         +--ro key-id     key-id
         +--ro key-tag    uint16
```
