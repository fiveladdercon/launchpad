---
layout: default
title: sc_get_next_property API
---


sc_get_next_property
====================


Prototype
---------

```
$string = $node->sc_get_next_property()
```


Parameters
----------

_None_

Return Type
-----------

`string` | `undef`


Description
-----------

**sc_get_next_property** iterates through the list of properties of a node,
returning the property key if there is another property or `undef` when all
properties have been listed.


Example
-------

```perl
$space = &sc_get_space();

$field = $space->sc_add_field(...);

$field->sc_add_property("key1","value1");
$field->sc_add_property("key2","value2");
$field->sc_add_property("key3","value3");

while ($key = $field->sc_get_next_property()) {
	printf "%-10s %s\n", $key, $field->sc_get_property($key);
}
```

This prints out the properties of the field.
