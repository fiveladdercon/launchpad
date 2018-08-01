---
title: rf.pl
permalink: /engines/rf/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


rf.pl
=====

[rf.pl] outputs the space in rocketfuel format.


Usage
-----

```
spacecraft ... rf.pl [-h|--help] [-R] OUTPUT
```


Example
-------

Convert a proprietary format to rocketfuel format:

```
$ spacecraft proprietary.pl rf.pl output
```

Here the `proprietary.pl` engine would use the EngineAPI to construct the 
space from the proprietary format and then the `rf.pl` engine would write
it out in rocketfuel format, completing the conversion.
