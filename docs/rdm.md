---
layout: default
title: Resident Data Model
permalink: /rdm/
---

[Engine API]: /api/
[Dimensions]: #dimensions
[Properties]: #properties


Spacecraft Resident Data Model (RDM)
====================================

If you're going to use spacecraft to work with your hardware address map, then you need to know how 
it's represented in memory.

Bit Spaces
----------

Generally register tools map byte, halfword and/or word spaces.  Doing so mixes the _functional 
intent_ of the mapping with the _access mechanism_.  Spacecraft, conversly, maps **bit spaces**. 
In a **bit space** every bit is numbered, beginning with zero on the right and increasing 
to the left<sup>a</sup>:

##### FIGURE 1: An infinite bit space #####

Normalizing to bit spaces means that you can do away with the "fractional" representation that 
inevitably arises in the other spaces.  For example<sup>b</sup>: 

> 313b = 39B.1 = 19H.9 = 9W.25 

##### FIGURE 2: Bit space normalization #####

Note that all four representations refer to the same bit, so that the representations are 
equivalent; that is the location of the bit _does not depend on it's representation_.
Also note however, that all other spaces require three quantities to uniquely locate a bit: the 
integer portion, the fractional portion and the units of measurement.  With a bit space, only one 
number is needed and the units are always bits.

- - - 

(a) Bit 0, the least significant bit, is shown on the right to align with the natural language
    convention that the most significant digit is read first and hence on the left, while the least
    significant digit is read last and hence are on the right.  This ensures that octal and 
    hexademical notations, which also follow this ordering convention, map directly into the bit 
    space without any mental gymnastics.

(b) The notation used in this example is described in [Spacecraft Numbering](/rdl/#numbering).



Fields
------

A **field** is a data structure that maps a **value** to a contiguous set of bits.

A field has a **parent**, which is a reference to the region into which the field is mapped.

A field has an **offset** into the region of its parent so that the field can be located and a 
**size** to indicate how much of the region is occupied.  The offset is in units of bits and 
specifies the least significant (rightmost) bit of the field relative to the start of the 
parent's space.  The **size** of the field is the number of contiguous bits that make up the 
field. 

##### FIGURE 3: Field size & offset #####

A field has a **value**, which specifies the initial default value of the bits. 

A field has a **name** so that people can associate the function of the field with a memorable 
identifier.

A field has a **type** which specifies a general class of functionality (i.e. configuration or 
status). 

A field has an optional **description** of the specific function of the bits.

A field may optionally have one or more **dimensions** to compactly represent repeated adjacent 
copies of the field.  See [Dimensions][] below for details. 

A field has an optional list of user defined **properties**.  See [Properties][] below for details.

A field also has a **filename** and **lineno**, which locate the source of the field declaration in 
the file system (if applicable).

| Member                   | M/O | Type       | Description                                                                          |
|:-------------------------|:---:|:-----------|:-------------------------------------------------------------------------------------|
| **parent**               | M   | region*    | A pointer to the region object into which the field is mapped.                       |
| **offset**               | M   | integer    | The offset in bits of the least significant bit of the field.                        |
| **size**                 | M   | integer    | The number of contiguous bits that make up the field.                                |
| **value**                | M   | integer    | The initial default value of the bits.                                               |
| **name**                 | M   | string     | The name of the field.                                                               |
| **type**<sup>a<sup>      | M   | string     | The type of the field, which specifies the general functionality of the field.       |
| **description**          | O   | string     | A description of the specific functionality associated with the field.               |
| **dimensions**           | O   | dimension* | An array of [dimensions][].                                                          | 
| **properties**           | O   | property*  | A list of user defined [properties][].                                               |
| **filename**<sup>b</sup> | O   | string     | The name of the file the field was declared in (if applicable).                      |
| **lineno**<sup>b</sup>   | O   | integer    | The line number in the file the field was declared in (if applicable).               |                         

M/O = Mandatory/Optional

(a) Though the field type is a mandatory data member, spacecraft has absolutely no type awareness.  
    Type information is generally required for most, if not all, engines however, which is why it is
    mandatory.  The lack of type awareness in spacecraft is actually quite powerful, as it opens the
    door for completely custom field types.

(b) If the field is read from a file the filename and lineno data members will be available.  If the 
    field is inserted with the [Engine API][], filename and lineno data members will be available if 
    they were provided (typically using the  `__FILE__` & `__LINE__` tokens).  Filename and lineno 
    data members are read-only. 



Regions
-------

A **region** is a data structure that maps **children** into a contiguous set of bits. 

##### FIGURE 4: A region #####

A **child** is either a field: 

##### FIGURE 5: A region with one mapped field ##### 

Or another smaller, finite region: 
 
##### FIGURE 6: A region with one mapped region ##### 

Because a region can contain other regions, they add hierarchy to the bit space mapping.  From 
the perspective of the parent region in Figure 6, the child region _occupies_ or _reserves_ a 
contiguous set of bits in its bit space.  From this perspective, a region is very much like a field.
From the perspective of the child region in Figure 6, however, the child region _provides_ a 
smaller bit space into which more children can be mapped. The bit space provided is finite and 
is equivalent to the size of the space occupied in the parent.

Because a child can either be a field or a region, fields and regions are collectively called mapped 
**items**. 

##### FIGURE 7: A child region with mapped fields #####

##### FIGURE 8: A hierarchy of regions & fields #####

There are a couple of things to note about the children of a region.  The first is that they are 
entirely contained within the space of the parent – a child cannot extend past the finite end of the 
parent region.  The implication here is that all items mapped into the region are no bigger than the
**size** of the region. The second is that children are adjacent, not necessarily contiguous, and 
never overlap. 

A **region** has zero or more children. 

A region has a **parent**, which is a reference to the region into which this region is mapped.

A region has an **offset** into the space of its parent so that the region can be located and a 
**size** to indicate how much of the bit space is occupied.  The **offset** is in units of bits and 
specifies the least significant (rightmost) bit of the region relative to the start of the 
parent's space.  The **size** of the region is the number of contiguous bits that make up the 
region. 

##### FIGURE 9: Region size & offset #####

A region has a **glob**, which is a rule that specifies how the names of children are altered (if at
all) when they are imported into the region.

A region has an optional **name**.  If a region does not have a name then it is an **anonymous
region**.

A region has an optional **type** so that it can be mapped as a child multiple times with different 
names and different offsets.  If a region does not have a type then it is an **untyped region**.

A region has an optional **description** of the specific nature of the region.

A region may optionally have one or more **dimensions** to compactly represent repeated adjacent 
copies of the region.  See [Dimensions][] below for details. 

A region has an optional list of user defined **properties**.  See [Properties][] below for details.

A region also has a **filename** and **lineno**, which locate the source of the region declaration 
in the file system (if applicable).

| Member                   | M/O           | Type              | Description                                                                                   |
|:-------------------------|:-------------:|:------------------|:----------------------------------------------------------------------------------------------|
| **parent**               | M<sup>a</sup> | region*           |  A pointer to the region into which this region is mapped.                                    |
| **offset**               | M             | integer           | The offset in bits of the least significant bit of the region.                                | 
| **size**                 | M             | integer           | The number of bits that make up the region.                                                   |
| **glob**                 | M<sup>b</sup> | string            | Specifies the rule for altering the names of children when they are imported into the region. |
| **name**                 | O             | string            | The name of the region.  If the name is omitted, the region is an _anonymous region_.         | 
| **type**                 | O             | string            | The type of the region.  If the type is omitted, the region is an _untyped region_.           |
| **children**             | O             | item*<sup>c</sup> | A list of fields or regions that are mapped into this region.  The list can be empty.         |
| **description**          | O             | string            | A description of the functionality associated with the region.                                |
| **dimensions**           | O             | dimension*        | An array of [dimensions][].                                                                   |
| **properties**           | O             | property*         | An optional list of user defined [properties][].                                              |
| **filename**<sup>d</sup> | O             | string            | The name of the file the region was declared in (if applicable).                              |
| **lineno**<sup>d</sup>   | O             | integer           | The line number in the file the region was declared in (if applicable).                       |

M/O = Mandatory/Optional 

a) The one and only root space is the only region that does not have a parent.

b) The **glob** is mandatory and must contain an asterisk character (*) to represent a how the 
   names of children are prefixed and suffixed when they are imported into the space.  The 
   prefix is the string before the asterisk while the suffix is the string after it, either or both
   of which may be absent.  If the glob consists of only the asterisk character then the names 
   of children are unaltered when they are imported.

c) Because a child can either be a field or a region, fields and regions are collectively called 
   items.

b) If the region is read from a file the filename and lineno data members will be available.  If 
   the region is inserted with the [Engine API][], filename and lineno data members will be 
   available if they were provided (typically using the  `__FILE__` & `__LINE__` tokens).  Filename 
   and lineno data members are read-only. 



### Addresses, Identifiers and the Root Space ###

Because of the hierarchical nature of regions, there must be a region at the top of the tree. 
This region is special because it is an anonymous region with no **parent** or **offset** and 
infinite **size**. It is the final bit space into which all fields are mapped, either directly or 
through the hierarchy of regions.  This top-most region is called the **root space**, and it should
be apparent that there is one and only one root space.

Ultimately all items relate back to the root space, as this is the point of mapping them.

The **address** of an item is its offset relative to the root space, not its parent.  The address 
of a mapped item is constructed by summing its offset with the offsets of each intervening region:
 
##### FIGURE 10: Address construction ##### 

The **identifier** of an item is its name when imported into the root space.  The identifier of a 
mapped item is constructed by prefixing and suffixing its name with the globs of each intervening
region:

##### FIGURE 11: Identifier construction #####



### Logical Representation vs Physical Implementation ###

As all fields ultimately map into the root space, the root space is a **logical representation** 
of the **physical implementation**.  

The first thing to realize is that **the logical representation is independent of the physical 
implementation**.  It makes no difference to the logical representation if a field is directly 
mapped into the root space or if it is 10 regions down the hierarchy: it makes no difference 
if the field is in RAM or registers, hand coded or generated, in-house or third-party, 
on clock domain X instead of Y, accessed 8, 16, 32 or 64 bits at a time, designed by U instead of 
V, or any other reason why a region is used isolate a portion of the root space.

The second thing to realize is that **the logical representation needs to be designed**.  
A completely flattened root space is one logical representation, while complete awareness of 
the physical implemenation is another.  The former fails to leverage hardware reuse, while the
latter exposes all the dirty laundry of the physical implementation.  In truth, the best logical 
representation lies somewhere between these two extremes, where certain key regions in the physical
implementation need to be highlighted in the logical representation, while other regions need to be 
hidden.



### Abstraction Levels ###

| Level      | Concerns                                 | Producers & Consumers                         |
|:-----------|:-----------------------------------------|:----------------------------------------------|
| functional | unique identification, logical structure | system architects & software, customers       |
| access     | data width & ordering, channel           | lab validation, verification, driver software |
| signal     | bus standard, clock domains              | designers                                     |



Dimensions
----------

Dimensions are a compact way of representing **adjacent repeated copies** of a mapped item.

##### FIGURE 12: A dimensioned field #####

The copies of the mapped item are numbered sequentially and range from **from** to **to**.
The original mapped item is always numbered **from**.

If **from** < **to**, copy numbering sequentially increases as copy offset increases:

##### FIGURE 13: Sequentially increasing numbering #####

If **from** > **to**, copy numbering sequentially decreases as copy offset increases: 

##### FIGURE 14: Sequentially decreasing numbering #####

A dimension has a **label** that is used to represent an arbitrary, unspecified or variable copy. 

A dimension has a **size** that specifies the number of contiguous bits that a copy occupies.  The 
dimension size is distinct from the item size to allow for different packing schemes.

Consider the case of a repeated 7 bit field.  Without a distinct dimension size the copies would 
rotate through byte alignment:

##### FIGURE 15: Misaligned copy packing #####

With a dimension size of 8, however, the repeated 7 bit field can be packed with byte alignment: 

##### FIGURE 16: Aligned copy packing #####

The dimension size must be greater than or equal to the item size and "snaps" to the item size if 
it is unspecified. 

The **count** of a dimension is the total number of copies and is equal to | **from** – **to** | + 1. 

The **span** of a dimension is the total space consumed by all copies and is equivalent to **count**
* **size**. 

##### FIGURE 17: Dimension span #####

A mapped item can have one or more dimensions.  The first dimension is the innermost.  The 
second dimension is the next innermost and snaps to span of the first dimension if a size is 
unspecified. Similarly, subsequent higher dimensions snap to the span of the next lower dimension
when size is unspecified so that tightly packed nested copies can be easily constructed: 

##### FIGURE 18: A multi-dimensional field #####

Note that the span of a dimensioned item, not its size, must be considered when mapping the 
offset of the next item.

A mapped item with zero dimensions is **dimensionless**.

| Member     | M/O           | Type    | Description                                                                     |
|:-----------|:-------------:|:--------|:--------------------------------------------------------------------------------|
| **label**  | M             | string  | A name for the set of indices.                                                  |
| **from**   | M             | integer | The index of the first copy.                                                    |
| **to**     | M             | integer | The index of the last copy.                                                     |
| **size**   | M<sup>a</sup> | integer | The number of bits occupied by a single copy.                                   |
| **count**  | M<sup>b</sup> | integer | The number of copies; equivalent to \|**from**-**to**\|+1.                      |
| **span**   | M<sup>b</sup> | integer | The number of bits occupied by all copies, equivalent to **size** * **count**.  |

M/O = Mandatory/Optional 

a) The size of a dimension is mandatory but will snap to the size of the next lower dimension or 
   the item size when no lower dimension if no size is specified. 

b) The count and span are computed data members and not stored so as to keep them consistent with 
   the from, to and size data members. 

Dimensions for an item, if present, are stored in a zero indexed array where dimension 0 is the 
innermost and dimension N the outermost.


###  Rolled vs Unrolled Representation ###

In a **rolled** representation, there is only a single instance of the mapped item and dimension 
information for that item is stored as an array of dimension stuctures.

##### FIGURE 19: Rolled representation #####

In an **unrolled** representation, adjacent copies have been elaborated and exist as distinct 
instances _as if they had been declared that way_.  All copies, including the original, are 
dimensionless.

##### FIGURE 20: Unrolled representation #####

Note that in either representation, the same number of bits have been consumed in the parent 
region. 



Properties
==========

Every field or region may have a set of optional user defined **properties**.  Properties are 
key/value pairs where the **key** is a string and the **value** is either a string or a number.

Properties are intended for altering the behavior of a specific engine for the given field or region.
Spacecraft has no awareness of what a given property may do; it simply annotates the item with 
the property for retrieval through the [Engine API][].

Since properties are generally targetted to a particular engine, it is recommended that the key
contain the name of the engine.

| Member    | M/O | Type              |  Description                                                                                            |
|:----------|:---:|:------------------|:--------------------------------------------------------------------------------------------------------|
| **key**   | M   | string            | Identifies the property.                                                                                |
| **value** | M   | string \| integer | Stores arbitrary data relevant to the property if more than simple existence/non-existence is required. |

M/O = Mandatory/Optional 

