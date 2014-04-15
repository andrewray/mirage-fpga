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
