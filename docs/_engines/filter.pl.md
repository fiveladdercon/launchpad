---
title: filter.pl
permalink: /engines/filter/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


filter.pl
=========

[filter.pl] removes selected nodes or node properties from the model.

This is intended for tailoring the model for customer use by removing proprietary 
information.


Usage
-----

```
spacecraft ... filter.pl [-property PATTERN] [-keep PATTERN] ...
```

The [filter.pl] engine has two distinct mode of opperation: property removal and
node removal.  Both can be applied at the same time, though if the node is to
be removed, property removal on that node becomes irrelevant.

-p PATTERN, -property PATTERN
  : Remove properties from nodes that match the given **PATTERN**.  
    More than one **-property** switch can be used to specify multiple patterns.

-k PATTERN, -keep PATTERN
  : Remove nodes from the model that have the **filter property** UNLESS the
    property value matches the given **PATTERN**.  More than one **-keep** switch 
    can be used to specify multiple patterns.

**PATTERNS** can be strings or regular expressions.

Note the difference in modes: property patterns identify which properties are 
removed, while keep patterns identify which nodes are NOT removed.  See more
about this subtle distinction in the examples below.


Properties
----------

filter PATTERN
  : A node with the **filter property** is removed from the model UNLESS the
    property **PATTERN** matches a **PATTERN** supplied on the command line.


Example
-------

#### Property Removal ####

Remove verilog properties from the model before shipping the model to a customer
in a packed rocket fuel file.

```
$ spacecraft soc.rf filter.pl -p verilog pack.pl rf.pl customers.rf
```

#### Node Removal ####

Suppose a rocket fuel file contains the following definitions:

```
0W  1W  0h  GENERAL_CONTROL    RW;

1W  1W  0h  CUSTOMER_X_SPECIAL RW  -filter customer_X;

1W  1W  0h  CUSTOMER_Y_SPECIAL RW  -filter customer_Y;

2W  1W  0h  ENGINEERING_DEBUG  RW  -filter engineering;
```

To remove all engineering and specific customer fields for the general customer:

```
$ spacecraft ... filter.pl ...
```

Here only the `GENERAL_CONTROL` field would remain as all other nodes have 
a **filter property** and hence get removed by default.

To build a model for a specific customer:

```
$ spacecraft ... filter.pl -keep customer_X  ...
```

Here both the `GENERAL_CONTROL` & `CUSTOMER_X_SPECIAL` fields would remain and
all other fields removed.  Note that both the engineering fields and the fields 
for the other customer have been removed without explicitly specifying their
removal.  This is the difference between property and node removal modes.

To release the engineering fields to a specific customer:

```
$ spacecraft ... filter.pl -k engineering -k customer_X  ...
```

Here only the `CUSTOMER_Y_SPECIAL` fields would be removed.

The **filter property** effectively marks a set of nodes as an **exclusion set**
-- a set of nodes that should to be excluded from the model by default when it 
goes to customers.  Pattern matching is then used to selectively shrink the 
exclusion set, thereby NOT excluding matching nodes and hence effectively 
including them.

The difference between NOT EXCLUDED and INCLUDED is subtle, and though it 
may seem counter-intuitive to define things that way, ultimately it is the 
command line usage that makes things clear: 

> to build a model for audience X, drop all tagged nodes EXCEPT those 
> for audience X.

In this case you only need to know that about audience X when working on 
audience X.  And by specifying audience X and only audience X, you won't 
accidentally leave in nodes for audience Y by forgetting about audience Y.

The alternative would be to construct the exclusion set by hand:

> to build a model for audience X, drop nodes tagged for audience Y, 
> audience Z, etc...

This, in contrast, requires knowing and specifying the complete set of audiences 
less the one for the one audience.  This is error prone, expecially with large 
field sets and/or many different audiences.  It is also less conservative, since 
typos in the filter property or the command line will accidentally leak 
proprietary information to the wrong audience.
