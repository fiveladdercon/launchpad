---
title: html.pl
permalink: /engines/html/
---
[{{page.title}}]: {{site.engine_baseurl}}/{{page.title}}


html.pl
=======

[html.pl] outputs the model as a cross referenced set of HTML files, one HTML 
document per space type.


Usage
-----

```
spacecraft ... html.pl [OUTPUT]
                       [-css STYLESHEET | -link STYLESHEET] 
```

Writes html files to the OUTPUT directory if supplied or the html directory
otherwise.

-R
	: Recursively generate HTML output.

-css STYLESHEET
	: Include the contents of the STYLESHEET in a style block in the
	  HTML document header.

-link STYLESHEET
	: Reference the STYLESHEET with a link tag in the HTML document header
	  and copy the STYLESHEET into the OUTPUT directory.


If no external STYLESHEET is provided with a `-css` or `-link` option, then
a default STYLESHEET will be inserted in a style block in each HTML document.


Example
-------

Generate HTML documentation for a space:

```
$ spacecraft ... html.pl
```
