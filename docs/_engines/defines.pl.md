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
indirectly accesses the space via a bus **peripheral** (i.e. via access routines).


```c
#include "space.h"  // Declaries a NODE macro per named node.
                    //
int x;              // A variable
                    //
write(NODE,1);      // An access routine writes the node
                    //
x = read(NODE);     // An access routine reads the node
```

This is in constrast to an **on-board driver**, where the processor executing
the code directly accesses the space via bus **transactions**.  The [structs.pl] 
engine is better suited for on-board drivers.


Usage
-----

```
spacecraft ... defines.pl [OUTPUT]
						  [--grid SIZE]
                          [--optimize] 
                          [--verilog] 
                          [--storage-off]
                          [--storage-only]
                          [--structs] 

```

Writes the header to the **OUTPUT** file if defined or **{TYPE}.h** otherwise.

-g, --grid SIZE
  : Specify the **SIZE** of the access grid in bits.  Defaults to 32 if omitted.

-o, --optimize
  : Optimize the output for minimal image size by removing names, default 
    values and range checking from macros.  Storage abstraction macros will 
    return names and values as empty strings and always mark the range as
    valid.

-v, --verilog
  : Output macros in verilog format so that they can be used in simulations.

-off, --storage-off
  : Omit the storage abstraction macros from the header.  These declarations 
    define macros that abstract the underlying storage mechanism of node 
    constants.

-only, --storage-only
  : Omit the node constants from the header.  These declarations map node
    data into an underlying storage mechanism dereferenced by node identifier.

-s, --structs
  : Output the node data as constant structs instead of parameter lists.  The
    result is possibly a more intuitive macro definition at the cost of code
    size.  It also demonstrates that the underlying storage structure is 
    irrelevant to functional code, including access routines.


Node Constants
--------------

Every named node requires three pieces of information in order to access the 
node from software:

  * The **size** of the node,
  * The **address** of the node, and
  * The size of the access **grid**.

The **address** and **size** are part of the node definition, while the size
of the **grid** is a function of the access system, or bus implementation.

To access a node, **size** bits are accessed from the **address** **grid** bits 
at a time.  Depending how the **size** and **address** aligns with the access
**grid**, sibling nodes may be accessed and/or one or more than access may be 
required.

The [defines.pl] engine encodes this information into a **constant** for each 
node by associating the identifier with the access data as a macro:

For example, the following definition:

```
10hW  2B  BEEFh  EXAMPLE  RW;
```

results in the following macro:

```c
#define EXAMPLE        ...node address, size & grid data...
```

Now every time EXAMPLE is referenced in code, it is replaced with the associated
constant.  So by constructing access routines that accept the encoded access data:

```c
void write( ...node data... , int wval );
int  read ( ...node data... );
```

those routines can be invoked using only the **constants**:

```c
write(EXAMPLE, 25);
rval = read(EXAMPLE);
```

As all of the access information for the node is hidden away behind the macro 
identifier, the resulting functional code is quite readable.  The other nice 
feature about using macros is that there is compile time checking, which means 
that identifier typos (or changes) are caught at compile time, not run time, 
which is typically far easier to debug.


Storage Abstraction Macros
--------------------------

As most code only references node constants by identifier, the underlying data
structure is irrelevant, and only the access routines need understand the data
structure.

To address this, the [defines.pl] engine outputs a number of **storage 
abstraction macros** to abstract the underlying data structure from the access 
routines as well. (The structs format is an alternative data structure that 
demonstrates this abstraction).

To define access routines, the **nodes** macro is used to declare the inputs to
the access routine:

```c
void write ( nodes, int write_value );
int  read  ( nodes );
```

The **nodes** macro defines a **node** variable and it's type.

To retrieve data from the **node** inside the access routine, the [defines.pl] 
engine outputs a number of retrieval macros:

```c
grid_of(node)    : returns the access **grid** size, in bits.
size_of(node)    : returns the **size** of the node, in bits.
address_of(node) : returns the bit **address** of least significant bit of the node.
name_of(node)    : returns the **name** of the node as a string, unless optimized.
value_of(node)   : returns the default **value** of the node as a string, unless optimized.
```

Which means that compiling and executing the following:

```c
void debug (nodes) {
	printf ("grid  = %d\n", grid_of(node)   );
	printf ("size  = %d\n", size_of(node)   );
	printf ("addr  = %d\n", address_of(node));
	printf ("name  = %s\n", name_of(node)   );
	printf ("value = %s\n", value_of(node)  );
}

int main () {
	debug(EXAMPLE);
}
```

results in the output:

```
grid  = 32
size  = 16
addr  = 512
name  = EXAMPLE
value = BEEFh
```

Though the storage macros are intended for use inside an access routine,
they work with with node constants as well:

```
printf ("grid  = %d\n", grid_of(EXAMPLE)   );
printf ("size  = %d\n", size_of(EXAMPLE)   );
printf ("addr  = %d\n", address_of(EXAMPLE));
printf ("name  = %s\n", name_of(EXAMPLE)   );
printf ("value = %s\n", value_of(EXAMPLE)  );
```

also results in the output:

```
grid  = 32
size  = 16
addr  = 0
name  = EXAMPLE
value = BEEFh
```


Optimization
------------

While developing both the access routines and the functional routines, it is
quite often beneficial to understand which nodes are being accessed by printing
out the access.

To this end, the [defines.pl] engine adds the **name** as a string to the node
constant that can be retrieved with the **name_of** storage abstraction macro.  
While this is beneficial in development, **name** strings inflate the code image.  
If the **name** strings are not used in production code, they can be eliminated 
from the constants with the **--optimize** switch.

Similarly the [defines.pl] engine adds the default **value** as a string to the
node constant, as it is useful to validate the reset state of nodes.  The 
**value** is retrieved with the **value_of** storage macro and is also removed 
by the **--optimize** switch.

Note that the **name_of** and **value_of** macros are not removed when optimized, 
so as to leave the calling code unaffected, but instead only return empty strings 
since the underlying string data is not present.

Lastly, the **value** is stored as a string to support large values; that is
values that are larger than the capacity of numbers on the host machine, which
is beyond the scope of this interface.


Dimensions
----------

Dimensions reduce redundancy in node definition but come at the cost of 
complexity in the node constants.  Consider the definition:

```
10hW  2B  BEEFh  ARRAY_[x:2]_[y:1:2]  RW;
```

This is a represents a 2x2x2 byte array.  We could unroll the array and
implement four macros:

```c
#define ARRAY_0_1   ...
#define ARRAY_0_2   ...
#define ARRAY_1_1   ...
#define ARRAY_1_2   ...
```

But doing so means we can no longer use variables to index the array:

```c
for(x=0;x<=1;x++)
  for(y=1;y<=2;y++)
    access(ARRAY_x_y);  // Compile error: ARRAY_x_y is not defined
```

To address this, the [defines.pl] engine adds dimension parameters to macro 
definitions:

```c
#define ARRAY_x_y(x,y)   ...
```

Which means that now you _can_ use variables:

```c
for(x=0;x<=1;x++)
  for(y=1;y<=2;y++)
    access(ARRAY_x_y(x,y));
```

The down side is that this introduces a leak in the compile time checking:

```c
access(ARRAY_x_y(0,0));  // Compiles fine, but y = 0 is out of range!
```

To compensate, the [defines.pl] engine provides an **is_valid** storage
macro that returns truthy if all array indices are within range:

```
is_valid(ARRAY_x_y(0,0))  // returns falsy because y = 0 is out of range.
is_valid(ARRAY_x_y(0,1))  // returns truthy
is_valid(ARRAY_x_y(0,2))  // returns truthy
is_valid(ARRAY_x_y(1,1))  // returns truthy
is_valid(ARRAY_x_y(1,2))  // returns truthy
```

However because the indices can be variables (by design), **is_valid** is 
unfortunately only a run-time check, which means it must be added to the
access routines:

```c
void write(nodes, int wval) {
	if (!is_valid(node))
	   printf("Houston, we have a problem with %s.\n",name_of(node));
}
```

Notwithstanding this overhead, a run time error message pointing to the problem 
is considerably better than combing through code looking for an out-of-range 
index in code that otherwise looks fine.  You've been warned.

Now of course, since the access routines are called with both dimensioned
and non-dimensioned nodes, the **is_valid** macro also returns truthy for
non-dimensioned nodes.

Furthermore, validity checking is only revelant durring development, and thus 
optimized out with the --optimize switch but forcing **is_valid** to always
return truthy.


Example
-------

Output a header file for designers to use in non-UVM simulations:

```
$ spacecraft -R soc.rf defines.pl -v
```
