---
title: cstruct.pl
permalink: /engines/cstruct/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}
[define.pl]: /engines/define/


cstruct.pl
===========

[cstruct.pl] outputs the model as a hierarchy of C structs in a header file 
suitable for including in *on-board* driver code (i.e. the processor executing 
the code accesses the space with bus cycles).

```c
#include "space.h"  // Defines structs that can be directly dereferenced

SPACE *space;       // The structure defined in the header

int x;              // A variable

space = 0x80000;    // Where the structure resides in the processor memory map,
                    // if the space is not the entire map.

*space.field = 1;   // The processor directly writes the field 

x = *space.field;   // The processor directly reads the field
```

This is in constrast to *off-board* driver code, which must use a bus peripheral
(i.e. SPI, ICC, MDIO, etc) to indirectly access the space.  The [define.pl] 
engine is better suited for off-board drivers.


Usage
-----

```
spacecraft ... cstruct.pl [OUTPUT]
```

Writes the header to the OUTPUT if defined, or _type_.h otherwise.


Example
-------

Output a header file for use in an on-board driver:

```
$ spacecraft -R soc.rf cstruct.pl
```
