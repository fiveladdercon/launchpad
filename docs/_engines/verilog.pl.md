---
title: verilog.pl
permalink: /engines/verilog/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


verilog.pl
==========

[verilog.pl] outputs the model as a verilog module.

Untyped regions are removed by recursively importing children into parents,
which leaves the a set of fields and typed regions to implement.

Typed regions result in bus decoder ports on the module, while fields result in
functional ports on the module.


Usage
-----

```
spacecraft ... verilog.pl [OUTPUT]
               [-types TYPES.pm]

```

Output the space to the **OUTPUT** file if specified or **{TYPE}.v** otherwise.

-types TYPES.pm
  : Use custom field types implemented in the **TYPES.pm** library.  The .pm
    suffix is mandatory.  See [custom field types](/fields/) for details on
    writing custom types.


Properties
----------

verilog:import
  : Include children of the typed region as if they had be declared
	 in an untyped region.  Has no effect if applied to fields or 
    untyped regions.

verilog:export TYPE
  : Exclude children of an untyped region as if they had be declared
    in a typed region with type **TYPE**.  Has no effect if applied to
    fields or typed regions.

verilog:portglob PORTGLOB
  : The **PORTGLOB** specifies how the decoder ports on the module are prefixed
    and/or suffixed.  Has no effect if applied to a field.  It is a required
    property if a typed region is anonymouns and has a glob of `*`.


Example
-------

Generate a top level decoder for the chip:

```
$ spacecraft soc.rf verilog.pl
```


