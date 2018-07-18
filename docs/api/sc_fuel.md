---
layout: default
title: sc_fuel API
---


sc_fuel
=======


Prototype
---------

```
$space = &sc_fuel(supply[,%options]);

$space = $region->sc_fuel([supply,%options])
```


Parameters
----------

| Parameter  | Type     | M/O   | Description                                     |
|:-----------|:---------|:-----:|:------------------------------------------------|
| `supply`   | `string` |  M/O  | A type or file with definitions of a space.     |
| `%options` | `hash`   |  O    | See options below.                              |

M/O = Mandatory/Optional


Return Type
-----------

`SC_SPACE`


Description
-----------

**sc_fuel** loads field and region definitions from a **supply** and returns them 
in a space.

A **supply** is either specified as a *type* or a *file*.  If it specified as a 
file, the type is set to the basename of the file.  If it is specified as a type, 
the fuel supply list is searched for a matching file.  See [sc_fuel_supply](sc_fuel_supply)
for details on finding a supply file from a supply type.

If the supply type has not been previously loaded, the supply file is parsed into
a space and returned.

If the supply type has been previously loaded, the previously loaded space is 
returned.

The **sc_fuel** API may be called as a function or as a region method.

If called as a region method:

The `supply` may be omitted, in which case the region must have a type, as the
region type is used as the supply type. 

Furthermore if the region has no children when **sc_fuel** is called, the region 
is populated with the definitions in the space by calling [sc_set_children](sc_set_children)
under the hood.

The **sc_fuel** API may be called with the following options in either context:

| Option       | Type      | M/O | Description                                          |
|:-------------|:----------|:---:|:-----------------------------------------------------|
| `-recursive` | `boolean` |  O  | Recursively load typed regions.                      |
| `-embedded`  | `boolean` |  O  | Search for embedded definitions in .v and .sv files. |


Example
-------

```perl
$space = &sc_get_space();

$space->sc_fuel("chip.rf", -recursive => 1);
```

Here the top level space is recursively loaded from the "chip.rf" file.  

This is equivalent to the following command line:

```
$ spacecraft -R chip.rf ...
```


```perl
$chip = &sc_get_space();

$macro = &sc_fuel("macro");

$chip->sc_add_region(-offset => '0KB, -size => '8KB', -name => 'MX')->sc_set_children($macro);
$chip->sc_add_region(-offset => '8KB, -size => '8KB', -name => 'MY')->sc_set_children($macro);
```

Here we do some bottom up construction, where the `$macro` definition is loaded
from the "macro" type (assuming macro.rf can be found) and added to the chip
as two different instances.

This is equivalent to the following chip.rf:

```
0KB 8KB MX macro;
8KB 8KB MY macro;
```






