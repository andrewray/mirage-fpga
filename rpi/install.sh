#!/bin/sh
set -e

. ./env.sh

# Change this
export GPU_MEM=128
export PI_USER=pi
export PI_USER_PASSWORD=raspberry
export SRCROOT=$ROOT/freebsd/usr/src
export MNTDIR=/mnt
export MAKEOBJDIRPREFIX=$ROOT/freebsd/obj
export IMG=$ROOT/freebsd/obj/bsd-pi.img

export TARGET_ARCH=armv6
export MAKESYSPATH=$SRCROOT/share/mk
export KERNCONF=RPI-B

if [ -z "$MNTDIR" ]; then
    echo "MNTDIR is not set properly"
    exit 1
fi

KERNEL=`realpath $MAKEOBJDIRPREFIX`/arm.armv6/`realpath $SRCROOT`/sys/$KERNCONF/kernel
UBLDR=`realpath $MAKEOBJDIRPREFIX`/arm.armv6/`realpath $SRCROOT`/sys/boot/arm/uboot/ubldr
DTB=`realpath $MAKEOBJDIRPREFIX`/arm.armv6/`realpath $SRCROOT`/sys/$KERNCONF/rpi.dtb

# temporarily disable...
#make -C $SRCROOT kernel-toolchain
#make -C $SRCROOT KERNCONF=$KERNCONF WITH_FDT=yes buildkernel
#make -C $SRCROOT MALLOC_PRODUCTION=yes buildworld

buildenv=`make -C $SRCROOT buildenvvars`

eval $buildenv make -C $SRCROOT/sys/boot clean
eval $buildenv make -C $SRCROOT/sys/boot obj
eval $buildenv make -C $SRCROOT/sys/boot UBLDR_LOADADDR=0x2000000 all

rm -f $IMG
dd if=/dev/zero of=$IMG bs=128M count=8
MDFILE=`mdconfig -a -f $IMG`
echo MDFILE = $MDFILE
gpart create -s MBR ${MDFILE}

# Boot partition
gpart add -s 32m -t '!12' ${MDFILE}
gpart set -a active -i 1 ${MDFILE}
newfs_msdos -L boot -F 16 /dev/${MDFILE}s1
mount_msdosfs /dev/${MDFILE}s1 $MNTDIR
fetch -q -o - http://people.freebsd.org/~gonzo/arm/rpi/freebsd-uboot-20130201.tar.gz | tar -x -v -z -C $MNTDIR -f -

cat >> $MNTDIR/config.txt <<__EOC__
gpu_mem=$GPU_MEM
device_tree=devtree.dat
device_tree_address=0x100
disable_commandline_tags=1
__EOC__
cp $UBLDR $MNTDIR
cp $DTB $MNTDIR/devtree.dat
umount $MNTDIR

# FreeBSD partition
gpart add -t freebsd ${MDFILE}
gpart create -s BSD ${MDFILE}s2
gpart add -t freebsd-ufs ${MDFILE}s2
newfs /dev/${MDFILE}s2a

# Turn on Softupdates
tunefs -n enable /dev/${MDFILE}s2a
# Turn on SUJ with a minimally-sized journal.
# This makes reboots tolerable if you just pull power on the BB
# Note:  A slow SDHC reads about 1MB/s, so a 30MB
# journal can delay boot by 30s.
tunefs -j enable -S 4194304 /dev/${MDFILE}s2a
# Turn on NFSv4 ACLs
tunefs -N enable /dev/${MDFILE}s2a

mount /dev/${MDFILE}s2a $MNTDIR

make -C $SRCROOT DESTDIR=$MNTDIR -DDB_FROM_SRC installkernel
make -C $SRCROOT DESTDIR=$MNTDIR -DDB_FROM_SRC installworld
make -C $SRCROOT DESTDIR=$MNTDIR -DDB_FROM_SRC distribution

echo 'fdt addr 0x100' > $MNTDIR/boot/loader.rc

echo '/dev/mmcsd0s2a / ufs rw,noatime 1 1' > $MNTDIR/etc/fstab

cat > $MNTDIR/etc/rc.conf <<__EORC__
hostname="raspberry-pi"
ifconfig_ue0="DHCP"
sshd_enable="YES"

devd_enable="YES"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
__EORC__

cat > $MNTDIR/etc/ttys <<__EOTTYS__
ttyv0 "/usr/libexec/getty Pc" xterm on secure
ttyv1 "/usr/libexec/getty Pc" xterm on secure
ttyv2 "/usr/libexec/getty Pc" xterm on secure
ttyv3 "/usr/libexec/getty Pc" xterm on secure
ttyv4 "/usr/libexec/getty Pc" xterm on secure
ttyv5 "/usr/libexec/getty Pc" xterm on secure
ttyv6 "/usr/libexec/getty Pc" xterm on secure
ttyu0 "/usr/libexec/getty 3wire.115200" dialup on secure
__EOTTYS__

echo $PI_USER_PASSWORD | pw -V $MNTDIR/etc useradd -h 0 -n $PI_USER -c "Raspberry Pi User" -s /bin/csh -m
pw -V $MNTDIR/etc groupmod wheel -m $PI_USER
PI_USER_UID=`pw -V $MNTDIR/etc usershow $PI_USER | cut -f 3 -d :`
PI_USER_GID=`pw -V $MNTDIR/etc usershow $PI_USER | cut -f 4 -d :`
mkdir -p $MNTDIR/home/$PI_USER
chown $PI_USER_UID:$PI_USER_GID $MNTDIR/home/$PI_USER

umount $MNTDIR
mdconfig -d -u $MDFILE

