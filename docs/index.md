---
layout: default
---

[Perl]:                     https://www.perl.org
[git]:                      https://git-scm.com
[github]:                   https://github.com
[spacecraftrdl/launchpad]:  https://github.com/fiveladdercon/launchpad 
[RDM]:                      rdm/                                          "Resident Data Model"
[spacecraft]:               cli/
[Engine API]:               api/


/ˈspāsˌkraft/
===================

Spacecraft is a hardware memory mapping tool.  

It is built on the premise that hardware memory maps are vital to so many audiences that they are 
never quite in the right format for everyone. So rather than dictate output format, Spacecraft 
instead constructs a light weight, flexible and _fast_ memory resident model of the hardware 
memory map and provides an extensive and powerful API that allows *you* to alter and output 
the memory map in whatever format *you* need.

Spacecraft has 5 components:

| [Resident Data Model (RDM)](rdm/) | A light weight, flexible, memory resident model of a hardware memory map.                                                                     |
| [Spacecraft CLI](cli/)            | A wickedly fast command line tool with an embedded [Perl][] interpretter for accessing the **[RDM][]** using **engines** written in [Perl][]. |
| [Engine API](api/)                | An extensive and powerful extension to spacecraft's embedded [Perl][] interpretter for building & traversing the **[RDM][]**.                 |
| [Rocket Fuel RDL](rdl/)           | A minimalist, yet expressive file format for persisting the **[RDM][]**.                                                                      |
| [Launch Pad](pad/)                | An open source, community driven ecosystem for sharing spacecraft **engines**.                                                                |

In it's basic form, [spacecraft][] is a command line tool used to reformat definitions 
like any other register definition tool:

```
$ spacecraft module.rf verilog.pl
```

Here [spacecraft][] is used to construct an [RDM][] from the definitions in `module.rf` and output 
the [RDM][] in verilog format using the `verilog.pl` engine.  This is pretty standard stuff.

```
$ spacecraft chip.rf html.pl uvm.pl
```

Here [spacecraft][] is used to construct an [RDM][] from `chip.rf` and output documentation in 
HTML format the `html.pl` engine _and_ output a simulation model in UVM format using the `uvm.pl` 
engine.  Again, this is pretty standard stuff.

Where things get a little different is that each engine operates on the _same_ [RDM][], so that 
you can chain a series of engines together:

```
$ spacecraft A/chip.rf eco.pl rf.pl B/
```

Here [spacecraft][] is used to construct an [RDM][] from the first spin (`A/chip.rf`), document 
engineering change order (`eco.pl`) - like the repurposing spare registers at the gate level - 
and write them out in .rf format for non-hardware consumers (`rf.pl B/`).  Here the `eco.pl` 
engine does not output anything, but rather programmatically captures the migration of the 
hardware memory map from one chip spin to the next.

You can also use the [Engine API][] to construct the [RDM][], so that you can use [spacecraft][]
as a general purpose transformation tool:

```
$ spacecraft vendor_read.pl vendor_input.txt proprietary_write.pl proprietary_output.txt
```

Here the `vendor_read.pl` (read) engine constructs an [RDM][] from the `vendor_input.txt`, 
then writes it out in `proprietary_output.txt` format with the `proprietary_write.pl` 
(write) engine.

Now because you've used the [RDM][] as an intemediary, you can reuse your `proprietary_write.pl`
write engine if yet another vendor format comes along:

```
$ spacecraft vendor2_read.pl vendor2_input.txt proprietary_write.pl proprietary_output.txt
```



Get Spacecraft
==============

The Spacecraft is distributed as a repository hosted on [github][].

1. Install [git][] locally, if needed.

2. Change directories to some install directory:

   ```
   $ cd </some/installation/directory>
   ```

3. Locally clone the repository.

   If you may ultimately contribute back to Spacecraft:

   1.  Create a [github][] account, if needed.

   2.  Fork the [spacecraftrdl/launchpad][] repository.

   3.  Clone your fork:

	   ```
	   $ git clone https://github.com/<youraccount>/launchpad
	   ```

   If you're just poking around: 

   1.  Clone the [spacecraftrdl/launchpad][] repository directly:

	   ```
	   $ git clone https://github.com/spacecraftrdl/launchpad
	   ```

	   but realize you're on your own and that that any changes you make 
	   can't be merged back in without a [github][] account.

   If in doubt, fork then clone.

4. Set the `SC_LAUNCHPAD` environment variable to the local launchpad repository 
   and add it to your path:

   ```
   $ cd launchpad
   $ echo "export SC_LAUNCHPAD=$PWD"  >> ~/.profile  # Note double quotes
   $ echo 'PATH=$PATH:$SC_LAUNCHPAD'  >> ~/.profile  # Note single quotes
   $ source ~/.profile
   ```

5. Link the appropriate binary for your architecture to `spacecraft` in the launchpad root:

   ```
   $ ln -s bin/spacecraft_<version>_<arch> spacecraft
   ```
