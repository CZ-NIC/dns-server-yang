DNS-SERVER-YANG
==============

Generic [YANG](https://tools.ietf.org/html/draft-ietf-netmod-rfc6020bis-05)
data model for a DNS server. 

Run _make_ to get the YANG modules in the normal compact format.

Other `Makefile` targets need [pyang](https://github.com/mbj4668/pyang)
to be installed.

The `validate` target requires
[Jing](http://www.thaiopensource.com/relaxng/jing.html) to be
installed. Alternatively, _xmllint_ can be used instead, if the `-j`
flag is removed from the `validate` action.

Here is the tree of what has been implemented so far:

```
module: dns-server
   +--rw dns-server
      +--rw access-control-list* [name]
      |  +--rw name                 string
      |  +--rw access-list-entry* [name]
      |     +--rw name      string
      |     +--rw prefix    inet:ip-prefix
      |     +--rw port?     inet:port-number {acl-entry-port}?
      |     +--rw key?      key-ref {acl-entry-key}?
      +--rw key* [name]
         +--rw name         string
         +--rw algorithm?   identityref
         +--rw secret?      binary
```
