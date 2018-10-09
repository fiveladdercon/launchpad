---
layout: default
title: Contributing
permalink: /contribute
---


Contributing to Spacecraft
==========================

Do you think others would use your engine?  If so, you need to hook into the
distribution system to put it out there.


Local Contributions
-------------------

The easiest way of making your engine available to your local team is to simply 
copy your engine into the `$SC_LAUNCHPAD/engines` directory of your team's
installation:

```
$ cp fantastic_engine.pl $SC_LAUNCPAD/engines
```

Your engine will now execute without a path for everyone on the team:

```
$ spacecraft fantastic_engine.pl ...
```

but you're on your own for letting people know about it.

Another way is to build engines like they belong in the distribution in the
first place.

To set up your local environment:

```
$ cd $SC_LAUNCHPAD
$ source setup
┌───────────────────────────────────────────────────────────────────────────────────┐
│ SPACECRAFT LAUNCHPAD                                                              │
├───────────────┬───────────────────────────────────────────────────────────────────┘
│ $SC_LAUNCHPAD │ /path/where/you/sourced/the/setup/file
│ COMMANDS      │ create : Create a new engine from the template.
│               │ host   : Locally host the documentation.
│               │ run    : Run a test or suite.
└───────────────┴────────────────────────────────────────────────────────────────────
```

#### Create

If you use the `create` command, it will add a new engine to the local launchpad 
by creating the engine, it's documentation and a test suite from the template:

```
$ create example
Creating $SC_LAUNCHPAD/engines/example.pl
Creating $SC_LAUNCHPAD/docs/_engines/example.pl.md
Creating $SC_LAUNCHPAD/tests/example.pl/
```

#### Run

If you go into the test directory for your newly created engine, you can use the
`run` command to execute the test suite:

```
$ cd tests/example.pl
$ run

  example.pl
    ✓ is documented

  ✓ 1 test complete

```
  
The test will pass, but only because your engine does nothing. The point is that
now you are in a working directory where you can add files to stimulate your 
engine as you write it:

```
$ touch test.rf
$ spacecraft test.rf example.pl test.data
```

And once the engine is working well enough you can add your tests to the `run.pl` 
script in the test directory:

```perl
it("does something useful", sub {

    spacecraft("test.rf example.pl test.actual");
    diff("test.actual","test.expected");

});
```

And then re-run the test:

```
$ run

  example.pl
    ✓ is documented
** FAIL : test.expected not found
    ✗ does something useful

  ✗ 1 of 2 tests failed

```

Now of course this fails, but that's because you need to manually bless the 
output, then copy it as the expected output:

```
$ cp test.actual test.expected
$ run

  example.pl
    ✓ is documented
    ✓ does something useful

  ✓ 2 tests complete

```

You can continue adding tests to the `run.pl` script until you are satified your 
engine does what you want it to.


#### Host

A good engine is only really good when it is documented.

The documentation for an engine is written in [github flavored markdown (GFM)][1]
and stored in the `$SC_LAUNCHPAD/docs/engines/<engine>.pl.md` file.

This file is output as the `--help` command line documentation, but is also the 
basis for [GitHub Pages][2] hosted documentation, so don't remove the header.

The big issue, however, is how to actually host the documentation.

Technically speaking, the easiest way is to host the documentation on github, 
but since [GitHub Pages][2] are public domain, your organization might not
approve of this approach.

However, if public domain hosting is acceptable, hosting the documentation on 
github is a matter of:

1.  Forking [fiveladdercon/launchpad][3] on github,
2.  Configuring your local clone to have your fork as it's remote,
3.  Pushing your changes to your fork,
4.  Configuring the project settings of your fork to enable [GitHub Pages][2], and
5.  Navigating to https://<youraccount>.github.io/launchpad.

This is pretty standard, well documented stuff on github.

If, on the other hand, public domain hosting is not acceptable, you'll need
to [locally install Jekyll][4], which, for me, didn't go as smoothly as 
might be expected from the instructions.  So here are the steps I ended up 
following after poking through the errors and consulting the forums:

1. Install ruby

   ```
   $ sudo apt-add-repository ppa:brightbox/ruby-ng
   $ sudo apt-get install ruby ruby-dev
   ```

2. Install some missing bundler dependencies:

   ```
   $ sudo apt-get install g++ zlib1g-dev
   ```

3. Install bundler

   ```
   $ sudo gem install bundler
   ```

4. Finally install [Jekyll][5]

   ```
   $ bundle install    
   ```

If you do go through the paces to get your own [Jekyll][5] up and running, the 
`host` command will start the server for you:

```
$ host
```


Community Contributions
-----------------------

If you feel your engine is valuable to the community at large, make sure it 
meets the following requirements and then submit it as a pull request to
[fiveladdercon/launchpad][3] on github.


**(i)** The engine must have the following 3 files at a minimum:

```
engines/<engine>.pl            # The engine
docs/_engines/<engine>.pl.md   # The [GFM][1] documentation
tests/<engine>.pl/run.pl       # The test suite run script
``` 

**(ii)** The engine must show a help screen with the `-h`, `-help` or `--help` 
command line switches:

```
$ spacecraft <engine>.pl --help

  Usage:  spacecraft <engine>.pl ...
  ...
```

**(iii)** The test suite must pass using the `run` command:

```
$ cd tests/<engine>.pl/
$ run
  <engine>.pl
  ...
  ✓ N tests complete
```

Note that the `tests/<engine>.pl/` directory only requires a `run.pl` script,
which means that it may have as many other files or directories needed to 
test the features of the engine.


[1]: https://github.github.com/gfm/    
[2]: https://pages.github.com
[3]: https://github.com/fiveladdercon/launchpad
[4]: https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll
[5]: https://jekyllrb.com
