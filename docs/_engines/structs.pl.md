---
title: structs.pl
permalink: /engines/structs/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}
[defines.pl]: /engines/defines/


structs.pl
==========

[structs.pl] outputs the model as a hierarchy of structs in a header file 
suitable for including in *on-board* driver code (i.e. the processor executing 
the code accesses the space with bus cycles).

```c
#include "space.h"  // Defines structs that can be directly dereferenced
                    //
SPACE *space;       // The top level struct declared in the header
                    //
int x;              // A variable
                    //
space = 0x80000;    // Where the struct resides in the processor memory map,
                    // if the space is not the entire map.
                    //
*space.field = 1;   // A reference assignment writes the field
                    //
x = *space.field;   // A dereference reads the field
```

This is in constrast to *off-board* driver code, which must use a bus peripheral
(i.e. SPI, ICC, MDIO, etc) to indirectly access the space.  The [defines.pl] 
engine is better suited for off-board drivers.


Usage
-----

```
spacecraft ... structs.pl [OUTPUT]
```

Writes the header to the OUTPUT file if defined or _space type_.h otherwise.


Example
-------

Output a header file for use in an on-board driver:

```
$ spacecraft -R soc.rf structs.pl
```
