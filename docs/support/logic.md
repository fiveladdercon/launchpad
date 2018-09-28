---
layout: default
title: Logical Representation
permalink: /model/logic
---

Logical Representation vs Physical Implementation
=================================================

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

Implementation Modelling with Rocket Fuel
-----------------------------------------

* Fields are implemented according to their type and typically, but not
  always, result in ports on the verilog module.

* Typed regions result in decoder ports.

* The children of untyped regions are imported into the space and treated
  as either a field or a typed region.

The net result is that **a Rocket Fuel file effectively describes a verilog
module**. This is actually true even when the verilog engine is not used!


#### Port Globs ####


As 

(1) Anonymous typed regions effectively hide implemenation details that are not 
relevant to any other audience.  For example, consider a single functional block 
that has both transmit and receive functions and hence has both transmit and 
receive control and status fields.  Typically the associated functional logic is 
implemented in separate modules, with separate clock domains, and in many cases 
by different people.  Normally this will either result in either (i) one slave 
with lots of cross domain wiring, (ii) two slaves wired out the one functional 
block or (iii) a decoder that splits the one functional block into two internal
slaves.  Option (i) is the specified intent, but since it is the most error prone
implementation, it is not a great choice.  Option (ii) does not technically meet
spec, but works. But it also just pushes the problem on to the integrator and
ultimately software if nobody deals with it.  Option (iii) is the best from an 
implemenation stand point but introduces a level of hierachy in the register 
model that is _present only for implementation reasons_.  This is clutter in
the "logical" model of one block with both receive and transmit functions.  
Using anonymous regions for this scenario will hide this implemenation detail,
effectively glueing the two sub-regions together without introducting new
names.
