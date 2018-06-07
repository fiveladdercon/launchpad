---
layout: default
title: sc_set_size API
---


sc_set_size
===========


Prototype
---------

```
$integer = $node->sc_set_size(size)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `size`    | `string` |  M  | The new size of the node.                      |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_size** sets the size for the node and returns `1` if successfull, `0`
otherwise.  The size is not changed if the set fails.

The set can fail if:

- The size specified is not a valid number;
- The new size causes the span of the node to overlap with siblings or extend 
  past the size of the parent region.
- The node is a region and new size causes children to no longer fit within
  the region.


Example
-------

```perl
$space = &sc_get_space();

$region = $space->sc_add_region(-offset => "0W", -size => "2W");
          $space->sc_add_region(-offset => "2W", -size => "2W");

$region->sc_set_size("3W") or &sc_fatal("Can't update size");

$region->sc_set_size("1W") or &sc_fatal("Can't update size");
```

The first set fails because the new span overlaps existing nodes.

The second set succeeds because there is no overlap.
