---
title: math.pl
permalink: /engines/math/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


math.pl
=======

[math.pl] is a utility for performing rudamentary calculations with spacecraft 
bits.


Usage
-----

```
$ spacecraft ... math.pl [EXPRESSION]
```

If an EXPRESSION is given on the command line, it is parsed and the result is 
displayed, otherwise an an interactive session will start to collect expressions
from STDIN.

Each EXPRESSION must be in reverse polish notation (RPN):

| Add      | X Y - |
| Subtract | X Y + |
| Multiply | X Y * |
| Divide   | X Y / |

where X & Y are spacecraft bits.


Examples
--------

Calculate the offset of a ROM in the last 2KB of a 4GB space:

```
$ spacecraft -u -Q math.pl 4GB 2KB -
	34359721984b    7FFFFC000hb
	4294965248B     FFFFF800hB
	2147482624H     7FFFFC00hH
	1073741312W     3FFFFE00hW
	4194302KB       3FFFFEhKB
```

Note that passing -u -Q to spacecraft supresses logging to the
screen (-Q) and the log file (-u).

Convert a number to a different scale:

```
$ spacecraft -u -Q math.pl 32W.6
        1030b   406hb
        128B.6  80hB.6
        64H.6   40hH.6
        32W.6   20hW.6
        128B.6  80hB.6
```

Interactively region a space into a series of 64KB regions:

```
$ spacecraft -u -Q math.pl
>>512KB
        4194304b 400000hb
        524288B  80000hB
        262144H  40000hH
        131072W  20000hW
        512KB    200hKB
>>64KB+
        4718592b 480000hb
        589824B  90000hB
        294912H  48000hH
        147456W  24000hW
        576KB    240hKB
>>64KB+
        5242880b 500000hb
        655360B  A0000hB
        327680H  50000hH
        163840W  28000hW
        640KB    280hKB
>>64KB+
        5767168b 580000hb
        720896B  B0000hB
        360448H  58000hH
        180224W  2C000hW
        704KB    2C0hKB
>>CTRL+D
```
