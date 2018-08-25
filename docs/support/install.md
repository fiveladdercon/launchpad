---
layout: default
title: Installation
permalink: /basics/install/
---

[github]:                  http://github.com
[git]:                     https://git-scm.com
[fiveladdercon/launchpad]: https://github.com/fiveladdercon/launchpad
[contribute]:              contribute/

Getting Spacecraft
==================

Spacecraft is distributed as a repository hosted on [github][].

1. Install [git][] locally, if needed.

2. Change directories to some install directory:

   ```
   $ cd </some/installation/directory>
   ```

3. Locally clone the repository.

   **If** you may ultimately [contribute][] back to Spacecraft:

   1.  Create a [github][] account, if needed.

   2.  Fork the [fiveladdercon/launchpad][] repository.

   3.  Clone your fork:

	   ```
	   $ git clone https://github.com/<youraccount>/launchpad
	   ```

   **If** you're just poking around: 

   1.  Clone the [fiveladdercon/launchpad][] repository directly:

	   ```
	   $ git clone https://github.com/fiveladdercon/launchpad
	   ```

	   but realize you're on your own and that that any changes you make 
	   can't be merged back in without a [github][] account.

   If in doubt, fork then clone.

4. Set the `SC_LAUNCHPAD` environment variable to the local launchpad repository 
   and add it to your path:

   ```
   $ cd launchpad
   $ echo "export SC_LAUNCHPAD=$PWD"  >> ~/.profile  # Note double quotes
   $ echo 'PATH=$PATH:$SC_LAUNCHPAD'  >> ~/.profile  # Note single quotes
   $ source ~/.profile
   ```

5. Link the appropriate binary for your architecture to `spacecraft` in the launchpad root:

   ```
   $ ln -s bin/spacecraft_<version>_<arch> spacecraft
   ```
