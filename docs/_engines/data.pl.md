---
title: data.pl
permalink: /engines/data/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


data.pl
=======

The **[data.pl]** engine outputs the complete model data in a tree format 
allowing for a detailed inspection of model construction.


Usage
-----

```
spacecraft ... data.pl [OUTPUT]
                       [-offset FORMAT] 
                       [-size FORMAT] 
```

Output is sent to the **OUTPUT** file if specified or **STDOUT** otherwise.

-offset FORMAT
  : Report offsets & addresses with the spacecraft bit **FORMAT** provided.
    Defaults to `%hb (%U)` when not specified.

-size FORMAT
  : Report sizes & spans with the spacecraft bit **FORMAT** provided.
    Defaults to `%hb (%U)` when not specified.


Example
-------

Debug a space fueled from the command line:

```
$ spacecraft dma.rf data.pl
```

The above results in the following output (clipped):

```
├─ REGION
│    identifier  : MODE
│    address     : 0hb (0B)
│    span        : 20hb (4B)
│    offset      : 0hb (0B)
│    size        : 20hb (4B)
│    glob        : *
│    name        : MODE
│    type        : 
│    description : The mode register sets the parameters for the transfer.
│    properties  : 
│    filename    : dma.rf
│    lineno      : 4
│    children    : ┐
│                : ├─ FIELD
│                : │    identifier  : WIDTH
│                : │    address     : 0hb (0B)
│                : │    span        : 2hb (0B.2)
│                : │    offset      : 0hb (0B)
│                : │    size        : 2hb (0B.2)
│                : │    value       : 0b
│                : │    name        : WIDTH
│                : │    type        : RW
│                : │    description : Transfer width. ...
│                : │    properties  : 
│                : │    filename    : dma.rf
│                : │    lineno      : 14
...
```
