DNS-server-YANG
==============

[YANG](https://tools.ietf.org/html/draft-ietf-netmod-rfc6020bis-05)
data model for an authoritative DNS server. The model tries to be
general where possible but the main focus in on
[Knot DNS](https://www.knot-dns.cz) configuration.

[Current data tree](https://gitlab.labs.nic.cz/labs/dns-server-yang/raw/master/model.tree)

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

