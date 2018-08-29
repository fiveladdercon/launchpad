---
layout: default
title: Rocket Fuel
permalink: /fuel/
---

[model]:      ../model
[EngineAPI]:  ../api
[space]:      ../model/#spaces
[field]:      ../model/#fields
[fields]:     ../model/#fields
[region]:     ../model/#regions
[regions]:    ../model/#regions
[property]:   ../model/#properties
[properties]: ../model/#properties
[dimension]:  ../model/#dimensions
[dimensions]: ../model/#dimensions


Rocket Fuel
===========

**Rocket Fuel** is the native spacecraft file format used to declare a hierarchy 
of [fields][] and [regions][] that define a [space][].



Bits
----

The **offsets** and **sizes** of [fields][] and [regions][] are defined in terms
of bits. Since it is not always convenient to think in bits, the spacecraft has
a fixed-point notation for specifying bits in terms of bytes, halfwords, words, 
doublewords, kilobytes, megabytes, gigabytes or terabytes.

##### FIGURE 1: Fixed point numbering

In the fixed-point notation a **scale** is appended to a decimal or hexidecimal
**integer part** to denote the location of the decimal point.  Following the 
scale is an optional **decimal point** followed by the **fractional bits** that 
are added to the scaled number.  The fractional bits are always specified in 
decimal format regardless of the format of the integer part.

| Scale  | Integer Shift  | Integer Units | Fractions Allowed? |
|:------:|:--------------:|:--------------|:------------------:|
| **b**  | N\<\<0         | bits          | N                  |
| **B**  | N\<\<3         | bytes         | Y                  |
| **H**  | N\<\<4         | halfwords     | Y                  |
| **W**  | N\<\<5         | words         | Y                  |
| **D**  | N\<\<6         | doublewords   | Y                  |
| **KB** | N\<\<13        | kilobytes     | N                  |
| **MB** | N\<\<23        | megabytes     | N                  |
| **GB** | N\<\<33        | gigabytes     | N                  |
| **TB** | N\<\<43        | terabytes     | N                  |

Hexadecimal numbers are suffixed with the **h** character<sup>a</sup>: 

<center>1465 = 5b9<b>h</b> = 5B9<b>h</b></center>

<hr class="sc_footnote">
<small>
(a) The **h** suffix was chosen instead of the more common 0x prefix for hexadecimal 
notation because of the need to distinguish between the number and the **b** and 
**B** scales in the fixed point numbering scheme. For example does 0xBB mean 187 
bits or 13 Bytes? Whereas it is clear that BhB means 13 Bytes while BBh means 187 
bits. Take care with the case of the **h** suffix as well since 3h is different 
than 3H – with the former being 3 bits or 3 and the later being 3 halfwords or 
48.
</small>



Spaces
------

A **[space][]** is defined in a **file** that declares the [fields][] and 
[regions][] mapped in to it.

The name of the file defines the **type** of space declared within it:

```
 module.rf
┌──────────────────────────────────────────────────────────┐
│ /*                                                       │ 
│  * This file contains field and region definitions for   │ 
│  * the "module" type space.                              │ 
│  */                                                      │ 
│  ...                                                     │ 
└──────────────────────────────────────────────────────────┘

```



Fields
------

```
4B.2   3b   5   THREE_BIT_FIELD   RW       ;  /*
│      │    │   │                 └─────── field type
│      │    │   └───────────────────────── field name
│      │    └───────────────────────────── field value
│      └────────────────────────────────── field size (in bits)
└───────────────────────────────────────── field offset (in bits)
*/
```

A **[field][]** declaration is an ordered, whitespace separated 5-tupple 
specifying the 5 mandatory data members **offset**, **size**, **value**, 
**name**, and **type**, followed by a semicolon (**`;`**). The sixth mandatory 
data member, the **parent**, simply refers to the [region][] in which the 
[field][] is declared, which may be the [space][].

A **description** can be added to the [field][] by enclosing the description 
text between 3-dash delimiters (**`---`**) _before_ the 5-tupple:

```
---
This is the description of the following THREE_BIT_FIELD
---
4B.2   3b   5   THREE_BIT_FIELD   RW       ;
```



Regions
-------

A **[region][]** is declared very much like a [field][]:

```
---
This is a 2KB child region.
---
8KB   2KB   CH_*   CHILD   child   ; /*
│     │     │      │       └────── region type
│     │     │      └────────────── region name
│     │     └───────────────────── region glob
│     └─────────────────────────── region size (in bits)
└───────────────────────────────── region offset (in bits)
*/
```

The first notable difference is that where a [field][] specifies a **value**, a 
[region][] instead specifies a **glob**.

The **glob** specifies the rule for importing names and must contain an asterisk
(**`*`**) character.  Text before the asterisk (if any) forms the prefix to 
imported names, while text after the asterisk (if any) forms the suffix to 
imported names.  A glob of `*` is perfectly legal and simply specifies that 
names are to be imported unaltered; it is also the default if no glob is 
specified, which is also legal.

The second notable difference is that while the [field][] type has no meaning to 
spacecraft, the [region][] **type** specifies that there is (possibly) a further 
mapping of [fields][] and [regions][] declarded in the file of the given type:

```

 parent.rf
┌─────────────────────────────────────┐
│                                     │
│ ---                                 │
│ This is a typed child region        │
│ ---                                 │
│ 8KB   2KB   CH_*   CHILD   child;   │
│                            │        │
└────────────────────────────┼────────┘
                             │
                             └───┤child.rf
                                 ┌───────────────────────────────┐
                                 │                               │
                                 │ ---                           │
                                 │ This is a field               │
                                 │ ---                           │
                                 │ 4B.2   3b   5   FIELD   RW;   │
                                 │                               │
                                 └───────────────────────────────┘

```

See the [Command Line Interface](/basics/cli/) for details on the procedure 
spacecraft uses to find a file from it's type.

An **untyped** [region][] may be declared by nesting child declarations within 
curly braces (**`{}`**):

```
 parent.rf
┌───────────────────────────────────┐
│                                   │
│ ---                               │
│ This is an untyped child region   │
│ ---                               │
│ 8KB   2KB   CH_*   CHILD   {      │
│                                   │
│    ---                            │
│    This is a field                │
│    ---                            │
│    4B.2   3b   5   FIELD   RW;    │
│                                   │
│ };                                │
└───────────────────────────────────┘
```

Note that untyped [regions][] may also contain untyped [regions][], so that 
[regions][] can be nested as deep as required within a single file.

An anonymous [region][] is one declared without a **name**:

```
---
This is an anonymous child region that imports names without alteration.
---
8KB   2KB   *   child   ; /*
│     │     │   └────── region type
│     │     └────────── region glob
│     └──────────────── region size (in bits)
└────────────────────── region offset (in bits)
*/
```

Lastly, a [region][] need not have children.  A childless [region][] results 
when the type file can not be found or when the [region][] is specified with 
an empty inline declaration:

```
---
This is a childless child region
---
0   1MB   RESERVED   {}   ;
```

The difference between an empty inline specification and an unfound type file 
is _intent_.  Childless, untyped [regions][] are intentional and do not cause 
a warning.  A childless [region][] as a result of an unfound file is assumed
to be unintentional and will cause a warning.



### Modeling Registers with Regions ###

A **register** is a multi-bit [region][] that is accessed as an indivisible unit; 
that is, a register is an **atomic access region** that is an artifact of the 
**field access system**.

Register size is independent of [field][] size, which results in _super-atomic 
fields_ that are larger than registers and _sub-atomic fields_ that are packed 
together within a single register.

[Fields][] are like the borders of countries on a map, while registers are the 
grid lines.

Because [field][] size is independent of register size, spacecraft does not 
explictly impose a register model:

```
3W.0  1b  0  FIFO_OVERFLOW   RO;
3W.1  1b  0  FIFO_UNDERFLOW  RO;
4W.0  4W  0  FIFO_CONTENT    RO;
```

Because the `FIFO_OVERFLOW` and `FIFO_UNDERFLOW` [fields][] are specified with 
offsets in the same word, `3W.x`, they will implicitly be accessed together --
atomically -- in a word-access (or byte-access or halfword-access or 
doubleword-access) system.  They are sub-atomic [fields][] bound to the same 
access, simply because they share the same word aligned offset.

On the otherhand the `FIFO_CONTENT` [field][] is 4 words in size and will never 
be accessed in one shot, but rather a burst of several accesses.

[Regions][] may be used to make registers more explicit:

```
---
This is a named 32-bit atomic region, otherwise known as a register.  
Note that field names are not altered because of the implicit * glob.
---
3W  32b  FIFO_STATUS  {
    0  1b  0  FIFO_OVERFLOW   RO;
    1  1b  0  FIFO_UNDERFLOW  RO;
};
```

Note that the separation of **name** from **glob** allows for the definition of 
register names that are _distinct_ from field names.  Thus, for example, the 
`FIFO_STATUS` register can be read to get the status of both the `FIFO_OVERFLOW` 
and `FIFO_UNDERFLOW` fields in a single access.

Also note that the name of a [region][] and hence a register is optional.  Often 
fields have nothing in common other than they share a register, in which case 
the register is hard to name and no name may be a better option than a 
meaningless name.  The same is true when a register has only one field.



### Modeling RAMs and ROMs with Regions ###

RAMs and ROMs are bulk memory and are easily modelled as named, intentionally 
childless [regions][]:

```
---
Boot ROM
---
0  64KB   BOOTROM   {}   ;

---
Instruction RAM
---
64KB  64KB   IRAM   {}   ;
```


### Top-down Design with Regions ###

Because unfound files result in childless [regions][], it is possible to design 
top-down by regioning a large space into smaller spaces:

```
chip.rf
┌──────────────────────────────────────────┐
│                                          │
│   0KB  64KB  MACRO_*_1  MACRO_1  macro;  │
│  64KB  64KB  MACRO_*_2  MACRO_2  macro;  │
│ 128KB  64KB  CORE_*     CORE     core;   │
│                                          │
└──────────────────────────────────────────┘
```

Here `chip.rf` can be created before `macro.rf` and `core.rf`, which effectively 
reserves both the name & address space for these subcomponents.



### Hiding Implementation Details with Regions ###

There are many reasons why an address map may get partitioned for implemenation:

* generated vs hand-coded vs RAM based fields
* third-pary vs in-house fields
* clock domain X instead of Y
* access system S instead of T
* designed by U instead of V   

Many of these implementation details are irrelevant to the functionality of the 
address map and exposing them can clutter the logical representation.

An anonymous [region][] with a glob of ``*`` effectively makes the [region][] 
invisible to the logical representation.



Properties
----------

[Properties][] can be added to a [field][] or [region][] by inserting **options** 
before the semicolon.  An **option** is the [property][] key prefixed with a dash 
(**`-`**) followed by either a string value, or nothing.  An option with no value 
implicitly defines a [property][] without a value, signaling option presence.

```
---
This is the description of the following THREE_BIT_FIELD
---
4B.2   3b   5   THREE_BIT_FIELD   RW   -example  -sample "A"     ;
//                                     │         └────────────── string property:
//                                     │                         key   = "sample"
//                                     │                         value = "A"
//                                     └──────────────────────── boolean property:
//                                                               key   = "example"
```

The [model][] has no inherent interpretation of [properties][] as they are simply 
annotated on the [field][] or [region][] for retreival with the [EngineAPI][].
This means that the options can be whatever you need them to be for your specific 
*engines*.

Since a particular [property][] is generally targeted to a particular **engine**, 
the [property][] **key** should include the **engine** name as a prefix: 

```
---
This is the description of the following THREE_BIT_FIELD
---
4B.2   3b   5   THREE_BIT_FIELD   RW  -verilog:import -html:hook 1    ;
//                                    │               └───────────── target the html engine
//                                    │                              key   = "html:hook"
//                                    │                              value = "1"
//                                    └───────────────────────────── target the verilog engine
//                                                                   key   = "verilog:import"
```

Note that this property naming convention is not enforced; it is only suggested 
to (i) make it clear which engine requires which property and (ii) avoid naming 
collisions between engines.



Dimensions
----------

Both [fields][] and [regions][] can have [dimensions][].  Adding [dimensions][] 
affects not only addresses, but identifiers too, so **dimension vectors** are 
declared in the **names** of [fields][] and in the **globs** of [regions][]:

```
// Four copies of a 32-bit "register"
0W  1W  *_[x:1:4:1W] {
  0  1b  1  LOS  RO;    // LOS_x, x = 1..4
  1  1b  1  LOC  RO;    // LOC_x, x = 1..4
};


// 32 copies of a field
4W  1b  0  UP_[y:0:31:1b];  // UP_y, y = 0..31
``` 

Each [dimension][] declares the 4-tupple of mandatory members: **label**, **from**, 
**to**, and **size**, in a **dimension vector**, which is a colon (**`:`**) 
separated list of values enclosed in square brackets (**`[]`**).

In most cases the [dimension][] size is the same as the [field][] or [region][] 
size, in which case the [dimension][] size may be omitted, making the 
[dimension][] snap.

If zero based, increasing indexing is used for the [dimension][], the **from** 
and **to** values may be replaced with the **count** value.

With these short cuts, the following defintions are equivalent:

```
0B  1B  FFh  ARRAY_[x:0:7:1B]  RW;  // label:from:to:size declared
0B  1B  FFh  ARRAY_[x:0:7]     RW;  // label:from:to declared, size snaps
0B  1B  FFh  ARRAY_[x:8]       RW;  // label:count declared, from = 0, to = count-1, size snaps
```

When multiple [dimensions][] are declared, they are ordered with the innermost, 
lowested indexed [dimension][] being _rightmost_ in the [field][] **name** or 
[region][] **glob**:

```
0B  1B  00h  ARRAY_[u:2]_[v:3]_[w:4];
//                  │     │     └───── Dimension 1 : 4x 1B
//                  │     └─────────── Dimension 2 : 3x (4x 1B)
//                  └───────────────── Dimension 3 : 2x (3x (4x 1B))
```

Note that the **size** declared is the size of a single [field][] or [region][], 
but that the **span** of all [dimensions][] must be considered when mapping the 
next node:

```
0B  1B  00h  ARRAY_[u:2]_[v:3]_[w:4];

//  The next available offest is 2x3x4x 1B = 24B, anything less overlaps ARRAY_u_v_w.
```

Lastly, if a [region][] has [dimensions][] _and_ a **name**, the **name** must 
be declared with hash characters (**`#`**) that specify the location of the 
corresponding [dimension][] so as to uniquely identify each copy:

```
0B  1B  *_[x:8]_[y:4]  LIST_#_#  list ;
//                          │ └────── Dimension 1 : y = 0..3
//                          └──────── Dimension 2 : x = 0..7
```



Syntax
======

The following is a summary of the Rocket Fuel syntax:

```
space       := (node)*

node        := (field | region) ';'

field       := description? offset size fvalue fname type options*

region      := description? offset size glob? rname? type options*
            |  description? offset size glob? rname? '{' space '}' options*

description := '---' string '---'

offset      := bits

size        := bits

fvalue      := bits

fname       := (identifier (dimension)?)+

glob        := (identifer (dimension)?)* '*' (identifer (dimension)?)*

rname       := identifier ('#' identifier)+  // One '#' per glob dimension

type        := identifier

options     := ('-' key value)

key         := identifier (':' identifer)?

value       := bits | identifier | '"' string '"'

dimension   :=  '[' label ':' from ':' to ':' size ']'
            |   '[' label ':' from ':' to          ']'
            |   '[' label ':' count                ']'

label       := identifier

from        := integer

to          := integer

size        := bits

count       := integer

bits        := [0-9]+b?                  // decimal bits
            |  [0-9]+B[.[0-9]+]?         // decimal bytes
            |  [0-9]+H[.[0-9]+]?         // decimal halfwords
            |  [0-9]+W[.[0-9]+]?         // decimal words
            |  [0-9]+KB                  // decimal kilobytes
            |  [0-9]+MB                  // decimal megabytes
            |  [0-9]+GB                  // decimal gigabytes
            |  [0-9]+TB                  // decimal terabytes
            |  [0-9a-fA-F]+hb?           // hexadecimal bits
            |  [0-9a-fA-F]+hB[.[0-9]+]?  // hexadecimal bytes
            |  [0-9a-fA-F]+hH[.[0-9]+]?  // hexadecimal halfwords
            |  [0-9a-fA-F]+hW[.[0-9]+]?  // hexadecimal words
            |  [0-9a-fA-F]+hKB           // hexadecimal kilobytes
            |  [0-9a-fA-F]+hMB           // hexadecimal megabytes
            |  [0-9a-fA-F]+hGB           // hexadecimal gigabytes
            |  [0-9a-fA-F]+hTB           // hexadecimal terabytes

identifier  := [a-zA-Z0-9][a-zA-Z0-9_]*
```

