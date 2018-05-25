---
layout: default
title: sc_note API
---


sc_note
=======


Prototype
----------

```
&sc_note(level,format,...)
```


Parameters
----------

| Parameter | Type      | M/O | Description                                    |
|:----------|:----------|:---:|:-----------------------------------------------|
| `level`   | `integer` |  M  | The verbosity level.                           |
| `format`  | `string`  |  M  | A printf style format string.                  |
| `...`     | `mixed`   |  O  | The arguments to be formatted.                 | 

M/O = Mandatory/Optional


Return Type
-----------

_None_


Description
-----------

The `sc_note` utility function unifies logging between engines and spacecraft,
creating a single log file that spans all engines.

The `level` parameter sets the verbosity threshold.  Notes will print to `stderr`
when the verbosity on the command line is equal to or higher than the threshold.
Hence a `level` of 0 will always show on screen and higher levels will show
when dialed-up with the command line.

All notes are logged to the log file, if present, regardless of the verbosity
level.



Example
-------

engine.pl:

```perl
&sc_note(0,"This will always get shown on screen.");
&sc_note(1,"The value of %s is %d.","x",10);
&sc_note(2,"This will get shown on screen when the verbosity on the command line is 2 or higher.");
```

stderr: (default verbosity)

```
** NOTE : This will always get shown on screen.
** NOTE : The value of x is 10.
```

logfile:

```
** NOTE : This will always get shown on screen.
** NOTE : The value of x is 10.
** NOTE : This will get shown on screen when the verbosity on the command line is 2 or higher.
```
