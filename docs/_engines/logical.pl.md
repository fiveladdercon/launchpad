---
title: logical.pl
permalink: /engines/logical/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


logical.pl
==========

[logical.pl] restructures the model into a logical subset of the implementation.

All fields are imported into the top level space, removing any region hierarchy.

If a region in the hierarchy has a **logical property** then the region is 
imported into the top level space, and it's local subspace is logically 
restructured following the same importing rules.

The net effect is to remove all region hierarchy except those regions with the 
**-logical** property.

The intent is to present a hierarchical representation of space that removes 
irrelevent physical implementation details for downstream consumers.


Usage
-----

```
spacecraft ... logical.pl
```

Restructures the physical implementation into a logical representation for
downstream consumers.


Properties
----------

logical
  : Marks the region as a logical node, which means it is retained as
    a hierarchical structure.  The property will be consumed by the
	engine and has no effect if applied to a field.


Example
-------

Restructure a physical hierarchy into a logical hierarchy before generating
and documenting structs for software:

```
$ spacecraft soc.rf logical.pl struct.pl html.pl
```
