---
layout: default
---

Spacecraft
==========

**Spacecraft** is a register definition and mapping tool built for end-to-end 
consistency.

It is built on the premise that consistent hardware register definitions are 
vital to so many audiences but are very rarely in the right format for everyone.

So rather than focus on formats, Spacecraft executes **engines** that use an 
**API** to interact with a memory resident **model** of an address space.  You 
can use an engine from the open source library, or write your own.


Features
--------

* A fast, flexible memory resident **[model][1]** of an address space, with:
   * **[Bit-wise addressing & sizing][2]**;
   * **[Fields][3]** with no type semantics;
   * Hierarchical structuring with **[regions][4]**;
   * Named regions like RAMs, ROMs and registers; and anonymous regions;
   * Typed, reusable regions and untyped, one-time regions;
   * **[Multi-dimensional arrays][5]** of fields & regions; and
   * Unlimited custom **[properties][6]**;
* An extensive, object oriented **API** to interface with the model;
* An **[open source library of engines][7]**; and
* A simple, expressive **[language][8]** for persisting the model.


Status
------

See the [project status][9] page for the current state of affairs.

[1]: /model/
[2]: /model/#bits
[3]: /model/#fields
[4]: /model/#regions
[5]: /model/#dimensions
[6]: /model/#properties
[7]: https://github.com/fiveladdercon/launchpad
[8]: /fuel/
[9]: /status



