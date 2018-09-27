---
title: json.pl
permalink: /engines/json/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


json.pl
=======

[json.pl] outputs the model in JSON format suitable for use in an HTML viewing
application.

Note that despite being a hierarchical format, region type information is lost
in the conversion.


Usage
-----

```
spacecraft ... json.pl [OUTPUT]
```

Outputs the model to the supplied OUTPUT file or _space type_.json otherwise.


Example
-------

Output a packed logical model in JSON format:

```
$ spacecraft ... logical.pl pack.pl json.pl
```

See [logical.pl](/engines/logical/) and [pack.pl](/engines/pack/).