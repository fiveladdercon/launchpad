---
layout: default
title: sc_drop_property API
---


sc_drop_property
================


Prototype
---------

```
$node->sc_drop_property(key)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `key`     | `string` |  M  | The property to remove.                        |

M/O = Mandatory/Optional


Return Type
-----------

_None_


Description
-----------

**sc_drop_property** deletes the `key` property of the node, if it exists.

Note that a property can exist with a value of `undef`, which effectively
makes the property an existance boolean that is tested with 
[sc_has_property](sc_has_property).

This means you can't remove a property by setting it's value to `undef`,
which means you need another way to remove the property.  This API
does just that.


Example
-------

```perl
$field->sc_set_property('example');

printf "example? %s", $field->sc_has_property('example') ? 'Yes' : 'No';
	
$field->sc_drop_property('example');

printf "example? %s", $field->sc_has_property('example') ? 'Yes' : 'No';
```

This would output:

```
example? Yes
example? No
```
