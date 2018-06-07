---
layout: default
title: sc_set_description API
---


sc_set_description
==================


Prototype
---------

```
$integer = $node->sc_set_description(description)
```


Parameters
----------

| Parameter     | Type     | M/O | Description                                    |
|:--------------|:---------|:---:|:-----------------------------------------------|
| `description` | `string` |  M  | The new description for the node.              |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_description** sets the description for the node and returns `1` on
success, `0` otherwise.

The set always succeeds, though setting a description to undef will
revert it to "" and issue a warning.


Example
-------

```perl
$space = &sc_get_space();

$field = $space->sc_add_field(-offset => 0, -size =>32, ...);

$field->sc_set_description("A very complicated function!");
```
