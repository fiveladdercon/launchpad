---
layout: default
title: Introduction
permalink: /basics/intro/
---

[contributing]: contribute/
[contribute]:   contribute/


What is Spacecraft?
===================

**spacecraft** is a command line tool that constructs a memory resident **model** 
of an address space, then executes one or more **engines** to construct, alter or 
output the model.

You either use engines from the **Launch Pad**, the open source library of engines,
or write your own when those don't suit your needs.


Basic Usage
-----------

### Need a verilog module?

Use spacecraft to read in field definitions from a file and implement them in 
verilog:

```
$ spacecraft module.rf verilog.pl
```

### Need a simulation model or some documenation?

Use spacecraft to read in a hierarchy of definitions and output the structure
in multiple formats for various audiences:

```
$ spacecraft -R chip.rf sim.pl lab.pl sw.pl doc.pl doc.pl -customer X ...
```


Advanced Usage
--------------

As with all tools of this nature, the normal usage is subject to the 
following conditions:

*  The input is always in the correct format, and
*  The output is always in the correct format.

Experience has shown that these conditions rarely hold, especially when
integrating inputs from multiple vendors.  Where most tools leave designers or
integrators to deal with input and output formatting issues, spacecraft is 
designed to take them head on:

> spacecraft constructs a memory resident **model** of an address space, then 
> executes one or more **engines** that construct, alter or output the model.


### Don't have the input in the correct format?

Write your own engine to construct the model from the input:

```
$ spacecraft vendor.pl vendor.in rf.pl
```

Here your custom `vendor.pl` engine reads definitions in the `vendor.in` file
and constructs the model, while the open source `rf.pl` engine writes out the 
model in **Rocket Fuel** format -- the spacecraft native format.


### Have your own format?

Write your own engine to output the model in your format:

```
$ spacecraft module.rf proprietary.pl
```

Here the model is loaded from the `module.rf` Rocket Fuel file and output in
your format using your `proprietary.pl` engine.


### Rocket Fuel not your cup of tea?

Skip it entirely and go direct from vendor to proprietary:

```
$ spacecraft vendor.pl vendor.in proprietary.pl
```

Note that in this case you are using the spacecraft memory resident model as an 
intermediary that isolates the input problem from the output problem.  This is 
particularly nice when yet another vendor format comes along:

```
$ spacecraft vendor2.pl vendor2.in proprietary.pl
```

Here the `proprietary.pl` engine is reused for output, so you can focus on the 
new vendor input.

*The separation of the input problem from the output problem is a major
benefit of using spacecraft.*


### Need to tweak an output?

Spacecraft engines are open source, so go ahead and hack what you need.


### Is it good for the rest of us?  

Consider [contributing](/contribute) your changes.


### Is that all?

Nope.  Since all engines operate on the model in sequence, you can chain a 
series of engines together to build a read-modify-write type flow:

```
$ spacecraft chip.rf eco.pl html.pl
```

Here spacecraft reads in the chip, implements an engineering change order - like 
the repurposing of spare registers or changing a default at the gate level for a 
metal spin - and *then* outputs the documentation.

The difference here is that the `eco.pl` engine does not output anything, but 
rather programmatically captures the migration of the hardware memory map from 
one chip spin to the next.  It is a much more compact representation of the 
change that eliminates maintaining multiple versions of source files that
typically differ in near trivial ways.

*You don't get this kind of flow with other tools.  Sharing the memory resident
model between standard and custom engines is a major benefit of using spacecraft,
as the model is flexible, fully API accessible and -- most importantly -- 
**fast**.*


What you need to know
=====================

Spacecraft
----------

**spacecraft** is a command line tool that constructs a memory resident **model** 
of an address space, then executes one or more **engines** to construct, alter or 
output the model.

You either use engines from the **Launch Pad**, the open source library of engines,
or write your own when those don't suit your needs.


The Model
---------

The **model** is a hierarchy of **regions** that map **fields** into an address 
**space**.

*All users should understand the model, as you will either be coding it in a
Rocket Fuel file, or manipulating it with the EngineAPI in an engine.*


Engines
-------

An **engine** is a [Perl](http://www.perl.org) script that uses the **EngineAPI** 
to interface with spacecraft to construct, alter or query the model.  One or 
more engines are passed to spacecraft on the command line and spacecraft will 
execute them in sequence.

*Most users are basic users and only need to know which engines are available 
and how to use each of them.  It's when you find yourself stuck with an 
input, output or migration problem that you'll graduate to an advanced user and 
start hacking the Launch Pad engines or writing and possibly 
[contributing](contribute) your own.*


Launch Pad
----------

The **Launch Pad** is an open source library of engines.  It is also home to the 
documentation and the spacecraft binaries.

*If you're reading this, then you've found the Launch Pad.*


Rocket Fuel
-----------

**Rocket Fuel** is native file format for peristing the spacecraft model to 
disk.

Populating the model from Rocket Fuel is the only form of model manipulation 
built in to spacecraft; all other model manipulation -- even outputing Rocket 
Fuel -- is delegated to engines.

*As a spacecraft user you are not obligated to code the model with Rocket Fuel, 
but if you don't, you will need to write an engine to construct the model from 
whatever format you do code in.  Note that if you do write an engine for your 
format, you can then output the model in Rocket Fuel format with the `rf.pl` 
engine, meaning you can convert you're existing format, see the result and make 
an informed choice about which format to use.*


Boosters
--------

Despite being freely available on [github](https://github.com/fiveladdercon/launchpad),
spacecraft is not free -- as in no-cost -- software.

While you can freely clone the Launch Pad, [install](/basics/install) the 
spacecraft executable and start poking around for no-cost, spacecraft executes 
a start-up check that will *waste your time* unless a **booster** is also 
installed.

A **booster** is a cryptographically signed license that is locally installed and 
enables your spacecraft executable to run at full speed.  You can purchase a 
booster here or send an email with your company, name, and email to 
<u>fiveladdercon[at]gmail.com</u> and request a trial.

*Of course you can always just keep running spacecraft without a booster, but the
engineering time wasted in the long haul is likely more expensive than a booster.*
