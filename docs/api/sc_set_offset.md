---
layout: default
title: sc_set_offset API
---


sc_set_offset
=============


Prototype
---------

```
$integer = $node->sc_set_offset(offset)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `offset`  | `number` |  M  | The new offset of the node.                    |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_offset** sets the offset for the node and returns `1` if successful,
`0` otherwise.  The offset is not changed if the set fails.

The set can fail if:

- The offset specified is not a valid number; or
- The new offset causes the span of the node to overlap with siblings or 
  extend past the size of the parent region.


Example
-------

```perl
$space = &sc_get_space();

$region = $space->sc_add_region(-offset => "0W", -size => "2W");
          $space->sc_add_region(-offset => "2W", -size => "2W");

$region->sc_set_offset("1W") or &sc_error("Can't update offset");

$region->sc_set_offset("3W") or &sc_error("Can't update offset");

$region->sc_set_offset("4W") or &sc_error("Can't update offset");
```

The first two sets fail because the new span overlaps the existing
node.

The last set succeeds because there is no overlap.
