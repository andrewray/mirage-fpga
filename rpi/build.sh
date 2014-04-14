# this should be run from freebsd/usr/src

. ./env.sh

cd freebsd/usr/src
make -j$NCPUS kernel-toolchain
make -j$NCPUS KERNCONF=RPI-B WITH_FDT=yes buildkernel
make -j$NCPUS buildworld

# Instructions said this 'make MALLOC_PRODUCTION=yes buildworld' but that causes errors

