---
layout: default
title: sc_unset API
---


sc_unset
========


Prototype
---------

```
$node = $node->sc_unset();
```


Parameters
----------

_None_

Return Type
-----------

_undef_


Description
-----------

**sc_unset** removes the node from it's parent and destroys the node.

As the node has been destroyed, the reference to it should no longer
be dereferenced.  To facilitate the setting the reference to `undef`,
the method returns `undef`.


Example
-------

```perl
$space  = &sc_get_space();

$field = $space->sc_add_field(...);

$field = $field->sc_unset();
```

The last statement removes the field from the space and effectively
sets the reference to `undef` so that it can't be used again.
