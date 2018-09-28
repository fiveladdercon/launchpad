---
title: structs.pl
permalink: /engines/structs/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}
[defines.pl]: /engines/defines/


structs.pl
==========

[structs.pl] outputs the model as a hierarchy of structs in a header file 
suitable for including in an **on-board driver**, where the processor executing 
the code directly accesses the space with bus transactions.

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

This is in constrast to an **off-board driver**, where the processor executing
the code indirectly accesses the space via a bus peripheral.  The [defines.pl] 
engine is better suited for off-board drivers.


Usage
-----

```
spacecraft ... structs.pl [OUTPUT]
```

Writes the header to the **OUTPUT** file if defined or **{TYPE}.h** otherwise.


Example
-------

Output a header file for use in an on-board driver:

```
$ spacecraft -R soc.rf structs.pl
```
