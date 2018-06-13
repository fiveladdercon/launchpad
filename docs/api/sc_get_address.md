---
layout: default
title: sc_get_address API
---


sc_get_address
==============


Prototype
---------

```
$number = $node->sc_get_address([numformat='%d'])
```


Parameters
----------

| Parameter   | Type     | M/O | Description                                                      |
|:------------|:---------|:---:|:-----------------------------------------------------------------|
| `numformat` | `string` |  O  | The format of the number returned.  Defaults to '%d' if omitted. |

M/O = Mandatory/Optional


Return Type
-----------

`number`


Description
-----------

**sc_get_address** returns the _address_ of the node, which is the offset of
the node relative to the space, not it's parent.

sc_get_address recursively traverses up the chain of parents to the space,
suming the relative offsets along the way.

The address is returned as a [formatted number](sc_number).

Note that if an ancestor has been detached from the space with [sc_detach],
the address will be relative to the detached ancestor, since the ancestor effectively
acts as the space when in the detached state.  See [sc_detach] for details.

Example
-------

```perl
$alpha   = $space->sc_add_region  (-offset => '2B', ...);
$beta    = $alpha->sc_add_region  (-offset => '3B', ...);
$charlie = $beta->sc_add_region   (-offset => '4B', ...);
$delta   = $charlie->sc_add_region(-offset => '5B', ...);

printf "%s\n", $delta->sc_get_address("%B");
```

This will report delta's address as 2B + 3B + 4B + 5B = 14B.

