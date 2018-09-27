---
title: verilog.pl
permalink: /engines/verilog/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}
[types]: {{site.engine_baseurl}}/Verilog/Fields.pm


verilog.pl
==========

[verilog.pl] outputs an implementation of the space in a verilog module.

Fields are implemented according to their type and typically (but not
always) result in ports on the verilog module.

Typed regions result in decoder ports.

The children of untyped regions are imported into the space and treated
as either a field or a typed region.


Field Types
-----------

To spacecraft, field types are just strings.  To the verilog engine, however,
a field type needs to translate into a verilog implementation.  Hence the verilog 
engine dictates the set of field types supported, not spacecraft.

The verilog engine has several predefined types:
 
* RW
* RO

But the engine is built with an object oriented architecture that allows for
adding custom types by deriving classes and passing them on the command line.



Usage
-----

```
spacecraft ... verilog.pl [OUTPUT]
               [-type TYPE.pm]
               [-bus BUS.pm]

```

Output the space to the OUTPUT file if specified, _space type_.v otherwise.

-type TYPE.pm
	: Use TYPE.pm as the implementation of a field with a custom TYPE.

-bus BUS.pm
	: Use BUS.pm as the implementation of the bus in the verilog module.



Properties
----------

-verilog:import
	: Include children of the typed region as if they had be declared
	  in an untyped region.

-verilog:portglob GLOB
	: If a typed region is anonymous<sup>1</sup> and has a glob of `*`, the 
	  supplied GLOB dictates how the decoder ports on the module are named.


Example
-------

```
$ spacecraft ... verilog.pl
```


Custom Fields
-------------

Custom field types can be added to the verilog engine.

Suppose you wanted a field type that implemented a constant in such a way that 
it didn't get optimized or pruned out in synthesis so that you could  later ECO 
it to identify the metaspin version.

```
//
// The CONST type needs a verilog implementation.
//
0W  16b   deadh   METAL_VERSION   CONST;
```

To implement this type in verilog you would need to pass an implemenation of 
the `CONST` type to the verilog engine:

```
$ spacecraft soc.rf verilog.pl -type CONST.pm
```

Now when the verilog engine goes to implement the METAL_VERSION field, it 
effectively does:

```perl
my $Field = new CONST;  # Create an instance of the CONST type
$Field->implementation; # Add the implemenation to the module
```

Hence the `CONST.pm` is a package with an implementation method.

Implementation methods use verilog Field and Bus APIs to get and add Signals
in the Module:

```perl
package CONST;                  # Implement the CONST type
use base ('Field');             # which is a custom Field type

sub implemenation {             # with an implemenation method.
   my $this    = shift;

   my $Clock   = $this->get_bus_clock;
   my $Port    = $this->get_field_port;
   my $Value   = $this->get_field_value;
   my $default = $this->get_field_default;

   # $Clock, $Port and $Value are Signal objects.

   # 1) Configure the Port to be an (internal) wire:

   $Port->wire;

   # 2) Assign the Port the constant value:

   $this->assign($Port,$default);  # i.e. assign $Port = $default;

   # 3) Declare a non-reset register with the CONST_ prefix so that synthesis
   #    can find the register and add a don't touch constraint.

   my $Const = $this->reg("CONST_".$Port, $Clock);

   # 4) Clock the register:

   $this->always($Const,$Port);  # i.e. always @($Clock) $Const <= $Port;

   # 5) Configure the Value to be a wire:

   $Value->wire;

   # 6) Assign the register to the value:

   $this->assign($Value,$Const);  # i.e. assign $Value = $Const;

   # 7) Add the Value to the Return path:

   $this->add_bus_read_data($Value);
	
}
```

The built in [types] are implemented this way and provide a good demonstration
of different implementations.




<hr class="sc_footnote">
<small>
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
</small>
