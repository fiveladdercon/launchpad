---
title: defines.pl
permalink: /engines/defines/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}
[structs.pl]: /engines/structs/

defines.pl
==========

[defines.pl] outputs the model as a flat set of defines in a header file suitable 
for including in an **off-board driver**, where the processor executing the code 
indirectly accesses the space via a bus peripheral.


```c
#include "space.h"  // Declaries a FIELD macro per field.
                    //
int x;              // A variable
                    //
write(#FIELD,1);    // A function writes the field
                    //
x = read(#FIELD);   // A function reads the field
```

This is in constrast to an **on-board driver**, where the processor executing
the code directly accesses the space via bus transactions.  The [structs.pl] 
engine is better suited for on-board drivers.


Usage
-----

```
spacecraft ... defines.pl [-verilog] [OUTPUT]
```

Writes the header to the **OUTPUT** file if defined or **{TYPE}.h** otherwise.

-v, -verilog
  : Output verilog defines instead of C defines so that they can be used in
    simulations.


Example
-------

Output a header file for designers to use in non-UVM simulations:

```
$ spacecraft -R soc.rf defines.pl -v
```
