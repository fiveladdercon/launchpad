---
layout: default
title: About
permalink: /about
---

About Spacecraft
================


The Pattern
-----------

Spacecraft came about because I was the guy left with integrating registers 
definitions from all over the place and formatting them into coherent views 
for simulations, validation benches, driver software, and the engineering & 
customer docs.  Since the tool I was using didn't handle every input and output 
I needed I wrote a lot of scripts to "move" the definitions along from where 
they were to where they needed to go.

Script after script after script had the same pattern:

1. Read definitions in some format and construct a "model"
2. Write out the definitions in some other format

In many cases the input format was line based, and constructing "the model" was 
as trivial as splitting a line into variables.  But those were the easy cases
where all the structural information had been stripped away - i.e. a flat space.


The Problem: Logical Representations
------------------------------------

Eventually the transformations needed the structural information because I was
no longer managing flat spaces, but **logical representations**, which I define
as: a selected subset of the physical implementation.

A flat space is one logical representation.  However a flat space does not 
convey any hardware reuse information, so it not conveyed to software.  A 
fully elaborated physical implementation is another logical representation. 
This representation carries the hardware reuse information, but carries it to 
the extreme, as it also includes all the "dirty laundry" of the physical 
implementation (such as the regioning of the space by design assignment - a 
logically irrelevant regioning to everybody other than the assigned designers, 
*especially customers*).

A **good logical representation** lies somewhere in between the fully flattened 
and fully elaborated representations. A good logical representation, however, 
does not just happen: **it must be designed**.

Managing logical represenations made each transformation more complex, as the
structural information needed to find it's way from the input to the output 
at each stage.  This, in turn, made the model for each transformation more and 
more complex.  And as one transformation lead to the next, I'd have start from 
scratch and create a new model for each transformation.  What a pain.


The Genesis: Model Abstraction
------------------------------

The model needed abstraction.  But since the model is memory resident and 
run-time transient, it needed a clear definition and API for interfacing
with it.  

Most tools only support the extremes of logical representation: fully flattened 
or fully elaborated, so the model was designed to manage the logical 
representation above and beyond the physical implementation.  The result was 
the minimalist model and it's API now in Spacecraft, albeit in script format.

Soon after abstracting the model into a reusable package, the pattern of the
scripts become even more evident. Now every script had:

1. A read function that used the API to construct the model.
2. A write function that used the API to write out the model.

It was immediately obvious that the read & write functions should be moved to 
into a library so the the inputs and outputs could be mixed and matched.


The Refinement: Porting for Performance
---------------------------------------

The thing was: implementing the model in script format meant it was slow - really
slow.  Especially as the volume of information to be transformed became large.
So before I could push the I/O functions into a library, I needed to deal with 
speed.

I moved the API and the model into C and swigged the API.  This improved the 
performance by orders of magnitude, so was well worth the effort.


The Side Effects: An Embedded Interpretter Extension & A Native Parser
----------------------------------------------------------------------

While mucking around with extending the interpretter with C, it also occured to 
me that if I could embedded the extended interpretter and pass the model between 
scripts, I could build a library of read and write _scripts_ instead of a library 
of read & write _functions_.  Each script would focus on one half of the problem,
so mixing and matching formats would become command line options.  This would
be far more portable and furthermore the scripts could serve as examples of API 
usage examples for anyone else that needed to "move" a model from one format 
to another.  A tinker here and a tinker there and then I found myself with an 
executable with an embedded interpretter that could execute multiple scripts and 
pass the model between them: let the scripting begin.  Well not quite.

With the executable and not the interpretter as the main program, it became 
clear that the model needed a file format that could be read natively in C. This 
lead to a syntax and grammar definition and the corresponding Flex lexer and 
Bison parser was added to the program.


Spacecraft
----------

Spacecraft is an evolution of that first executable.  It has been built from the 
ground up with all of the benefits and none of the warts.  It is also freely 
available with an open source library of scripts.

