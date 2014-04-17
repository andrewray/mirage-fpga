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


