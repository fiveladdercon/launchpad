---
title: pack.pl
permalink: /engines/pack/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


pack.pl
=======

[pack.pl] "packs" the model into a single file for transmission to a customer, 
which they can then "unpack" into a set of files.

The engine works by "moving" region types into **pack** properties and vice-versa.


Usage
-----

```
spacecraft ... pack.pl ...
```


Properties
----------

pack
  : The **pack** property stores the region type while the model is packed.
    It is not intended to be added by hand, but is instead temporary storage
    used by the [pack.pl] engine.


Example
-------

To pack the model into a single file for shipment to a customer:

```
$ spacecraft -R soc.rf pack.pl rocketfuel packed
```

This will transform several recursively loaded files into a single `packed/soc.rf`
file that can be shipped to the customer.

The customer can then unpack the model back into the set of files:

```
$ spacecraft packed/soc.rf pack.pl rocketfuel unpacked
```

Note that the [pack.pl] engine is used to both pack and unpack the model, so 
that the following does not change the model:

```
$ spacecraft -R soc.rf pack.pl pack.pl rocketfuel.pl unpacked
```

