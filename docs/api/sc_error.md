---
layout: default
title: sc_error API
---


sc_error
========


Prototype
---------

```
&sc_error(format,...)
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

The `sc_error` utility function unifies logging between engines and spacecraft,
creating a single log file that spans all engines.

Errors are printed to `stderr` in red, logged and counted, but processing 
continues.  Errors are typically a result of faulty input, and thus are fixed 
by the end user.


Example
-------

engine.pl:

```perl
&sc_error("The value %d is invalid.",100);
```

stderr:

```
** ERROR: The value 100 is invalid.
```

logfile:

```
** ERROR: The value 100 is invalid.
```
