---
layout: default
title: sc_add_region API
---


sc_add_region
=============


Prototype
----------

```
$child = $parent->sc_add_region(%options)
```


Parameters
----------

| Parameter  | Type   | M/O | Description                                                         |
|:-----------|:-------|:---:|:--------------------------------------------------------------------|
| `%options` | `hash` | M   | Key/value pairs that specify members of the child region to insert. |

M/O = Mandatory/Optional


Return Type
-----------

`SC_REGION` or `undef`


Description
-----------

Adds a new child region to the parent region or space and returns a `SC_REGION` object if the addition is successful, or `undef` if not.

The `%options` accepted are as follows:

| Option         | Type     | M/O | Description                                                                                                                                                                                                                                                   |
|:---------------|:---------|:---:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-offset`      | `number` | M   | The offset of the child region with respect to the parent region, in bits.                                                                                                                                                                                    |
| `-size`        | `number` | M   | The size of the child region, in bits.                                                                                                                                                                                                                        |
| `-glob`        | `string` | O   | A dimensioned identifier with a single asterisk character `*` that specifies how child names are imported into the parent.  Defaults to `*` when omitted.                                                                                                     |
| `-name`        | `string` | O   | A name unique to the region.  If the glob is dimensioned, the name, if present, should have one `#` character per dimension to specify how the copy instance is uniquely named.  Defaults to `undef` when omitted, meaning the created region is _anonymous_. |
| `-type`        | `string` | O   | A type for the child region.  The type is not loaded if it is refers to a file with further definition; it simply captures the string.  Defaults to `undef` if omitted, making the region _untyped_.                                                          |
| `-description` | `string` | O   | A description of the child region.  Defaults to "" if unspecified.                                                                                                                                                                                            |
| `-filename`    | `string` | O   | The name of the file that contains the definition.  Defaults to undef if omitted and can not be changed afterwards.                                                                                                                                           |
| `-lineno`      | `string` | O   | The line number of the file that contains the definition.  Defaults to 0 if omitted and can not be changed afterwards.                                                                                                                                        |

Note that the order of the options do not matter.

For the addition to be successful:

- All mandatory options must be specified and contain non-empty values;
- The offset & size must be valid numbers;
- The glob must contain valid dimensions if the region is to be dimensioned;
- The name, if present, must contain one dimension placeholder for each dimension if the region is to be dimensioned; and
- The span of the child region must fit within the size of the parent region and not overlap with any other siblings.


Example
-------

```perl
my $region = $space->sc_add_region(
	-offset      => 0,
	-size        => '1MB',
	-name        => 'EXAMPLE_REGION',
	-description => 'This is a region inserted by the API.'
	-filename    => __FILENAME__,
	-lineno      => __LINE__
);
```

This adds a named, untyped 1MB region into the space at offset 0.