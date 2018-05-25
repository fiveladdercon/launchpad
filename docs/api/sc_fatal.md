---
layout: default
title: sc_fatal API
---


sc_fatal
========


Prototype
---------

```
&sc_fatal(format,...)
```


Parameters
----------

| Parameter | Type      | M/O | Description                                    |
|:----------|:----------|:---:|:-----------------------------------------------|
| `format`  | `string`  |  M  | A printf style format string.                  |
| `...`     | `mixed`   |  O  | The arguments to be formatted.                 | 

M/O = Mandatory/Optional


Return Type
-----------

_None_


Description
-----------

The `sc_fatal` utility function unifies logging between engines and spacecraft,
creating a single log file that spans all engines.

Fatals are printed to `stderr` in red, logged and counted as errors, and 
processing halts.  Fatals are typically a result of a system failure, such 
as file system and memory system issues.


Example
-------

engine.pl:

```perl
&sc_fatal("Out of %s","disk space");
```

stderr:

```
** FATAL: Out of disk space.
```

logfile:

```
** FATAL: Out of disk space.
```
