---
title: filter.pl
permalink: /engines/filter/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


filter.pl
===========

[filter.pl] trims properties or nodes from the model, which is useful for
tailoring the model for customer use.


Usage
-----

```
spacecraft ... filter.pl 
    [-property PATTERN] 
    [-filter PATTERN] 
```

The [filter.pl] engine does not output the model; it only removes selected parts
of it.  The final output format


-property PATTERN
  : Remove properties from nodes that match the given PATTERN.  
    More than one `-property` switch can be used to specify multiple PATTERNs,
    and a PATTERN can be a regular expression or a simple string.

-filter PATTERN
  : Remove nodes with filter properties that match the given PATTERN.
    More than one `-filter` switch can be used to specify multiple PATTERNs,
    and a PATTERN can be a regular expression or a simple string.


Example
-------

Remove verilog properties from the model before shipping the map to customers
in a flattened rocket fuel file.

```
$ spacecraft soc.rf filter.pl -property verilog pack.pl rf.pl
```


