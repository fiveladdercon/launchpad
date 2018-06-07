---
layout: default
title: sc_set_type API
---


sc_set_type
===========


Prototype
---------

```
$integer = $node->sc_set_type(type)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `type`    | `string` |  M  | The new type for the node.                     |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_type** sets the type for the node and returns `1` if successfull, `0`
otherwise.  The type is not changed if the set fails.

A field must have a type, but a region may be typeless.

If the node is a field, the set can fail if:

- the type is undef or ""

Recall that field type has no meaning to spacecraft; it's meaning is
determined by the hardware engine used.

Also not that specifying a region type does not load the definitions of 
that type from a file; it simply sets the value.


Example
-------

```perl
$space = &sc_get_space();

$field = $space->sc_add_field(-offset => 0, -size => 32, -type => 'RW', ...);

$field->sc_set_type() or &sc_error("Can\'t set type");

$field->sc_set_type('RO') or &sc_error("Can\'t set type");
```

The first set fails because a field requires a type.

The second set succeeds.

