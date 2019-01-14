#!/usr/bin/bash
# kvm_vm_clean.sh
# clean kvm vm if existing
# Robert Wang @github.com/robertluwang
# Dec 23, 2018

dckvm=`dirname "$0"`
source $dckvm/kvmrc

# delete vm if existing

vmstate=`virsh domstate $VM|awk '{print $1}'`

if [ ! -z $vmstate ];then
    echo
    echo $VM existing, will delete it now ...
    echo

    if [ $vmstate == "running" ];then
        virsh destroy $VM
        virsh undefine $VM
    else
        virsh undefine $VM
    fi

    rm -f $DISKPATH/$VM.qcow2

    echo $VM deleted

else
    echo
    echo $VM not existing
    echo
fi
