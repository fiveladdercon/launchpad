---
layout: default
title: sc_set_dimension_size API
---


sc_set_dimension_size
=====================


Prototype
---------

```
$integer = $node->sc_set_dimension_size(dimension[,size])
```


Parameters
----------

| Parameter   | Type      | M/O | Description                                    |
|:------------|:----------|:---:|:-----------------------------------------------|
| `dimension` | `integer` |  M  | The index of the dimension to set.             |
| `size`      | `number`  |  O  | The new size of the dimension.                 |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_dimension_size** sets the size for the specified dimension returning
`1` on success, or `0` otherwise.  The dimension size is not changed if the
set fails.

Omitting the size value will cause the dimension to snap to the span of the
next dimension or the size of the node.

The set can fail if:

- the node does not have dimensions or the dimension specified; or
- the size specified is not a valid number;
- the size specified does not contain the span of the next dimension or the
  size of the node; or
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

$field = $region->sc_add_field(-name => "FIELD_[x:1:8]", -size => '7b', ...);

$field->sc_set_dimension_size(1,'6b') or &sc_error("Can't resize the dimension");

$field->sc_set_dimension_to(1,'1B') or &sc_error("Can't resize the dimension");
```

The first set fails because the dimension size is smaller than the field size
and hence does not contain the field.

The second set succeeds and resizes the dimension to 8b, making each copy align
to a byte boundary.
