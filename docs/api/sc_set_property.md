---
layout: default
title: sc_set_property API
---


sc_set_property
===============


Prototype
---------

```
$integer = $node->sc_set_property(key[,value])
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `key`     | `string` |  M  | The name of the property.                      |
| `value`   | `string` |  O  | The value of the property.                     |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_property** sets properties of the node and returns `1` on success, `0`
otherwise.  The set always succeeds.

If the property with the specified key already exists the value is updated,
otherwise a new property is added.

If the value is omitted, the key is set or updated to undef, which effectively
makes the property a boolean that is tested with the [sc_has_property](sc_has_property) 
API instead of the [sc_get_property](sc_get_property), since the later
returns `undef` when both the property does not exist or when the property was
set without a value.


Example
-------

```perl
$space = &sc_get_space();

$field = $space->sc_add_field(-offset => 0, -size => 32, ...);

$field->sc_set_property("attribute","volatile");

$field->sc_set_property("important");

$field->sc_set_property("attribute","static");
```

This adds two properties to the field and updates one since the property
already exists.
