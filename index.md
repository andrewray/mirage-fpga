---
layout: default
title: FreeBSD and OCaml on ARM
---

# Running OPAM on the Raspberry PI

## FreeBSD image

Build using [freebsd-arm-tools](https://github.com/daveish/freebsd-arm-tools)

~~~
$ sudo ./build-arm-image.sh -g 32 -s 3 -w 256 -v svn://svn.freebsd.org/base/release/10.0.0 -r /src/FreeBSD/release/10
~~~

* 3GB image (so requires a 4GB+ SD card)
* 256MB of swap
* 32MB GPU
* Uses release/10 rather than stable/10 as I had some unexplained seg faults with the later

Note that if you have an older 256MB RPI then you must enable some
swap in order to be able to build OCaml later on through OPAM.

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

These are the ones you will need later to compile ocaml.

Here are the packages I have compiled so far:

~~~
bash-4.3.11.txz         
gmake-3.82_1.txz        
patch-2.7.1.txz
bison-2.7.1,1.txz       
libgpg-error-1.12.txz       
perl5-5.16.3_9.txz
ca_root_nss-3.15.5.txz      
libidn-1.28_1.txz       
pkg-1.2.7_2.txz
curl-7.36.0.txz         
libtool-2.4.2_2.txz     
pkgconf-0.9.5.txz
dialog4ports-0.1.5_2.txz    
libxml2-2.8.0_4.txz     
rsync-3.1.0_3.txz
m4-1.4.17_1,1.txz       
unzip-6.0_1.txz
getopt-1.1.5.txz        
p5-Error-0.17022.txz        
vim-lite-7.4.256.txz
gettext-0.18.3.1.txz        
wget-1.15.txz
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

