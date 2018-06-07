---
layout: default
title: sc_set_name API
---


sc_set_name
===========


Prototype
---------

```
$integer = $node->sc_set_name(name)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `name`    | `string` |  M  | The new name for the field.                    |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_name** sets the name for the node and returns `1` if successfull, `0`
otherwise.  The name is not changed if the set fails.

Note that the name of a field is mandatory and specifies it's dimensions, 
whereas the name of a region is optional and only needs to _follow_ the 
dimensions specified with the glob.

Hence the name affects the span of a field but not a region.

If the node is a field, the set can fail if:

- the name is undef or "";
- the name, if dimensioned, does not have valid dimensions; or
- the name, if dimensioned, changes the span of the field so that it overlaps
  with siblings or extends past the size of the parent.

If the node is a region, the set can fail if:

- the name, if the region is dimensioned, does not contain the correct number
  of dimension placeholders.


Example
-------

```perl
$space = &sc_get_space();

$region = $space->sc_add_region(-offset => 0, -size => '2W', -glob => '*_[x:2]');
$field  = $region->sc_add_field(-offset => 0, -size => '1W', -name => 'F', ...);

$field->sc_set_name('F_[i:3]') or &sc_error("Can't update field name");

$field->sc_set_name('F_[i:2]') or &sc_error("Can't update field name");

$region->sc_set_name('R') or &sc_error("Can't update region name");

$region->sc_set_name('R_%') or &sc_error("Can't update region name");
```

The first field set fails because it is being updated to a dimensioned 
node and the total span is 3W, which does not fit within the 2W region.  

The second field set succeeds because the total span is 2W, which fits.

The first region set fails because the region is dimensioned and the
name, when present, must have the correct number of dimension slots.

The second region set succeeds because it has the correct number of
dimension slots.
