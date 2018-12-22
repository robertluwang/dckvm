#!/usr/bin/bash
# kvm_image_build.sh
# build bootable kvm image 
# Robert Wang @github.com/robertluwang
# Dec 17, 2018

dckvm=`dirname "$0"`

source $dckvm/kvmrc

virt-builder $OS_VERSION \
--format qcow2 \
--size ${DISKSIZE}G -o $IMGPATH/${OS_VERSION}-${DISKSIZE}G.qcow2 \
--network --timezone $TZ \
--root-password password:$ROOTPW \
--firstboot-command "sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config; systemctl stop NetworkManager; systemctl disable NetworkManager"

echo
virt-sysprep --format qcow2 -a $IMGPATH/${OS_VERSION}-${DISKSIZE}G.qcow2

echo
echo base image template generated ...
echo
qemu-img info $IMGPATH/${OS_VERSION}-${DISKSIZE}G.qcow2
echo

