---
layout: default
title: sc_add_field API
---


sc_add_field
============


Prototype
----------

```
$field = $region->sc_add_field(%options);
```


Parameters
----------

| Parameter  | Type   | M/O | Description                                                         |
|:-----------|:-------|:---:|:--------------------------------------------------------------------|
| `%options` | `hash` | M   | Key/value pairs that specify members of the child region to insert. |

M/O = Mandatory/Optional


Return Type
-----------

`SC_FIELD` or `undef`


Description
-----------

Adds a new child region to the parent region or space and returns a `SC_REGION` object if the addition is successful, or `undef` if not.

The `%options` accepted are as follows:

| Option         | Type      | M/O | Description                                                                                                                                                                                                                                                   |
|:---------------|:----------|:---:|:-------------------------------------------------------------------------------------------------------------------------|
| `-offset`      | `number`  | M   | The offset of the field with respect to the parent region, in bits.                                                      |
| `-size`        | `number`  | M   | The size of the field, in bits.                                                                                          |
| `-value`       | `string`  | M   | A default value for the field.                                                                                           |
| `-name`        | `string`  | M   | A name for the field.  The name should be unique.                                                                        |
| `-type`        | `string`  | M   | A type of the field.                                                                                                     |
| `-description` | `string`  | O   | A description of the field.  Defaults to "" if unspecified.                                                              |
| `-filename`    | `string`  | O   | The name of the file that contains the definition.  Defaults to undef if omitted and can not be changed afterwards.      |
| `-lineno`      | `string`  | O   | The line number of the file that contains the definition.  Defaults to 0 if omitted  and can not be changed afterwards.  |

Note that the order of the options do not matter.

For the addition to be successful:

- All mandatory options must be specified and contain non-empty values;
- The offset & size must be valid numbers;
- The name must contain valid dimensions if the field is to be dimensioned; and
- The span of the field must fit within the size of the parent region and not overlap with any other siblings.


Example
-------

```perl
my $field = $region->sc_add_field(
	-offset      => 65,      # i.e. 2W.1
	-size        => '3b',
	-value       => '7h',
	-name        => 'EXAMPLE_FIELD',
	-description => 'This field was inserted from the API.'
	-filename    => __FILE__,
	-lineno      => __LINE__
);
```

This adds a 3 bit field to the region at offset 2W.1.


Errors