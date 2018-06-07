---
layout: default
title: sc_set_glob API
---


sc_set_glob
===========


Prototype
---------

```
$integer = $region->sc_set_glob(glob)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `glob`    | `string` |  M  | The new glob for the region                    |

M/O = Mandatory/Optional


Return Type
-----------

`integer`


Description
-----------

**sc_set_glob** sets the glob for the region and returns `1` on success, `0`
otherwise.  The glob is not changed if the set fails.

Note that only regions have globs.

The set can fail if:

- the glob does not contain a single `*` character;
- the glob, if dimensioned, does not have valid dimensions; or
- the glob, if dimensioned, changes the span of the region so that it overlaps
  with siblings or extends pas the size of the parent.

Calling sc_set_glob with `undef` or `""` will set the glob to `*` and issue
a warning.

Also note that if a named region is redimensioned by updating the glob, then
the name needs to be updated with the new dimension slot as well.


Example
-------

```perl
$space = &sc_get_space();

$region = $space->sc_add_region(-offset => 0,  -size => 32, -name => "R");
          $space->sc_add_field (-offset => 64, -size => 32, ...);


$region->sc_set_glob("*_[x:3]") or &sc_error("Can't set glob");

$region->sc_set_glob("*_[x:2]") or &sc_error("Can't set glob");

# Don't forget to change the name too...
$region->sc_set_name("R_%") or &sc_error("Can't set name");
```

The first set fails because the region gets dimensioned and the new 
span overlaps an existing sibling.

The second set succeeds because the span fits.  Since the region is
now dimensioned, the name needs to be updated as well.
