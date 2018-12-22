#!/usr/bin/bash
# kvm_vm_create.sh
# launch kvm vm instance using bootable kvm image 
# Robert Wang @github.com/robertluwang
# Dec 17, 2018

dckvm=`dirname "$0"`

source $dckvm/kvmrc

# delete vm if existing

vmstate=`virsh domstate $VM|awk '{print $1}'`

if [ ! -z $vmstate ];then

    echo $VM existing, will delete it now 
    
    if [ $vmstate == "running" ];then
        virsh destroy $VM
        virsh undefine $VM
    else
        virsh undefine $VM
    fi

    rm -f $DISKPATH/$VM.qcow2

    echo $VM deleted, will create it now

else
    echo $VM not existing, will create it now
fi

# prepare bootable image

if [ -f $IMGPATH/${OS_VERSION}-$DISKSIZE.qcow2 ]; then
    cp $IMGPATH/${OS_VERSION}-$DISKSIZE.qcow2 $DISKPATH/$VM.qcow2
else
    sh $dckvm/kvm_image_build.sh
    cp $IMGPATH/${OS_VERSION}-$DISKSIZE.qcow2 $IMGPATH/$VM.qcow2
fi

# create new vm by importing bootable image

virt-install --import --name $VM \
--ram $RAM \
--vcpu $VCPU \
--disk path=$DISKPATH/$VM.qcow2,device=disk,format=qcow2 \
--network network=$NET_NAT \
--network network=$NET_PROVISION \
--nographics --serial=pty --os-type=linux --os-variant $OS_VARIANT \
--noautoconsole --noreboot

# fix driver type issue, it misidentifies raw for qcow2 disk driver type

if [ -f $dckvm/$VM.xml ];then
        rm -f $dckvm/$VM.xml
fi

virsh dumpxml $VM > $dckvm/$VM.xml
sed -i "s/driver name='qemu' type='raw'/driver name='qemu' type='qcow2'/g" $dckvm/$VM.xml
virsh undefine $VM
virsh define $dckvm/$VM.xml

# generate kvm post script for new vm

cp $dckvm/kvm_post_template $dckvm/kvm_post_$VM.sh

sed -i "s/_nat_ip_/$NET_NAT_IP/g" $dckvm/kvm_post_$VM.sh
sed -i "s/_nat_mask_/$NET_NAT_MASK/g" $dckvm/kvm_post_$VM.sh
sed -i "s/_nat_if_/$NET_NAT_IF/g" $dckvm/kvm_post_$VM.sh

sed -i "s/_provision_ip_/$NET_PROVISION_IP/g" $dckvm/kvm_post_$VM.sh
sed -i "s/_provision_mask_/$NET_PROVISION_MASK/g" $dckvm/kvm_post_$VM.sh

# update hostname and run post script to fix NIC issue
virt-customize --hostname ${VM_HOSTNAME} --firstboot $dckvm/kvm_post_$VM.sh -d $VM

virsh start $VM

echo $VM is running now
