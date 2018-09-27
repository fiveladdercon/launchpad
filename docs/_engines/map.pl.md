---
title: map.pl
permalink: /engines/map/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


map.pl
======

[map.pl] outputs *named* fields and regions in the space in a simple
line based format suitable for diffing and quickly inspecting the input.


Usage
-----

```
$ spacecraft ... map.pl [OUTPUT]
                        [-address FORMAT] 
                        [-size FORMAT]
                        [-f|-r] 
```

Output is sent to STDOUT unless an OUTPUT file is specified.

-address FORMAT
  : Report addresses with the number FORMAT provided.
    Defaults to `%hW` when not specified.

-size FORMAT
  : Report sizes with the number FORMAT provided.
    Defaults to `%hb` when not specified.

-f 
  : map only fields.

-r 
  : map only fields.


Example
-------

Recursively parse a rocketfuel file and summarize the address map:

```
$ spacecraft -R soc.rf map.pl 
```
