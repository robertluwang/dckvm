#!/usr/bin/bash
# kvm_image_build.sh
# build bootable kvm image 
# Robert Wang @github.com/robertluwang
# Dec 17, 2018

dckvm=`dirname "$0"`

source $dckvm/kvmrc

virt-builder $OS_VERSION \
--format qcow2 \
--size $DISKSIZE -o $IMGPATH/${OS_VERSION}-$DISKSIZE.qcow2 \
--network --timezone $TZ \
--root-password password:$ROOTPW \
--firstboot-command "sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config; systemctl stop NetworkManager; systemctl disable NetworkManager; systemctl restart network"

virt-sysprep -a $IMGPATH/${OS_VERSION}-$DISKSIZE.qcow2
