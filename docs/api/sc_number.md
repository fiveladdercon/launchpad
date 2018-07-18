---
layout: default
title: sc_number API
---


sc_number
=========


Prototype
---------

```
$number = &sc_number(format,number)
```


Parameters
----------

| Parameter | Type     | M/O | Description                                    |
|:----------|:---------|:---:|:-----------------------------------------------|
| `format`  | `string` |  M  | The output format of the number.               |
| `number`  | `number` |  M  | The number to format.                          |

M/O = Mandatory/Optional


Return Type
-----------

`number`


Description
-----------

**sc_number** reformats spacecraft fixed point numbers using a printf style 
format string.

| Format | Description               |
|:------:|:--------------------------|
| `%d`   | Unitless decimal bits     |
| `%b`   | Decimal bits              |
| `%B`   | Decimal Bytes             |
| `%H`   | Decimal Halfwords         |
| `%W`   | Decimal Words             |
| `%D`   | Decimal Doublewords       |
| `%U`   | Decimal scaled Bytes      |
| `%hb`  | Hexadecimal bits          |
| `%hB`  | Hexadecimal Bytes         |
| `%hH`  | Hexadecimal Halfwords     |
| `%hW`  | Hexadecimal Words         |
| `%hD`  | Hexadecimal Doublewords   |
| `%hU`  | Hexadecimal scaled Bytes  |

The same number is formatted multiple times if the format string has
multiple specifiers, which allows quick and easy comparison.

Unrecognized specifiers are passed through unmodified.


Example
-------

```perl
printf &sc_number("%b = %B = %H = %W = %D\n",313);
```

This will output

```
313b = 39B.1 = 19H.9 = 9W.25 = 4D.57
```
