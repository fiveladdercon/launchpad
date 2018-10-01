---
layout: default
title: Custom Fields
permalink: /fields/
---

[1]: {{site.engine_baseurl}}/Verilog/Fields.pm

Custom Field Types
==================

To the spacecraft executable field types are just strings.  To the verilog 
engine, however, a field type needs to translate into a verilog implementation.
Hence the verilog engine dictates the set of field types supported, not the 
spacecraft executable.

The verilog engine has several [predefined types][1], but the engine 
is built with an object oriented architecture that allows adding custom 
types by passing a library of derivative classes on the command line.


Introduction
------------

Suppose you wanted a `CONST` field type that didn't get optimized or pruned out 
in synthesis so that you could later ECO the value to identify the metaspin 
version.

```
//
// You can just reference the CONST type in your Rocket Fuel because
// it's just a string to spacecraft.  However it does need an implementation
// if you try to generate a verilog module from this file.  You'll get
// an error if the type does not exist.
//
0W  16b   deadh   METAL_VERSION   CONST;
```

To implement this type in verilog you would need to pass an implemenation of 
the `CONST` type to the verilog engine:

```
$ spacecraft soc.rf verilog.pl -types CONST.pm
```

Here we name the package `CONST.pm`, but the package name doesn't really matter
as long as the package contains a `CONST` class.  In fact if you have more than
one custom type, they can all be added to the same package, creating a library
of custom types.

Now when the verilog engine goes to implement the `METAL_VERSION` field, it 
effectively does:

```perl
my $Field = new CONST;  # Create an instance of the CONST type
$Field->implementation; # Add the implemenation to the module
```

Hence the `CONST.pm` package contains a `CONST` class with an `implementation` 
method.

Implementation methods use inherited APIs to get or add **Signals** in the 
**Module** and use them in assign statements and always blocks:

```perl
package CONST;                  # Implement the CONST type
use base ('Field');             # which is a custom Field type

sub implemenation {             # with an implemenation method.
   my $this = shift;

   # 1) Get Signals from the Module

   my $Clock   = $this->get_bus_clock;
   my $Port    = $this->get_field_port;
   my $Value   = $this->get_field_value;
   my $default = $this->get_field_default;

   # $Clock, $Port and $Value are Signal objects.

   # 2) Configure the Port to be an (internal) wire:

   $Port->wire;

   # 3) Assign the Port the constant value:

   $this->assign($Port,$default);  # i.e. assign $Port = $default;

   # 4) Declare a non-reset register with the CONST_ prefix so that synthesis
   #    can find the register and add a don't touch constraint.

   my $Const = $this->reg("CONST_".$Port, $Clock);

   # 5) Clock the register:

   $this->always($Const,$Port);  # i.e. always @($Const.Clock) $Const <= $Port;

   # 6) Configure the Value to be a wire:

   $Value->wire;

   # 7) Assign the register to the value:

   $this->assign($Value,$Const);  # i.e. assign $Value = $Const;

   # 8) Add the Value to the Return path:

   $this->add_bus_read_data($Value);
	
}
```

This implementation method will result in the following verilog for the
`METAL_VERSION` field inside the module:

```
module ...
...
wire [15:0] metal_version;
wire [15:0] metal_version_value;
...
reg  [15:0] CONST_metal_version;
...
assign metal_version       = 16'hdead;
assign metal_version_value = CONST_metal_version;

always @(posedge bus_clock) begin
  CONST_metal_version <= metal_version;
end
...
bus_read_data = metal_version_value |
...
endmodule
```

The implementation:

* Adds two wires to the module (Steps 2 & 6).
* Adds a `CONST_` reg to the module (Step 4).
* Adds two assign statements (Steps 3 & 7).
* Adds an always block (Step 5).
* Adds the value into the return path (Step 8).

The built in [types][1] are implemented this way and provide a good demonstration
of different implementations.


Verilog Engine Classes
======================

The verilog engine has an object oriented architecture that uses the following 
naming convention:

* Classes start with an uppercase letter.
* Instance variables start with an uppercase letter.
* Strings and numbers start with a lowercase letter.

The architecture is composed of the following classes:

#### General verilog structure:

A **Module** has Blocks of logic that use Signals.

A **Signal** is reg or wire variable that can optionally be an input or output.

A **Block** of logic is a group of related always blocks and assign statements.

#### Specific to accessing fields & regions:

A **Slave** is a Module that has a Bus that accesses a set of Fields.

A **Field** is a Block accessed by the Bus that implements a function.

A **Bus** has a Decoder Block that fans-out bus inputs to Fields and a Return 
path Block that fans-in and assembles bus outputs.

In this architecture, then, custom field types are derivatives of the Field
class, since each type implements a specific function.  Fields are Blocks that 
reside in a Slave that interface with the Bus and use Signals in always blocks
and assign statements to implement a function.

