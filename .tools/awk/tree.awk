# This script takes the output of pyang's "tree" plugin, extracts a subtree at `root`
# and prints it down to `depth`. Omitted parts are indicated by "...".
# If `types` is false, the datatype of leafs is not printed.
# The following variables should be passed to the script:
# - `yam`: YANG module containing the subtree to be printed,
# - `root`: path to the root of the subtree, with slash-separated components.  

function node(text) {
    if (lev > maxlev) {
	if (!cont) {
	    print "   ..."
	    cont = 1
	}
    } else {
	cont = 0
	print FS text
    }
}

BEGIN {
    if (!istep) { istep = 3 }
    if (!depth) { depth = 999 }
    if (!types) { types = 0 }
    split(root, pcomp, "/")
    cc = pcomp[1]?1:2
}

/^module:/ { if (mod) { exit }
    if ($2 == yam) {
	mod = 1
	FS = "+"
    }
}

{ if (!mod) { next } } # Module not found yet

/^rpcs:/ || /^notifications:/ { exit } # We don't do rpcs and notifications (yet)

/\+/ { # Any node
    lev = length($1)
    if (lev <= minlev) { exit }
    if (out) {
	if (lev <= maxlev || !cont) {
	    printf("%s", " " substr($1, minlev + 2))
	} else { next }
    }
}

/\+--r[ow]/ { # data node
    split($2, toks, " ")
    if (out) {
	node(types || toks[3] ~ /\[/?$2:toks[1] " " toks[2])
	next
    }
    if (toks[2] == pcomp[cc]) {
	minlev = lev
	if (pcomp[++cc] == "") {
	    out = 1
	    maxlev = minlev + istep * depth
	    print FS $2
	}
    }
}

/\+--:/ { # case
    if (out) {
	node($2)
    }
}
