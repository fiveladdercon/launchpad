---
layout: default
title: sc_set_dimension_label API
---


sc_set_dimension_label
======================


Prototype
---------

```
$integer = $node->sc_set_dimension_label(dimension,label)
```


Parameters
----------

| Parameter   | Type      | M/O | Description                                    |
|:------------|:----------|:---:|:-----------------------------------------------|
| `dimension` | `integer` |  M  | The index of the dimension to set.             |
| `label`     | `string`  |  M  | The new label of the dimension.                |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_dimension_label** sets the label for the specified dimension returning
`1` on success, or `0` otherwise.  The dimension label is not changed if the
set fails.

The set can fail if:

- the node does not have dimensions or the dimension specified; or
- the label is "" or undef.

Note that dimensions are numbered from 1 to N, left to right in the 
field name or region glob.

To change multiple dimension details at once, set the field name with 
[sc_set_name]() or set the region glob with [sc_set_glob]().


Example
-------

```perl
$space = &sc_get_space();

$field = $space->sc_add_field(-name => "FIELD_[x:1:8]", ...);

$field->sc_set_dimension_label(0,'y') or &sc_error("Can't relabel the dimension");

$field->sc_set_dimension_label(1,'y') or &sc_error("Can't relabel the dimension");
```

The first set fails because the dimension is out of range.

The second set succeeds and relabels the dimension to 'y'.
