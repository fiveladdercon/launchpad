---
title: rocketfuel.pl
permalink: /engines/rocketfuel/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


rocketfuel.pl
=============

[rf.pl] outputs the model a set of Rocket Fuel files.


Usage
-----

```
spacecraft ... rocketfuel.pl [OUTPUT] 
                             [-offset FORMAT] 
                             [-size FORMAT]

```

Outputs the model to the OUTPUT directory if defined or the _rocketfuel_ 
directory otherwise.

-offset FORMAT
  	: Report offsets with the number FORMAT provided.
      Defaults to `%U` when not specified.

-size FORMAT
  	: Report offsets with the number FORMAT provided.
      Defaults to `%U` when not specified.


Example
-------

Convert a proprietary format to rocket fuel by writting a custom input engine
then outputing the model in rocket fuel format:

```
$ spacecraft custom_read.pl propretary.reg rocketfuel.pl
```
