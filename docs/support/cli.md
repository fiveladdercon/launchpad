---
layout: default
title: Command Line Interface
permalink: /basics/cli/
---

Command Line Interface
======================

```
spacecraft [-h|--help] [--version] 
           [-l LOGFILE|-u]
           [-Q|-q|-v|-V]
           [-R] [-I FUELSUPPLY] [-E] [ROCKETFUEL]
           ENGINE.pl [OPTIONS] [ENGINE.pl ...]
```

Spacecraft is a command line tool that constructs a memory resident model of
an address space, then executes one or more engines that construct, alter or
output the model.

Engines
-------

Each engine to be executed is passed on the command line as **`ENGINE.pl`**.

The **`.pl`** extension is required, as it delimits where the **`OPTIONS`** to 
one engine end and the next engine begins.  The implication is that the options 
passed to spacecraft itself must be passed _before_ the first engine.

Well behaving engines show a help message when passed a `--help` option, so use 
this option to find out details about the `OPTIONS` for a given `ENGINE.pl`.

If the `ENGINE.pl` is not a fully qualified path, spacecraft will look for the
engine in `$SC_LAUNCHPAD/engines` and then issue a warning if not found.

At least one `ENGINE.pl` should be specified, otherwise spacecraft has nothing 
to do.


Rocket Fuel
-----------

If a **`ROCKETFUEL`** file is supplied on the command line, the model is populated 
with the definitions declared in the file.  Otherwise the model is an empty space.

-R
:	**Recursively** populate the model.  Without the `-R` switch, typed regions
	are left childless.  With the `-R` switch, typed regions are populated
	with the definitions decared in the associated file - e.g. a region with
	type X will populate with definitions declared in X.rf. 

-I FUELSUPPLY
:	**Include** **`FUELSUPPLY`** as a fuel supply, which is a list of search 
    paths.  When locating a .rf file, spacecraft looks in the following paths 
    in sequence:

      1.  Paths included with the `-I` switch on the command line,
      2.  Paths included with the `&sc_fuel_supply` EngineAPI,
      3.  Paths defined in the `$SC_FUEL_SUPPLY` environment variable,
      4.  The current working directory, `.`.

-E
:	Look for **embedded** definitions in .v & .sv files.  Rocket Fuel can
    be embedded directly in verilog files by enclosing field & region definitions 
    between `/*{` and  `}*/`.  When embedded definitions are enabled, spacecraft
    will look for

      1.  a `.rf` in each fuel supply, then
      2.  a `.v`  in each fuel supply, then
      3.  a `.sv` in each fuel supply.

The `ROCKETFUEL` passed on the command line may also be a .v or .sv file with
embedded definitions.  The `-E` switch is only required when the model is being 
recursively populated with embedded sub space defintions.


Mission Control
---------------

Each spacecraft mission reports status to STDERR and a log file.  Reporting to
STDERR implies that engine STDOUT can be easily redirected.

Reports to STDERR can be dialed up or down depending on the `-Q`, `-q`, `-v` &
`-V` verbosity switches:

-Q
:  Be **very quiet**, reporting only warnings and errors to STDERR.

-q
:  Be **quiet**, reporting minimal notes to STDERR in addition to warnings and 
   errors.

-v
:  Be **verbose**, reporting many notes to STDERR in addition to warnings and
   errors.

-V
:  Be **very verbose**, reporting everything to STDERR.


Regardless of the STDERR verbosity setting, everything is always logged to
the `spacecraft.log` log file unless the following switches are used:

-l LOGFILE
:  	**Log** to `LOGFILE` instead of `spacecraft.log`.

-u
:	**Unlogged** mission, meaning that no log file is created.
