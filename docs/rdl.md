---
layout: default
title: Register Definition Language
permalink: /rdl/
---

[RDM]:        ../rdm          "Resident Data Model"
[Engine API]:  ../api
[region]:     ../rdm#regions
[regions]:    ../rdm#regions
[field]:      ../rdm#fields
[fields]:     ../rdm#fields
[dimension]:  ../rdm#dimensions
[dimensions]: ../rdm#dimensions
[property]:   ../rdm#properties
[properties]: ../rdm#properties



Rocket Fuel RDL
===============

The .rf file format is used to persist the [RDM][].  Each file maps a [region][] of the [RDM][].



Numbers
-------

Hexadecimal numbers are suffixed with the **h** character<sup>a</sup>: 

<center>1465 = 5b9<b>h</b> = 5B9<b>h</b></center>

The **offsets** and **sizes** of [fields][] and [regions][] are defined in terms of bits.  Since it 
is not always convenient to think in bits, the Rocket Fuel format has a pseudo fixed-point notation 
for specifying bits in terms of bytes, halfwords, words, doublewords, kilobytes or megabytes. 

##### FIGURE 1: Fixed point numbering

In the fixed-point notation a **scale** is appended to the number to denote the location of the 
decimal point.  Following the scale is an optional **decimal point** followed by the **fractional 
bits** that are in added to the scaled number.  The fractional bits are always specified in 
decimal format regardless of the integer format.

| Scale  | Integer Shift  | Integer Units | Fractions Allowed? |
|:------:|:--------------:|:--------------|:------------------:|
| **b**  | N\<\<0         | bits          | N                  |
| **B**  | N\<\<3         | bytes         | Y                  |
| **H**  | N\<\<4         | halfwords     | Y                  |
| **W**  | N\<\<5         | words         | Y                  |
| **D**  | N\<\<6         | doublewords   | Y                  |
| **KB** | N\<\<13        | kilobytes     | N                  |
| **MB** | N\<\<23        | megabytes     | N                  |

The number scheme is _pseudo_ fixed-point because there is no limit on the size of the fractional 
part (where permitted).  This is because the fraction is added to the scaled (shifted) number, 
not ORed with it.  Thus it is quite possible – though quite unusual – to specify a fractional part 
that is larger than the scaled part: 

<center>2B.25 = 2*8 + 25 = 31</center>


- - -

(a) The **h** suffix was chosen instead of the more common 0x prefix for hexadecimal notation because of the 
need to distinguish between the number and the **b** and **B** scales in the fixed point numbering scheme.
For example does 0xBB mean 187 bits or 13 Bytes? Whereas it is clear that BhB means 13 Bytes while BBh means 
187 bits. Take care with the case of the **h** suffix as well since 3h is different than 3H – with the former 
being 3 bits or 3 and the later being 3 halfwords or 48.



Fields
------

```
4B.2   3b   5   THREE_BIT_FIELD   RW       ;
|      |    |   |                 └─────── type
|      |    |   └───────────────────────── name
|      |    └───────────────────────────── value
|      └────────────────────────────────── size
└───────────────────────────────────────── offset
```

A [field][] declaration is an ordered, whitespace separated 5-tupple specifying 5 mandatory 
data members **offset**, **size**, **value**, **name**, and **type**, followed by a semicolon 
(**`;`**). The sixth mandatory data member, the **parent**, refers to the [region][] in which 
this [field][] is declared.

A **description** can be added to the [field][] by enclosing the description text between 3-dash
delimiters (**`---`**) _before_ the 5-tupple:

```
---
This is the description of the following THREE_BIT_FIELD
---
4B.2   3b   5   THREE_BIT_FIELD   RW       ;
```


Properties
----------

[Properties][] can be added to a [field][] or [region][] by inserting **options** before 
the semicolon.  An **option** is the [property][] key prefixed with a dash (**-**) followed by 
either a number or string value or nothing.  An option with no value implicitly defines a number 
[property][] with a value of 1, signally option presence.

```
---
This is the description of the following THREE_BIT_FIELD
---
4B.2   3b   5   THREE_BIT_FIELD   RW   -example  -sample "A"     ;
                                       |         └────────────── string property:
                                       |                         key   = "sample"
                                       |                         value = "A"
                                       └──────────────────────── number property:
                                                                 key   = "example"
                                                                 value = 1 (implicitly)
```

The [RDM][] has no inherent interpretation of [properties][] as they are simply annotated on 
the [field][] for retreival with the [Engine API][].  This means that the options can be 
whatever you need them to be for your specific *engines*.

Since a particular [property][] is generally targeted to a particular **engine**, the [property][] 
**key** should include the **engine** name as a prefix: 

```
---
This is the description of the following THREE_BIT_FIELD
---
4B.2   3b   5   THREE_BIT_FIELD   RW  -verilog:import -html:hook 1    ;
                                       |               └───────────── target the html engine
                                       |                              key   = "verilog:import"
                                       |                              value = 1
                                       └───────────────────────────── target the verilog engine
                                                                      key   = "html:hook"
                                                                      value = 1 (implicitly)

```

Note that this property naming convention is not enforced; it is only suggested to (i)
make it clear which engine requires what property and (ii) avoid naming collisions between
engines.


Syntax
======

Numbers have the following syntax: 

```
number := [0-9]+b?                  # decimal bits
number := [0-9]+B[.[0-9]+]?         # decimal bytes
number := [0-9]+H[.[0-9]+]?         # decimal halfwords
number := [0-9]+W[.[0-9]+]?         # decimal words
number := [0-9]+KB                  # decimal kilobytes
number := [0-9]+MB                  # decimal megabytes
 
number := [0-9a-fA-F]+hb?           # hexadecimal bits
number := [0-9a-fA-F]+hB[.[0-9]+]?  # hexadecimal bytes
number := [0-9a-fA-F]+hH[.[0-9]+]?  # hexadecimal halfwords
number := [0-9a-fA-F]+hW[.[0-9]+]?  # hexadecimal words
number := [0-9a-fA-F]+hKB           # hexadecimal kilobytes
number := [0-9a-fA-F]+hMB           # hexadecimal megabytes
```

[Fields][] have the following syntax:

```
field := [--- description ---]? offset size value name type [-key [value]?]* ;
```