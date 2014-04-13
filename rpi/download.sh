# Download and unpack uboot and freebsd source code.

# download boot loader
fetch http://people.freebsd.org/~gonzo/arm/rpi/freebsd-uboot-20121129.tar.gz
mkdir uboot
tar -C uboot -x -z -f freebsd-uboot-20121129.tar.gz

# get freebsd 10 source code
fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/10.0-RELEASE/src.txz
mkdir freebsd
tar -C freebsd -x -z -f src.txz


