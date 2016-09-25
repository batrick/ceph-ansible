#!/bin/bash

set -e

{
    count=0
    while ! systemctl status ceph-fuse@-mnt; do
        sleep 5
        if ((++count > 60)); then
            exit 1
        fi
    done

    T=$(mktemp -d tmp.XXXXXX)

    (
        cd "$T"
        wget -q http://download.ceph.com/qa/linux-4.0.5.tar.xz

        tar Jxvf linux*.xz
        cd linux*
        make defconfig
        make -j`grep -c processor /proc/cpuinfo`
    )

    rm -rfv "$T"
} > /root/client-output.txt 2>&1
