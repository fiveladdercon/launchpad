---
layout: default
title: Custom Engines & The EngineAPI
permalink: /engines/
---

[model]:    /model/
[bit]:      /fuel/#bits
[bits]:     /fuel/#bits
[space]:    /model/#spaces
[spaces]:   /model/#spaces
[region]:   /model/#region
[regions]:  /model/#region
[field]:    /model/#field
[fields]:   /model/#field
[property]: /model/#properties

[1]:(http://www.perl.org)
[Rocket Fuel]: /fuel/


Custom Engines & The EngineAPI
==============================

An **engine** is a [Perl][1] script that uses the **EngineAPI** package to access 
the spacecraft memory resident [model].


Hello World
-----------

You can create an engine anywhere, as an engine is just a [Perl][1] script:

```
$ touch hello.pl
```

And then execute it with spacecraft:

```
$ spacecraft hello.pl
** NOTE : Firing engine hello.pl.
** NOTE : Engine hello.pl finished in 0.001364661 seconds.
** NOTE : Finished in 0.004851019 seconds with 0 warnings, 0 errors.
```

To turn the script into an engine, you must include the **EngineAPI**:

```perl
use EngineAPI;

&sc_note(0,"Hello World!");
```

Now when you execute, you're hooked into spacecraft:

```
$ spacecraft hello.pl
** NOTE : Firing engine hello.pl.
** NOTE : Hello World!
** NOTE : Engine hello.pl finished in 0.009796026 seconds.
** NOTE : Finished in 0.013642397 seconds with 0 warnings, 0 errors.
```

The first step is generally to get a handle to the memory resident [model] using 
the **[sc_get_space](/api/sc_get_space)** API:

```perl
use EngineAPI;

# Get a handle to the model:
my $space = &sc_get_space();

# And use the object oriented methods:
&sc_note(0,"Hello %s!", $space->sc_get_type);
```

Now when you execute, you've dereferenced the [model].  But since you've started 
from a blank canvas, the space doesn't even have a type!

```
$ spacecraft hello.pl
** NOTE : Firing engine hello.pl.
** NOTE : Hello !
** NOTE : Engine hello.pl finished in 0.009796026 seconds.
** NOTE : Finished in 0.013642397 seconds with 0 warnings, 0 errors.
```

To see the power of the memory resident [model], let's create another script:

```
$ touch world.pl
```

With the following in it:

```perl
use EngineAPI;

my $space = &sc_get_space();

$space->sc_set_type("World");
```

Now when you execute, execute **both** engines!  First the `world.pl` engine
to construct the model, then the orignal `hello.pl` engine to output the
model:

```
$ spacecraft world.pl hello.pl
** NOTE : Firing engine world.pl.
** NOTE : Engine world.pl finished in 0.009658130 seconds.
** NOTE : Firing engine hello.pl.
** NOTE : Hello World!
** NOTE : Engine hello.pl finished in 0.006746967 seconds.
** NOTE : Finished in 0.020468362 seconds with 0 warnings, 0 errors.
```

Notice how the `hello.pl` now reports the type set in `world.pl` -- the
[model] is passed between the scripts and you've separated model construction
from model output!

You can always construct the [model] with the EngineAPI -- and you'd do this 
when you need to convert an existing format -- but it's easier to describe the 
model in [Rocket Fuel] and load it that way.

So let's try adding some [Rocket Fuel] and executing again:

```
$ touch World.rf
$ spacecraft World.rf hello.pl
** NOTE : Parsed World.rf in 0.000246411 seconds. Found 0 regions and 0 fields.
** NOTE : Firing engine hello.pl.
** NOTE : Hello World!
** NOTE : Engine hello.pl finished in 0.010435138 seconds.
** NOTE : Finished in 0.014355259 seconds with 0 warnings, 0 errors.
```

And voila, you've loaded the space defined in the World.rf [Rocket Fuel] and
have a handle to it in your engine.

Now it's a matter of using the EngineAPI to do what ever cool stuff you 
need to do with your definitions -- including converting them to [Rocket Fuel]!

If at some point your engines become useful for more than just you, you can 
promote them to your local launchpad.  If you do go that far, consider 
following the instructions for [contributing](/contribute/), because you may 
at some point decide your engine is good for the rest of us.


Working with Bits
-----------------

Because the [Rocket Fuel] fixed point numbering notation for working with 
spacecraft [bits] is not part of the Perl language<sup>a</sup>, the EngineAPI 
interface uses Perl strings to exchange the `sc_bit` type.  That is, when you 
see the `sc_bit` type in the EngineAPI, think of it as string holding a 
spacecraft fixed point [bit] number, not as a number.  For example:

```perl
$offset = "64";
$size   = 32;
```

Here the `$offset` is a valid `sc_bit` because it is a string, while the `$size`
is not because it is an integer.  To keep it straight, just keep in mind that
a bare `sc_bit` in perl is a syntax error:

```perl
$size = 32KB;  # Not valid perl
```

<hr class="sc_footnote">
<small>
(a) yet, at least for the version embedded in spacecraft.
</small>



Working with Spaces, Regions and Fields
---------------------------------------

The spacecraft [model] -- which is a hierarchy of [regions] within a 
[space] -- is accessible inside an engine as a hierarchy of Perl objects.

At the top of the hierarchy is a singleton instance of a [space] object
that is shared between engines.  To get a handle to the [space] inside 
the engine, you use the `sc_get_space` function:

```perl
my $space = &sc_get_space();
```

A [space] is a [region] and a [region] is a **node**.  

A [field] is also a **node**.

This leads to the following **inheritance hierarchy**<sup>a</sup> in the 
EngineAPI:

```
 ┌─────────┐
 │  node   │
 └────┬────┘
      ├────────────┐
 ┌────┴────┐  ┌────┴────┐
 │ region  │  │  field  │
 └────┬────┘  └─────────┘
      │
 ┌────┴────┐
 │  space  │
 └─────────┘
```
##### FIGURE 1: Inheritance hierarchy #####
<hr class="sc_footnote">
<small>
  (a) not to be confused with the **instance hierarchy** actually mapped by 
  the [space].
</small>



### Get Methods ###

All nodes have the following `sc_get_*` methods to access the data members:

```perl
print $node->sc_get_address();
print $node->sc_get_identifer();
print $node->sc_get_offset();
print $node->sc_get_name();
print $node->sc_get_size();
print $node->sc_get_span();
print $node->sc_get_type();
print $node->sc_get_description();
print $node->sc_get_property($key);
print $node->sc_get_filename();
print $node->sc_get_lineno();
```

But only [regions] have globs:

```perl
print $region->sc_get_glob();
```

And only [fields] have values:

```perl
print $field->sc_get_value();
```

Note: 

* that the address & identifier is relative to the [space], while the offset
  and name is relative to the parent node; 
* that the type and name of a [region] are optional and may be `undef`; and 
* that the span will be the same as the size if the node is not dimensioned.



### Set Methods ###

All nodes have the following `sc_set_*` methods to set the data members:

```perl
$node->sc_set_offset($offset)           or &sc_error("set failed");
$node->sc_set_size($size)               or &sc_error("set failed");
$node->sc_set_name($name)               or &sc_error("set failed");
$node->sc_set_type($type)               or &sc_error("set failed");
$node->sc_set_description($description) or &sc_error("set failed");
$node->sc_set_property($key,$value)     or &sc_error("set failed");
```

And again only [regions] have globs:

```perl
$region->sc_set_glob($glob) or &sc_error("set failed");
```

and only [fields] has values:

```perl
$field->sc_set_value($value) or &sc_error("set failed");
```

The `sc_set_*` methods return `1` if the set is successful and `0` otherwise.  A
set can fail for a number of reasons, depending on what is being set.  For
example, changing an offset may cause the node to overlap with a sibling or 
extend past the end of it's parent.  If a set fails, an error is issued and
the node is unchanged.

Note that you can't directly set the address or identifier.  That's because they
are calculated values that depend on the offset and name of a node _and_ the 
node's place in the hierarchy of [regions].

Also note that you can't set the filename & lineno because they are read-only.



### Test Methods ###

All nodes have the following `sc_has_*` or `sc_is_*` methods to test whether
an aspect of the node is true or false:

```perl
print "true" if $node->sc_is_space();          
print "true" if $node->sc_is_region();         
print "true" if $node->sc_is_field();          
print "true" if $node->sc_is_named();          
print "true" if $node->sc_is_typed();          
print "true" if $node->sc_is_first_child();          
print "true" if $node->sc_is_last_child();          
print "true" if $node->sc_has_properties();     
print "true" if $node->sc_has_property($key);  
print "true" if $node->sc_has_dimensions();    
print "true" if $node->sc_has_children();      
```



### Iteration Methods ###

As the [space] is a hierarchy of [regions], all nodes have the following
methods to sequentially traverse the hierarchy.

To iterate bottom-up from child to parent, use `sc_get_parent`:

```perl
while ($parent = $child->sc_get_parent()) {
	...
}
```

And to iterate top-down from parent to each child, use `sc_get_next_child`:

```perl
while ($child = $parent->sc_get_next_child()) {
   ...
}
```

Note that as [fields] do not have children, calling `sc_get_next_child` on
a [field] will return `undef`. This terminates the `while` loop before it 
starts and results in the desired behaviour.



### Working with Properties ###

Each node can have a set of properties and each property is a key/value pair.

To check if the node has any properties:

```perl
$node->sc_has_properties();  # returns 1 if $node has any properties
```

To check if the node has a specific property:

```perl
$node->sc_has_property($key);  # returns 1 if $node has property $key
```

To get the value of the specific property:

```perl
$value = $node->sc_get_property($key);
```

To update the value of an existing property or to add a new property:

```perl
$node->sc_set_property($key);  
# - OR -
$node->sc_set_property($key,$value);
```

Note that a node can have a property that has no value (or a value of `undef`)
because in some cases the existence or non-existence of a property is sufficient 
information.  This capability introduces a couple of things to consider.

The first thing to consider is that the `sc_get_property` returns the property 
value and will return `undef` both when the property does not exist and when the 
property does not have a value.  Hence you can not safely use `sc_get_property` 
to test for the existence of a property, since it will return falsy when the 
value is `undef`.  For existence checking you must use `sc_has_property`.

For example, the following snippet:

```perl
$node->sc_set_property("exists");
print "exists\n" if $node->sc_get_property("exists");  # does not print
print "exists\n" if $node->sc_has_property("exists");  # prints
```

will print only once because the `sc_get_property` returns the value `undef`, 
which is falsy, while the `sc_has_property` returns truthy because it looks at 
the existence of the key, not the value.

The second thing to consider is that setting the value to `undef` does not
remove the property.  It simply turns the property into an existence boolean.
To remove the property, you must use the `sc_unset_property` method.

```perl
$node->sc_set_property("key","value");
print "exists\n" if $node->sc_has_property("key");  # prints

$node->sc_set_property("key");
print "exists\n" if $node->sc_has_property("key");  # prints

$node->sc_unset_property("key");
print "exists\n" if $node->sc_has_property("key");  # does not print
```

Lastly, you can loop through the list of properties on a node with the
`sc_get_next_property` method:

```perl
while ($key = $node->sc_get_next_property()) {
	$value = $node->sc_get_property($key);
	print $value ? "$key = $value\n" : "$key";
}
```



### Working with Dimensions ###

Dimensions are a concise way to represent adjacent copies of a node, but with
power comes responsibility.  Dimensions transform redundancy in the definition
into complexity in the engine.  This is particularly true when nodes have 
multiple dimensions at multiple levels in the hierarchy.

All nodes can have zero or more dimensions.

To test where a node has any dimensions, use the `sc_has_dimensions` method:

```perl
$node->sc_has_dimensions();  # returns truthy if $node has any dimensions
```

To test how many dimensions a node has, use the `sc_get_dimensions` method:

```perl
print $node->sc_get_dimensions();  # returns N, the number of dimensions of $node
```

To iterate through the list of dimensions, if any, use the `sc_get_next_dimension`
method:

```perl
while ($dim = $node->sc_get_next_dimension()) {
	...
}
```

Here the `$dim` variable returned is just the dimension number, and since
dimensions are numbered starting from 1, the loop will iterate through the
dimensions then return a 0 to terminate the loop.

To get the data member for a given dimension, use the `sc_get_dimension_*` 
methods:

```perl
$node->sc_get_dimension_label($dim);
$node->sc_get_dimension_from($dim);
$node->sc_get_dimension_to($dim);
$node->sc_get_dimension_size($dim);
$node->sc_get_dimension_span($dim);
$node->sc_get_dimension_count($dim);
````

To set the data member for a given dimension, use the `sc_set_dimension_*` 
methods:

```perl
$node->sc_set_dimension_label($dim,$label) or &sc_error("set failed");
$node->sc_set_dimension_from($dim,$from)   or &sc_error("set failed");
$node->sc_set_dimension_to($dim,$to)       or &sc_error("set failed");
$node->sc_set_dimension_size($dim,$size)   or &sc_error("set failed");
```

The `sc_set_dimension_*` methods behave like the rest of the `sc_set_*` methods,
returning `1` when the set is successful, and otherwise returning `0` having 
left the dimension unchanged.  Setting the dimension size, for example, to a 
value less than the node size, will cause the set to fail.

Note that you can't set the span and count as these are calculated values.

Also note that you can only get/set dimensions that exist, and passing an
invalid dimension number will issue a warning and have no effect.

Quite often an engine is assembling a dimension into a formatted string, which
makes the `sc_get_dimension_*` methods cumbersome.  To lighten the burden, you 
can use the `sc_get_dimension` method instead:

```perl
$node->sc_get_dimension($dim,$dimformat);
```

Where the `$dimformat` is a printf-like format string with % specifiers that
extract dimension data members.  For example:

```perl
# Assume label = 'x', from = 1, to = 3, snapping size

$node->sc_get_dimension(1,"%v");  # returns "[x:1:3]", the dimension vector
```

See the [sc_get_dimension](/api/sc_get_dimension) API for details.

To convert between unrolled & rolled representations, use the `sc_unroll`
and `sc_reroll` APIs:

```perl
$node->sc_unroll();
$node->sc_reroll();
```

Note that these methods only make sense for nodes declared or constructed with 
dimensions and they have no effect on non-dimensioned nodes.  Also note that
this implies the initial state is rolled, which means you will always unroll
first.



### Working with Hierarchy ###


In addition to the iterative methods, the following two APIs are provided
for working with hierarchy:

```perl
$space = $region->sc_detach();
$space->sc_reattach();
```

The `sc_detach` API moves all children from a region into a new separate 
space, leaving the origininal region childless, while the `sc_reattach`
reverts the change.

For example, suppose we decide to instantiate two instances of a particular
module:

```
0KB  8KB  EAST  EAST_* module;
8KB  8KB  WEST  WEST_* module;
```

If we run this through a documentation engine, we'll get all `EAST_*` fields 
followed by all `WEST_*` fields.  This is comprehensive but repetative.

A better approach is to the document the module type, then document the 
instances with cross references to the the type.  This is done by detaching the 
space from the region, reruning the engine on the detached space, then 
reattaching the space:

```
sub subspaces {
  my $region = shift;
  my $list   = shift; $list = {} unless defined $list;

  while (my $node = $region->sc_get_next_child) {
    if ($node->sc_is_region) {
      my $type = $node->sc_get_type;
      if ($type) {
        #
        # Detach the space from the region and a copy of the type
        #
        $list->{$type} = $node->sc_detach unless $list->{$type};
      } else {
        &subspaces($node,$list);  
      }
    }
  }
  return $list;
}

my $space  = &sc_get_space
my $linked = &subspaces($space);

# Document the space
&document($space);

# Document the linked sub-spaces
foreach my $type (sort keys %{$linked}) {
  &document($linked->{$type});
  #
  # Reattach the detached space back into the model
  #
  $linked->{$type}->reattach;
}
```



Fueling
-------

Though [Rocket Fuel](/fuel/) can be passed on the [spacecraft command line](/cli/),
it doesn't have to be and the model and be fueled through the API:

```perl
# Get the (empty) space
$space = &sc_get_space();

# Add "path" to the fuel supply (search list)
&sc_fuel_supply("path");

# Read the type (.rf file) into the space
$space->sc_fuel("type");    
```

which is equivalent to:

```
$ spacecraft -R -I path type.rf
```

but stores it in an engine.  This can be a handy way to manage a long list of 
fuel supplies rather than passing them on the command line each time.

Though the previous example loaded the entire space, the fueling API can be
used to fuel regions as well:

```perl
# Get the (empty) space
$space = &sc_get_space();

# Add a region
my $region = $space->sc_add_region(-offset => '0KB', -size => '8KB');

# Fuel the region fromt the "type.rf" file
$region->sc_fuel("type.rf");
```

The fueling API also supports the instantiation of a region type:

```perl
# Get the (empty) space
$space = &sc_get_space();

# Add some regions
my $east = $space->sc_add_region(
  -offset => '0KB', 
  -size   => '8KB', 
  -name   => 'EAST',
  -glob   => 'EAST_*'
  );

my $west = $space->sc_add_region(
  -offset => '8KB', 
  -size   => '8KB', 
  -name   => 'WEST',
  -glob   => 'WEST_*'
  );

# Load a region "type"
my $module = &sc_fuel("module.rf");

# Instantiate the type
$east->sc_set_children($module);
$west->sc_set_children($module);
```

Note that the same definition ($module) is used twice.



Mission Control
---------------

Engines have access to the logging system of spacecraft using the following
printf-like functions:

```perl
&sc_note($level,"Just %s","information");
&sc_warn("Possible issue");
&sc_error("User issue");
&sc_fatal("Engine issue");
```


Utilities
---------

```perl
&sc_bits();
&sc_dimensions();
&sc_import();
```




Engine Patterns
===============

Most **output engines** follow a very simple pattern that recursively traverses
the hierarchy of regions:

```perl
#
# Include the EngineAPI
#
use EngineAPI;

#
# Declare a function that works on one region at a time
#
sub work_on {
	my $region = shift;

	# iterate through all children in the region:

	while ($child = $region->sc_get_next_child) {

		if ($child->sc_is_field) {

			# do something useful with the field

		} else {

			# recursively work on the child region

			&work_on($child);
		}

	}
}

#
# Pass the space as the initial region
#
&work_on(&sc_get_space());
```

