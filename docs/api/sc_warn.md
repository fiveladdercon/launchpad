---
layout: default
title: sc_warn API
---


sc_warn
=======


Prototype
---------

```
&sc_warn(format,...)
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

The `sc_warn` utility function unifies logging between engines and spacecraft,
creating a single log file that spans all engines.

Warnings are printed to `stderr` in yellow, logged and counted, but 
processing continues.


Example
-------

engine.pl:

```perl
&sc_warn("The value %d seems strange.",100);
```

stderr:

```
** WARN : The value 100 seems strange.
```

logfile:

```
** WARN : The value 100 seems strange.
```
