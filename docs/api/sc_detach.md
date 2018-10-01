---
layout: default
title: sc_detach API
---


sc_detach
=========


Prototype
---------

```
$node->sc_detach()
```


Parameters
----------

_None_

Return Type
-----------

_None_


Description
-----------

**sc_detach** removes the node from the parent and temporarily makes it the 
space for it's descendents.  

The intent is to allow large spaces to be presented as a logical assembly 
of sub spaces.

While a node is in the detached state, the [sc_get_address]
and [sc_get_identifier] methods relate descendents back
to the detached node rather than the space.

A detached node is intended to be reattached at a later time with [sc_reattach].  
If the node is to be permanently removed,
[sc_unset] should be used instead.

Detaching a node already in the detached state has no effect.

To test if the node is is detached state use the [sc_is_space] test,
since it will return true when in the detached state.

[sc_get_address]:    sc_get_address
[sc_get_identifier]: sc_get_identifier
[sc_reattach]:       sc_reattach
[sc_is_space]:       sc_is_space

Example
-------

```perl
$alpha   = $space->sc_add_region  (-offset => '2B', -glob => 'A_*', ...);
$beta    = $alpha->sc_add_region  (-offset => '3B', -glob => 'B_*', ...);
$charlie = $beta->sc_add_region   (-offset => '4B', -glob => 'C_*', ...);
$delta   = $charlie->sc_add_region(-offset => '5B', -name => 'D'  , ...);

printf "%3s : %s\n", $delta->sc_get_address("%B"), $charlie->sc_get_identifier();

$beta->sc_detach();

printf "%3s : %s\n", $delta->sc_get_address("%B"), $charlie->sc_get_identifier();

$beta->sc_reattach();

printf "%3s : %s\n", $delta->sc_get_address("%B"), $charlie->sc_get_identifier();
```

This will output:

```
14B : A_B_C_D
9B  : C_D
14B : A_B_C_D
```

Note that the offset of beta, `3B`, does not affect the address of it's 
descendents while it is in the detached state; this is because beta, while 
detached, has no parent, and thus nothing to "offset" against.  It is only 
when beta has a parent that the offset makes sense.

Similarly the glob of beta, `B_*`, only affects decendents when they are
_imported into beta's parent_, which isn't there while in the detached state;
that is beta has nothing to "import" into when it has no parent.
