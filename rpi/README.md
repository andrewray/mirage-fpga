Some scripts to compile a Raspberry PI FreeBSD image.

Run the following from this directory to create a SD card image
`freebsd/obj/bsd-pi.img`.

```
$ ./download.sh
$ ./build.sh
$ sudo ./install.sh
```

TODO;

* Move distro install commands to `build.sh`
* final steps which use raw block devices seem to require `root`.  Would prefer it not to.
* Use `-C` rather than `cd` in build.sh
* No need to download uboot in `download.sh` as a later version is got in `install.sh`

# Another compilation script

I have just tried a different [compiler script](https://github.com/daveish/freebsd-arm-tools) 
using

```
$ sudo ./build-arm-image.sh -g 32 -s 3 -w 256
```

This script is based on the instructions from which I generated my own images but 
also adds swap.  I need swap to build ocaml through opam it seems (I have a 256Mb
rpi, I might just buy a 512Mb version).
