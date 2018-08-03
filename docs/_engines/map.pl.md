---
title: map.pl
permalink: /engines/map/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


map.pl
======

[map.pl] outputs named fields and regions in the space in a simple
line based format suitable for diffing and quickly checking the input.


Usage
-----

```
$ spacecraft ... map.pl [-h|--help] [-f|-r] [OUTPUT]
```

Output is sent to STDOUT unless an OUTPUT file is specified.

-f := map only fields. blah blah blah,
    blah, blah blah.

-r :=
	
	map only fields. blah blah blah,
	not lazy.

    blah, blah blah. And
now lazy.

Example
-------

Recursively parse a rocketfuel file and summarize the address map:

* First
* Second
* Third

```
$ cd $SC_LAUNCHPAD/example
$ spacecraft -R soc.rf map.pl 
```