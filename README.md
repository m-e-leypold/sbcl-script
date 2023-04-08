sbcl-script -- script runner for scripts written in Steel Bank Common Lisp
==========================================================================

About
-----

```sbcl-script``` is a script runner for scripts written in Steel Banks
Common Lisp, to be used in the hash-bang line, which also reads the
system and user initialization files.

Details
-------

Using ```sbcl --script``` in the following fashion to run a lisp script

    #!/usr/bin/env -S sbcl --script

	(do-something)

has the disadvantage that the user initialization file is not read, thus any
user local setup (like additional ASDF paths or quicklisp) is not
respected.

It is desirable, though, that the developer has the opportunity to run
a script in development against packages installed in the user
environment, whereas the finally installed version might run against
the system wide installed packages only (using ```sbcl --script``` in
the hash-bang line).

```sbcl-script``` works almost like ```sbcl --script```, but also
reads the default user and system initialization files
```/etc/sbclrc``` and ```~/.sbclrc```.

During development of a script, the script should have the hash-bang line

    #!/usr/bin/env sbcl-script

which should be replaced by

    #!/usr/bin/env sbcl --script

when installing the script.

Caveats
-------

### Use ```(require 'asdf)```

ASDF seems not to be loaded initially in all installations of SBCL. So
every script that relies on ASDF should start with

	(require 'asdf)
	
This is a no-op for ```scbl-script``` if you already set up ASDF in
your initialization file, whereas it loads ASDF when the script is run
with ```sbcl --script```.

### Redirect ```*standard-output*``` during ASDF operation

ASDF writes compilation messages to ```*standard-output*```. So for
scripts to work nicely as filters and with redirection, the loading of
ASDF systems should be done while temporarily redirecting
```*standard-output*``` to ```*error-output```.

	(let ((*standard-output* *error-output*))
	  (asdf:load-system "some.system")
	  (asdf:load-system "another.system"))

License
-------

This program is licensed to you under the terms of the GNU General
Public License as follows:

    sbcl-script --- Script runner for scripts written in Steel Bank Common Lisp
    Copyright (C) 2023 M E Leypold

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

A copy of the Gnu Public License can be found in the file
[LICENSE.txt](./LICENSE.txt).
