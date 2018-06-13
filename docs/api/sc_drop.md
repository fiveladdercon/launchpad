---
layout: default
title: sc_drop API
---


sc_drop
=======


Prototype
---------

```
$node->sc_drop()
```


Parameters
----------

_None_

Return Type
-----------

_None_


Description
-----------

**sc_drop** removes the node from it's parent and destroys the node.

As the node has been destroyed, the reference to it should no longer
be dereferenced.


Example
-------

```perl
$space  = &sc_get_space();

$field = $space->sc_add_field(...);

$field = $field->sc_drop();
```

The last statement removes the field from the space and effectively
sets the reference to `undef` so that it can't be used again.
