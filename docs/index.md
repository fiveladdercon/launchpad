---
layout: default
---

Spacecraft
==========

**Spacecraft** is an address mapping tool for hardware designers.

It is built on the premise that hardware address maps are vital to so many 
audiences that they are never quite in the right format for everyone. So rather 
than dictate input and output formats, Spacecraft instead constructs a light 
weight, flexible and _fast_ memory resident model of the hardware address map 
and provides an extensive and powerful API that puts *you* in control of
the input and output.

Regions can be named or anonymous, allowing for the construction of a logical
representation of the address space that is a designed subset of the physical 
implementation.

spacecraft is a tool that hosts the model and *delegates model manipulation*, 
including model output, to engines

### Abstraction Levels ###

| Level      | Concerns                                 | Producers & Consumers                         |
|:-----------|:-----------------------------------------|:----------------------------------------------|
| functional | unique identification, logical structure | system architects & software, customers       |
| access     | data width & ordering, channel           | lab validation, verification, driver software |
| signal     | bus standard, clock domains              | designers                                     |


### Logical Representation vs Physical Implementation ###

As all fields ultimately map into the space, the space is a **logical 
representation** of the **physical implementation**.  

The first thing to realize is that **the logical representation is independent 
of the physical implementation**.  It makes no difference to the logical 
representation if a field is directly mapped into the space or if it is 10 
regions down the hierarchy: it makes no difference if the field is in RAM or 
registers, hand coded or generated, in-house or third-party, on clock domain X 
instead of Y, accessed 8, 16, 32 or 64 bits at a time, designed by U instead of 
V, or any other reason why a region is used carve out a portion of the space.

The second thing to realize is that **the logical representation needs to be 
designed**.  A completely flat space is one logical representation, while 
complete awareness of the physical implemenation is another.  The former fails 
to leverage hardware reuse, while the latter exposes all the dirty laundry of 
the physical implementation.  In truth, the best logical representation lies 
somewhere between these two extremes, where certain key regions in the physical
implementation need to be highlighted in the logical representation, while 
other regions need to be hidden.

```
└ ┴ ┬ ├ ─ ┼ ┐ │ ┤ ┘ ┌
```