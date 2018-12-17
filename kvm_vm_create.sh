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

    rm -f /var/lib/libvirt/images/$VM.qcow2

    echo $VM deleted, will create it now

else
    echo $VM not existing, will create it now
fi

# prepare bootable image

if [ -f /var/lib/libvirt/boot/${OS_VERSION}-$DISKSIZE.img ]; then
    cp /var/lib/libvirt/boot/${OS_VERSION}-$DISKSIZE.img /var/lib/libvirt/images/$VM.qcow2
else
    sh $dckvm/kvm_image_build.sh
    cp /var/lib/libvirt/boot/${OS_VERSION}-$DISKSIZE.img /var/lib/libvirt/images/$VM.qcow2
fi

# create new vm by importing bootable image

virt-install --import --name $VM \
--ram $RAM \
--vcpu $VCPU \
--disk path=/var/lib/libvirt/images/$VM.qcow2 \
--network network=default \
--network network=provision \
--nographics --serial=pty --os-type=linux --os-variant $OS_VARIANT \
--noautoconsole --noreboot

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
