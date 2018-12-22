#!/usr/bin/bash
# kvm_vm_ks.sh
# create kvm vm from iso plus kickstart
# Robert Wang @github.com/robertluwang
# Dec 22, 2018

dckvm=`dirname "$0"`

source $dckvm/kvmrc

virt-install --name $VM \
--nographics \
--location /var/lib/libvirt/boot/CentOS-7-x86_64-Minimal-1708.iso \
--initrd-inject $dckvm/$KS \
--extra-args "ks=file:/$KS console=ttyS0" \
--memory=$RAM --vcpus=$VCPU \
--disk size=$DISKSIZE
