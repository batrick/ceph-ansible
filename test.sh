#!/bin/bash

set -ex
ulimit -n 65536

ARGUMENTS='--options n --long nuke'
NEW_ARGUMENTS=$(getopt $ARGUMENTS -- "$@")
eval set -- "$NEW_ARGUMENTS"

source ansible-env.bash

function repeat {
    while ! "$@"; do
        printf "failed...\n" >&2
        sleep 1
    done
}

NUKE=0
WATCH="clients mdss"
YML=site.yml
RETRY="${YML%.*}.retry"
if ! [ -f "$YML" ]; then
    cp -v -- site.yml.sample "$YML"
fi

function main {
    if [ "$NUKE" -gt 0 ]; then
        time python2 linode-nuke.py
    fi
    if ! [ -f ansible_inventory ]; then
        time python2 linode-launch.py
    fi
    time python2 linode-wait.py

    ans --module-name=shell --args='mkdir -p -v -m 1777 /crash; echo kernel.core_pattern=/crash/%e-%h-%p-%t.core | tee -a /etc/sysctl.conf; sysctl -p; echo DefaultLimitCORE=infinity | tee -a /etc/systemd/system.conf; systemctl daemon-reexec;' all

    ans --module-name=shell --args='yum groupinstall -y "Development tools"' clients
    ans --module-name=yum --args='name="autoconf,automake,bc,gdb" state=latest update_cache=yes' clients

    ans --module-name=yum --args="name=logrotate,epel-release,ca-certificates,psmisc,wget state=latest update_cache=yes" all
    ans --module-name=shell --args='yum --disablerepo=epel -y update' all

    ans --module-name=yum --args="name=htop state=latest update_cache=yes" all
    ans --module-name=command --args="mkdir -p /root/.config/htop" all
    ans --module-name=copy --args='src=htoprc dest=/root/.config/htop/htoprc owner=root group=root mode=644' all

    ans --module-name=shell --args='wipefs -a /dev/sdc' osds
    if ! do_playbook --limit=all "$YML"; then
        printf 'mons\n' >> "$RETRY"
        repeat do_playbook --limit=@"${RETRY}" "$YML"
        rm -f -- "${RETRY}"
    fi

    ans --module-name=shell --args='ceph --admin-daemon /var/run/ceph/*asok config set mon_allow_pool_delete true' mons
    ans --module-name=shell --args='ceph osd pool rm rbd rbd --yes-i-really-really-mean-it' mon-000

    ans --module-name=copy --args='src=crontab dest=/root/ owner=root group=root mode=644' all
    ans --module-name=copy --args='src=ceph-log-rotate.timer dest=/etc/systemd/system/ owner=root group=root mode=644' all
    ans --module-name=copy --args='src=ceph-log-rotate.service dest=/etc/systemd/system/ owner=root group=root mode=644' all
    ans --module-name=copy --args='src=ceph.logrotate dest=/etc/logrotate.d/ceph owner=root group=root mode=644' 'clients mons'
    ans --module-name=copy --args='src=ceph-mds.logrotate dest=/etc/logrotate.d/ceph owner=root group=root mode=644' mdss
    ans --module-name=copy --args='src=ceph-osd.logrotate dest=/etc/logrotate.d/ceph owner=root group=root mode=644' osds
    ans --module-name=copy --args='src=ceph-gather.py dest=/ owner=root group=root mode=755' all
    ans --module-name=copy --args='src=ceph-gather.service dest=/etc/systemd/system/ owner=root group=root mode=644' all
    ans --module-name=copy --args="src=./kernel_untar_build.sh dest=/ owner=root group=root mode=755" clients
    ans --module-name=copy --args="src=./creats.sh dest=/ owner=root group=root mode=755" clients
    ans --module-name=copy --args="src=./creats.c dest=/ owner=root group=root mode=644" clients

    ans --module-name=shell --args="chmod 000 /mnt; crontab crontab" all
    ans --module-name=command --args="systemctl start ceph-fuse@-mnt.service" clients
    ans --module-name=command --args="systemctl start ceph-gather.service" "$WATCH"
    date --utc
    time ans --forks=1000 --module-name=shell --args="chdir=/mnt/ mkdir -p dir && /creats.sh dir/file. 15625" clients
    date --utc
    wait
    ans --module-name=command --args="systemctl stop ceph-gather.service" "$WATCH"
    ans --module-name=command --args="systemctl stop ceph-fuse@-mnt.service" clients
}

while [ "$#" -ge 0 ]; do
    case "$1" in
        -n|--nuke)
            NUKE=1
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

main |& tee -a OUTPUT
