# Notes on getting OCaml running

The plan is to get opam running.  To start with I think I will have to compile 
everything from scratch, however, I would like to set up binaries of opam
and a compiler (similar to 4.01.0+bin-ocp) so this is much faster on
subsequent installs.

# Ports

There are no binary packages for FreeBSD at the moment (perhaps some user
maintained ones, but I have not found one).  So, we need to compile stuff
from source.  For that we need the ports tree but its not been installed
by default (and it is pretty huge while I have limited space on the 
SD card image - I should expand this).

```
$ portsnap fetch
```

This grabs all the ports (approx 68 MB) then extracts them to 
`/var/db/portsnap` (approx 136 MB).  _Note; the verification step takes
forever...._

```
$ portsnap extract
```

will extract the whole ports tree (>800Mb).  You can also extract a subsets

```
$ portsnap extract <pattern>
```

This is causing me problems as (1) its shockingly slow and (2) its filling
my SD card up and Im running out of space (aside; I tried building 4gb
or slightly below 4gb images and they wouldnt boot, so I have settled on
2gb for now - should be enough to build and install the stuff I need).

So....

# NFS

[Setting up NFS](http://www.freebsd.org/doc/handbook/network-nfs.html) went
pretty smoothly except I also added

```
mountd_enable="YES"
```

To the server.  My `/etc/exports` looks like

```
/usr/home/andyman/dev/github/mirage-fpga/rpi/freebsd/fs/ports -maproot=root 192.168.1.85
```

and I used portsnap to extract a copy of ports on the server and put them 
in `/.../freebsd/fs/ports`.

As root on the rpi do

```
mkdir /usr/ports
mount <ip_addr_of_server>:/home/.../freebsd/fs/ports /var/ports
```

# Compiling ports

Generally you do

```
$ cd /usr/ports/<package>
$ make install clean
```

You can find dpendancies with targets like

```
$ make missing
$ make build-depends-list
$ make run-depends-list
```

This is useful to plan your day...some stuff takes *forever* to build.

Once you have some packages you can

```
$ pkg create -a -o <dir>
```

To generate binary packages which should be installable with the `pkg` util
on a clean build.

# Compiling OCaml

I am using the official 4.01.0 release tarball initially.

Initially a `make world` seems to be OK and build a functioning interpreter.  Getting
a native code compiler is a bit more effort.

The `configure` script will not detect a native code compiler for this platform so
we need to start hacking.  My first attempt was to add a clause

```
# Configure the native-code compiler
...
  armv6*-*-freebsd*) arch=arm; model=armv6; system=freebsd;;
...
```

This requires a further change to asmrun/arm.S at the top.  

```
elif defined(Sys_linux_eabi) || defined(Sys_frebsd)
```

to get the clx macro defined.  This isnt exactly our architecture but it seems a
reasonable lowest common denominator for now.

Further arm.S does not compile correctly as the makefile uses `gcc` to assemble
and preprocess.  Changing to `cc` gets this compiled.

```
cc -c -DSYS_freebsd -DMODEL_armv6 -o arm.o arm.S
```

Finally we modify asmcomp/arm/arch.ml at the very top so that `Config.system = "freebsd"` 
maps to EABI.

Now we can run `make opt` and get a native code compiler.  However, on running it we get

```
% ocamlopt test.ml
/usr/bin/ld: ERROR: Source object /tmp/camlstartupd0882d.o has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /tmp/camlstartupd0882d.o
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/std_exit.o has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/std_exit.o
/usr/bin/ld: ERROR: Source object test.o has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file test.o
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(pervasives.o) has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(pervasives.o)
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(list.o) has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(list.o)
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(char.o) has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(char.o)
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(string.o) has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(string.o)
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(sys.o) has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(sys.o)
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(buffer.o) has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(buffer.o)
/usr/bin/ld: ERROR: Source object /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(printf.o) has EABI version 0, but target a.out has EABI version 5
/usr/bin/ld: failed to merge target specific data of file /home/pi/dev/ocaml/ocaml-4.01.0-install/lib/ocaml/stdlib.a(printf.o)
cc: error: linker command failed with exit code 1 (use -v to see invocation)
File "caml_startup", line 1:
Error: Error during linking
```

## Fixes

Created a new section at the top of arm.S specifically for SYS_freebsd which sets
armv6 + softfp.

Change the configure script to use `cc -c` for both AS and ASPP.

This now builds an ocamlopt which generates binaries - and they run!

Not much testing yet but I have built OPAM and it will at least print
its help screen.

## Next steps

* Release the freebsd opam binaries on the github page.
* Compile ocaml with world.opt to get the native `.opt` compilers
* Create a patch for 4.01.0 so I can push a compiler target for
  freebsd 10-release to opam and actually `-init` it.
* binary compiler release as per 4.01.0+ocp-bin
* Compile git
* See if there is somewhere we can store binary packages


