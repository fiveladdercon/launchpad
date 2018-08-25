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
           [-I PATH] [-R] [-E] [ROCKETFUEL]
           ENGINE.pl [OPTIONS] [ENGINE.pl ...]
```

Spacecraft is a command line tool that constructs a memory resident model of
an address space, then executes one or more engines that construct, alter or
output the model.

Engines
-------

Each engine to be executed is passed on the command line as ENGINE.pl.

The .pl extension is required, as it delimits where the options to one engine 
ends and the next engine begins.  The implication is that the options passed to 
spacecraft must be passed before the first engine.

If the ENGINE.pl is not a fully qualified path, spacecraft will look for the
engine in $SC_LAUNCHPAD/engines and then issue a warning if not found.

At least one ENGINE.pl should be specified, otherwise spacecraft has nothing to 
do.

Rocket Fuel
-----------

If a ROCKETFUEL file is supplied on the command line, the model is populated
with the definitions declared in the file.  Otherwise the model is an empty 
address space.

