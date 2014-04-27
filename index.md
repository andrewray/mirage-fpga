---
layout: default
title: FreeBSD and OCaml on ARM
---

# Running OPAM on the Raspberry PI

## FreeBSD image

I have been building my images using [freebsd-arm-tools](https://github.com/daveish/freebsd-arm-tools)
on a FreeBSD10 x86_64 VirtualBox VM.

~~~
$ sudo ./build-arm-image.sh -g 32 -s 3 -w 256 -v svn://svn.freebsd.org/base/release/10.0.0 -r /src/FreeBSD/release/10
~~~

* 3GB image (so requires a 4GB+ SD card)
* 256MB of swap
* 32MB GPU
* Uses release/10 rather than stable/10 as I had some unexplained seg faults with the later

Note that if you have an older 256MB RPI then you must enable some
swap in order to be able to build OCaml later on through OPAM.

You can dramatically speed the build up by adding CPUs.  On my quad core I assign three cores
to the VM then modify the build script in the **Build From Source** section around line 330.
Add -j4 to each of the three make invocations.

## Packages

Some binary packages are provided on this site, however, you first of all need
to install the `pkg` tool.

You can do this by compiling it through ports on the RPI or use the following
hack to bootstrap it (as root).

~~~
$ fetch -o pkg.txz http://andrewray.github.io/mirage-fpga/packages/pkg-1.2.7_2.txz
$ tar xf pkg.txz -s ",/.*/,,g" "*/pkg-static"
$ ./pkg-static add pkg.txz
~~~

## Configuring pkg

In `/etc/pkg/FreeBSD.conf`

~~~
FreeBSD: {
  url: "pkg+http://andrewray.github.io/mirage-fpga/packages",
  mirror_type: "srv",
  enabled: yes
}
~~~

## Installing packages

With a bit of luck you should now be able to install the packages provided.

~~~
$ pkg install patch wget curl rsync gmake
~~~

Get a list of packages in this repo with

~~~
$ pkg rquery -a %n
~~~

## Installing OCaml

From your home directory

~~~
$ wget http://github.com/andrewray/mirage-fpga/releases/download/v0.1/opam.asm-1.1.tar.gz
$ tar xzf opam.asm-1.1.tar.gz
$ mkdir bin
$ mv opam.asm bin/opam
$ rehash
~~~

_The wget command seems to require `--no-check-certificate` at the moment._

To compile ocaml

~~~
$ opam init --comp=4.01.0+armv6-freebsd
~~~

Wait a couple of hours...

