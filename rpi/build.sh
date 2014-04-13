# this should be run from freebsd/usr/src

export MAKEOBJDIRPREFIX=/home/andyman/github/mirage-fpga/rpi/freebsd/obj
export TARGET=arm
export TARGET_ARCH=arm

make kernel-toolchain
make KERNCONF=RPI-B WITH_FDT=yes buildkernel
make buildworld

# Instructions said this
# make MALLOC_PRODUCTION=yes buildworld
# but that causes errors

