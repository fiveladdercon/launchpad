---
layout: default
title: sc_get_space API
---


sc_get_space
============


Prototype
---------

```
$space = &sc_get_space()
```


Parameters
----------

_None_

Return Type
-----------

`SC_SPACE`


Description
-----------

**sc_get_space** returns a reference to the root space that is shared between
engines.

Generally every engine will start with a called to &sc_get_space().

If a space definition was provided as fuel on the command line, then 
&sc_get_space() will return the definition.  This is the pattern for
an output engine.

If a space definition was not provided as fuel on the command line, then
&sc_get_space() will return a reference to an anonymous, untyped, childless
region.  This is the pattern for an input engine.


Example
-------

```perl
sub identified () {
	my $region = shift;
	if ($region->sc_is_named()) {
       printf "%s\n", $region->sc_get_name();
    }
    while (my $child = $region->sc_get_next_child()) {
       if ($child->sc_is_field()) {
         printf "%s\n", $child->sc_get_name();
       } else {
         identified($child);
       }
    }
}

&identified(&sc_get_space());
```

This is the typical output engine pattern: a function is
defined that iterates through the children and is recursively
called on regions and the recursion is started with the
space.

This engine simply lists all identifiers in the space.