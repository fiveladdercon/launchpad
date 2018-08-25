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