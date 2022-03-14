#!/bin/bash

yum install -y  https://zfsonlinux.org/epel/zfs-release.el7_9.noarch.rpm 
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum install -y epel-release kernel-devel zfs

yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
yum -y update
yum install -y zfs
modprobe zfs

zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus1 mirror /dev/sdd /dev/sde
zpool create otus1 mirror /dev/sdf /dev/sdg
zpool create otus1 mirror /dev/sdh /dev/sdi


