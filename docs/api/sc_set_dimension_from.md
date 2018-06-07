---
layout: default
title: sc_set_dimension_from API
---


sc_set_dimension_from
=====================


Prototype
---------

```
$integer = $node->sc_set_dimension_from(dimension,from)
```


Parameters
----------

| Parameter   | Type      | M/O | Description                                    |
|:------------|:----------|:---:|:-----------------------------------------------|
| `dimension` | `integer` |  M  | The index of the dimension to set.             |
| `from`      | `integer` |  M  | The new from index of the dimension.           |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_dimension_from** sets the from index for the specified dimension returning
`1` on success, or `0` otherwise.  The dimension from index is not changed if the
set fails.

The set can fail if:

- the node does not have dimensions or the dimension specified; or
- the resulting change in span causes the node to overlap with siblings or 
  extend past the size of the parent.

Note that dimensions are numbered from 1 to N, left to right in the 
field name or region glob.

To change multiple dimension details at once, set the field name with 
[sc_set_name]() or set the region glob with [sc_set_glob]().


Example
-------

```perl
$space = &sc_get_space();

$region = $space->sc_add_region(-offset => 0, -size => '8B')

$field = $region->sc_add_field(-name => "FIELD_[x:1:8]", -size => '1B', ...);

$field->sc_set_dimension_from(1,0) or &sc_error("Can't reindex the dimension");

$field->sc_set_dimension_from(1,2) or &sc_error("Can't reindex the dimension");
```

The first set fails because the dimension the field span increases to 9B and
won't fit in the region.

The second set succeeds and reindexes the dimension to range from 2 to 8.
