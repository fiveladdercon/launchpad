---
layout: default
permalink: /status
---

> As of October 9th, 2018, the Spacecraft project is being shelved - not because
> I want to stop working on it, but because my new employer will not exempt the
> project from their NDA that I must sign on that date.  Since my work on 
> Spacecraft may fall under the NDA, I'd rather park the project than have it 
> expropriated.


Spacecraft Status
=================

Spacecraft has three components in various stages of development:

1. The spacecraft executable, which hosts the model, implements the EngineAPI, 
   reads [Rocket Fuel][1] and executes engines;
2. The open source library of engines; and
3. The open source documentation.


spacecraft
----------

The spacecraft executable is **complete** and is distributed with the 
library of engines and documenation on [github][2].  It is thoroughly tested 
and currently usable as is, assuming it [installs][3] correctly.  The API listed 
is complete and tested, even if it's documentation is not.

The spacecraft executable only operates at full speed when a BOOSTER file is 
installed in the local `$SC_LAUNCHPAD` directory.  Presently there is no system 
in place to accept payments for BOOSTER files, so I can only generate short term
trial BOOSTER files on request.  To request a trial BOOSTER, send your name, 
email & company to fiveladdercon[at]gmail.com.

[1]: /fuel/
[2]: https://github.com/fiveladdercon/launchpad
[3]: /install


Engine Library
--------------

The library of open source engines is a work in progress:

| Engine          | Code        | Test Suite       |
|:----------------|:------------|:-----------------|
| [data.pl]       | Complete    | Complete         |
| [defines.pl]    | Complete    | Needs grid tests |
| [filter.pl]     | Complete    | Complete         |
| [html.pl]       | Templated   | Templated        |
| [json.pl]       | Complete    | Complete         |
| [logical.pl]    | Complete    | Templated        |
| [map.pl]        | Complete    | Complete         |
| [math.pl]       | Complete    | Missing          |
| [pack.pl]       | Complete    | Templated        |
| [rocketfuel.pl] | Complete    | Complete         |
| [structs.pl]    | Templated   | Templated        |
| [uvm.pl]        | Templated   | Templated        |
| [verilog.pl]    | In Progress | Templated        |

[data.pl]:       /engines/data/
[defines.pl]:    /engines/defines/
[filter.pl]:     /engines/filter/
[html.pl]:       /engines/html/
[json.pl]:       /engines/json/
[logical.pl]:    /engines/logical/
[map.pl]:        /engines/map/
[math.pl]:       /engines/math/
[pack.pl]:       /engines/pack/
[rocketfuel.pl]: /engines/rocketfuel/
[structs.pl]:    /engines/structs/
[uvm.pl]:        /engines/uvm/
[verilog.pl]:    /engines/verilog/


Documentation
-------------

The open source documentation is a work in progress:

| Page                            | Status                                                                   |
|:--------------------------------|:-------------------------------------------------------------------------|
| [/]()                           | Complete                                                                 |
| [/intro]()                      | Complete                                                                 |
| [/install]()                    | Complete                                                                 |
| [/cli]()                        | Complete                                                                 |
| /access/                        | **Need a discussion on access systems and access system parameters.**    |
| [/model/]()                     | Missing diagrams. Needs space as type, region as instance clarification. |
| [/model/logic]()                | Notes only.  Needs details why different types regions are added.        |
| [/fuel/]()                      | Missing diagrams. Needs review - check comment delimiters in examples.   |
| [/fields/RO]()                  | Incomplete                                                               |
| [/fields/RW]()                  | Incomplete                                                               |
| [/fields/]()                    | Needs more detail on [verilog.pl] classes for custom fields.             |
| [/engines/data/]()              | Complete                                                                 | 
| [/engines/defines/]()           | Needs grid section                                                       | 
| [/engines/filter/]()            | Complete                                                                 |
| [/engines/html/]()              | Scoped                                                                   |
| [/engines/json/]()              | Complete                                                                 |
| [/engines/logical/]()           | Needs as-built update                                                    |
| [/engines/map/]()               | Complete                                                                 |
| [/engines/math/]()              | Complete                                                                 |
| [/engines/pack/]()              | Complete                                                                 |
| [/engines/rocketfuel/]()        | Complete                                                                 |
| [/engines/structs/]()           | Scoped                                                                   |
| [/engines/uvm/]()               | Scoped                                                                   |
| [/engines/verilog/]()           | In progress                                                              |
| [/engines/]()                   | Missing utility APIs                                                     |
| [/api/sc_get_space]()           | Complete                                                                 |
| [/api/sc_get_address]()         | Complete                                                                 |
| [/api/sc_get_identifier]()      | Templated                                                                |
| [/api/sc_get_dimensions]()      | Templated                                                                |
| [/api/sc_get_offset]()          | Templated                                                                |
| [/api/sc_get_size]()            | Templated                                                                |
| [/api/sc_get_span]()            | Templated                                                                |
| [/api/sc_get_glob]()            | Templated                                                                |
| [/api/sc_get_value]()           | Templated                                                                |
| [/api/sc_get_name]()            | Templated                                                                |
| [/api/sc_get_type]()            | Templated                                                                |
| [/api/sc_get_description]()     | Templated                                                                |
| [/api/sc_get_children]()        | Templated                                                                |
| [/api/sc_get_property]()        | Templated                                                                |
| [/api/sc_get_dimension_label]() | Templated                                                                |
| [/api/sc_get_dimension_from]()  | Templated                                                                |
| [/api/sc_get_dimension_to]()    | Templated                                                                |
| [/api/sc_get_dimension_size]()  | Templated                                                                |
| [/api/sc_get_dimension_count]() | Templated                                                                |
| [/api/sc_get_dimension_span]()  | Templated                                                                |
| [/api/sc_get_dimension]()       | Templated                                                                |
| [/api/sc_get_filename]()        | Templated                                                                |
| [/api/sc_get_lineno]()          | Templated                                                                |
| [/api/sc_set_offset]()          | Complete                                                                 |
| [/api/sc_set_size]()            | Complete                                                                 |
| [/api/sc_set_span]()            | Complete                                                                 |
| [/api/sc_set_glob]()            | Complete                                                                 |
| [/api/sc_set_value]()           | Complete                                                                 |
| [/api/sc_set_name]()            | Complete                                                                 |
| [/api/sc_set_type]()            | Complete                                                                 |
| [/api/sc_set_description]()     | Complete                                                                 |
| [/api/sc_set_children]()        | Templated                                                                |
| [/api/sc_set_property]()        | Complete                                                                 |
| [/api/sc_set_dimension_label]() | Complete                                                                 |
| [/api/sc_set_dimension_from]()  | Complete                                                                 |
| [/api/sc_set_dimension_to]()    | Complete                                                                 |
| [/api/sc_set_dimension_size]()  | Complete                                                                 |
| [/api/sc_is_space]()            | Templated                                                                |
| [/api/sc_is_region]()           | Templated                                                                |
| [/api/sc_is_field]()            | Templated                                                                |
| [/api/sc_is_named]()            | Templated                                                                |
| [/api/sc_is_typed]()            | Templated                                                                |
| [/api/sc_is_first_child]()      | Templated                                                                |
| [/api/sc_is_last_child]()       | Templated                                                                |
| [/api/sc_has_properties]()      | Templated                                                                |
| [/api/sc_has_property]()        | Templated                                                                |
| [/api/sc_has_children]()        | Templated                                                                |
| [/api/sc_get_parent]()          | Templated                                                                |
| [/api/sc_get_next_child]()      | Templated                                                                |
| [/api/sc_get_next_property]()   | Complete                                                                 |
| [/api/sc_get_next_dimension]()  | Complete                                                                 |
| [/api/sc_add_region]()          | Complete                                                                 |
| [/api/sc_add_field]()           | Complete                                                                 |
| [/api/sc_unset]()               | Complete                                                                 |
| [/api/sc_unset_property]()      | Complete                                                                 |
| [/api/sc_unset_children]()      | Templated                                                                |
| [/api/sc_bits]()                | Templated                                                                |
| [/api/sc_dimensions]()          | Templated                                                                |
| [/api/sc_import]()              | Templated                                                                |
| [/api/sc_detach]()              | Complete                                                                 |
| [/api/sc_reattach]()            | Complete                                                                 |
| [/api/sc_unroll]()              | Templated                                                                |
| [/api/sc_reroll]()              | Templated                                                                |
| [/api/sc_fuel]()                | Complete                                                                 |
| [/api/sc_fuel_supply]()         | Templated                                                                |
| [/api/sc_note]()                | Complete                                                                 |
| [/api/sc_warn]()                | Complete                                                                 |
| [/api/sc_error]()               | Complete                                                                 |
| [/api/sc_fatal]()               | Complete                                                                 |
| [/contribute/]()                | Complete                                                                 |
| [/about/]()                     | Not bad.  Maybe a section on fiveladdercon.                              |