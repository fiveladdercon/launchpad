---
layout: default
title: sc_set_value API
---


sc_set_value
============


Prototype
---------

```
$integer = $field->sc_set_value(value)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `value`   | `number` |  M  | The new value for the field.                   |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_value** sets the value for the field and returns `1` on success, `0`
otherwise.  The value is not change if the set fails.

Note that only fields have values.

The set can fail if:

- the value is undef or "".


Example
-------

```perl
$space = &sc_get_space();

$field = $space->sc_add_field(-offset => 0, -size => 32, -value => "FFFFFFFFh", ...);

$field->sc_set_value() or &sc_error("Can't set value");

$field->sc_set_value(0) or &sc_error("Can't set value");
```

The first set fails because the required value is missing.

The second set succeeds.
