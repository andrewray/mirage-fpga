---
layout: default
title: FreeBSD and OCaml on ARM
---

# Running OPAM on the Raspberry PI

## FreeBSD image

[Download](img/FreeBSD-stable10-r264702-ARMv6-RPI-B-3GB.img.tgz) (~146MB)

__Actually this does not work as the image is too big to store on github so
I will need to find some other solution.__

It is built using [freebsd-arm-tools](https://github.com/daveish/freebsd-arm-tools)

~~~
$ sudo ./build-arm-image.sh -g 32 -s 3 -w 256
~~~

* 3GB image (so requires a 4GB+ SD card)
* 256MB of swap
* 32MB GPU

## Packages

Some binary packages are provided on this site, however, you first of all need
to install the `pkg` tool.

I compile this on the Raspberry PI.

### Using portsnap on the RPI

~~~
$ portsnap fetch
$ portsnap extract
$ make -C /usr/port/ports-mgmt/pkg install clean
~~~

You will find the verification step takes hours to run and the ports packages
use about 1GB of diskspace.

### Using portsnap over NFS

It is a lot quicker to install the ports on a x86 freebsd machine (in my case
a VirtualBox VM) then [NFS](http://www.freebsd.org/doc/handbook/network-nfs.html) 
mount it on the Raspberry PI.

On the server;

~~~
$ portsnap -p /path/to/ports
~~~

and then configure `/etc/exports`

~~~
/path/to/ports -maproot=root <ip-addr-of-rpi>
~~~

As root on the RPI;

~~~
$ mkdir /usr/ports
$ mount <ip-addr-of-server>:/path/to/ports
~~~

### Untested binary...

[Apparently](http://kernelnomicon.org/?p=261) you can 
try something like this to avoid having to compile `pkg`.

~~~
$ fetch -o pkg.txz http://adrewray.github.io/mirage-fpga/packages/pkg-1.2.7_2.txz
$ tar xf //pkg.txz -s “,/.*/,,g” “*/pkg-static”
$ ./pkg-static add //pkg.txz
~~~

_I havent tried this._

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
$ pkg install wget curl rsync gmake
~~~

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

_in progress - I will shortly be sending a pull request to include the necessary
compiler_

From your home directory

~~~
$ wget http://github.com/andrewray/mirage-fpga/releases/download/v0.1/opam.asm-1.1.tar.gz
$ tar xzf opam.asm-1.1.tar.gz
$ mkdir bin
$ mv opam.asm bin/opam
$ rehash
~~~

To compile ocaml

~~~
$ opam init --comp=4.01.0+armv6-freebsd
~~~

Wait a couple of hours...

