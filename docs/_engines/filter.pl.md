---
title: filter.pl
permalink: /engines/filter/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


filter.pl
=========

[filter.pl] removes selected nodes or node properties from the model.

This is intended for tailoring the model for customer use by removing proprietary 
information.

Note that the engine does not output the model; it only removes selected parts 
of it.


Usage
-----

```
spacecraft ... filter.pl PATTERN [PATTERN]
    [-property PATTERN] 
```

Removes nodes that have a `filter` property that matches at least one of the 
supplied PATTERNs.

-property PATTERN
  : Remove properties from nodes that match the given PATTERN.  
    More than one `-property` switch can be used to specify multiple PATTERNs.

PATTERNs can be strings or regular expressions.


Properties
----------

-filter PATTERN
  : If a node's filter property PATTERN matches any PATTERN supplied on the 
    command line, the node is removed from the model.  If a node's filter 
    property PATTERN does not match ANY PATTERNs supplied on the command line,
    the filter property is removed.  Note that this implies that filter 
    properties are consumed by the filter engine so that all filtering based
    on the property must occur in a single pass of the engine.


Example
-------

Remove verilog properties from the model before shipping the map to a customer
in a packed rocket fuel file.

```
$ spacecraft soc.rf filter.pl -property verilog pack.pl rf.pl customers.rf
```

Suppose a rocket fuel file contains the following definitions:

```
0W  1W  0h  STANDARD  RW;

1W  1W  0h  SPECIAL   RW  -filter customer_X;

2W  1W  0h  DEBUG     RW  -filter private;
```

To remove all engineering fields and customer specific fields from general 
customer documentation:

```
$ spacecraft ... filter.pl private customer_X ...
```

Here only the `STANDARD` field would be documented.


To remove the engineering fields for a specific customer:

```
$ spacecraft ... filter.pl private ...
```

Here both the `STANDARD` & `SPECIAL` fields would be documented, and only the
`DEBUG` field removed.
