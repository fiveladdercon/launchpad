---
layout: default
title: sc_get_next_dimension API
---


sc_get_next_dimension
=====================


Prototype
---------

```
$integer = $node->sc_get_next_dimension()
```


Parameters
----------

_None_

Return Type
-----------

`integer`


Description
-----------

**sc_get_next_dimension** iterates through the list of dimensions of a node,
returning the dimension index if there is another dimension or `0` when all
dimensions have been listed.


Example
-------

```perl
$space = &sc_get_space();

$field = $space->sc_add_field(-name => "Field_[x:8]_[y:4]_[z:2]", ...);

while ($i = $field->sc_get_next_dimension()) {
	print $field->sc_get_dimension($i,"%l : %f..%t\n");
}
```

This prints out the dimension information of the field in a custom format.
