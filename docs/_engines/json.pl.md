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
in the conversion of instances.


Usage
-----

```
spacecraft ... json.pl [-space NUMBER] [OUTPUT]
```

Outputs the model to the supplied **OUTPUT** file or **STDOUT** otherwise.

-s NUMBER, --space NUMBER
  : Specifying a **NUMBER** greater than 0 will pretty print the JSON similar
    to the **space** argument to the JSON.stringfy function.


Example
-------

Output a packed logical model in pretty printed JSON format:

```
$ spacecraft ... logical.pl pack.pl json.pl -space 4
```

See [logical.pl](/engines/logical/) and [pack.pl](/engines/pack/).