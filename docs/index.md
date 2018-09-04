---
layout: default
---

[model]:    /model/
[language]: /fuel/

Spacecraft
==========

**Spacecraft** is an address mapping tool for hardware designers.

It is built on the premise that hardware address maps<sup>a</sup> are vital to 
so many audiences that they are never quite in the right format for everyone. 
So rather than dictate input and output formats, Spacecraft instead constructs 
a light weight, flexible and _fast_ memory resident model of the hardware 
address map and provides an extensive and powerful API that puts *you* in 
control of the input, output and whatever else you might need to do.

Features
--------

* A memory resident [model][] of an address map, with:
   * Bitwise addressing & sizing using a [fixed point notation](/fuel/#bits) to 
     detangle the access problem from the mapping problem;
   * A [hierarchical structure](/model/#regions) to divide and conquer the 
     mapping problem;
   * Support for named regions like RAMs, ROMs and registers;
   * Support for anonymous regions to _design_ a 
     [logical representation](/model/#hiding-implementation-details-with-anonymous-regions) 
     that is distinct from the physical representation;
   * Support for custom name import rules;
   * Multi-dimensional field & region arrays;
   * Unlimited user defined properties per node; and
   * Untyped fields to detangle the implementation problem from the mapping 
     problem;
* An open source library of engines that output the model in various formats; and
* A simple, expressive [language](/fuel/) for persisting the model.


<hr class="sc_footnote">
<small>
   (a) Also known as register maps or memory mapped I/O.
</small>