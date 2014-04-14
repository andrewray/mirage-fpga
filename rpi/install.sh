. ./env.sh

export buildenv=`make -C $ROOT/freebsd/usr/src buildenvvars`
echo $buildenv
