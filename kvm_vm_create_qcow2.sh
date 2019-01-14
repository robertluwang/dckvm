#!/usr/bin/bash
# kvm_vm_create_qcow2.sh
# launch kvm vm instance using bootable qcow2
# Robert Wang @github.com/robertluwang
# Jan 13, 2019

dckvm=`dirname "$0"`

source $dckvm/kvmrc

$dckvm/kvm_vm_clean.sh

# prepare bootable image

if [ -f $IMGPATH/${IMGFILE} ]; then
    cp $IMGPATH/${IMGFILE} $DISKPATH/$VM-${IMGFILE}
else
    echo "$IMGPATH/${IMGFILE} not existing, check please ..."
    exit
fi

# either nat or provision network not ready, reset network
net_nat=`virsh net-list --all|grep $NET_NAT|awk '{print $1}'`
net_pro=`virsh net-list --all|grep $NET_PROVISION|awk '{print $1}'`

if [ -z "$net_nat" ] || [ -z "$net_pro" ]; then
    echo
    echo network not ready, reset $NET_NAT and $NET_PROVISION now ...
    echo

    $dckvm/kvm_net_setup.sh
fi

# create new vm by importing bootable image

virt-install --import --name $VM \
--ram $RAM \
--vcpu $VCPU \
--disk path=$DISKPATH/$VM-${IMGFILE},format=qcow2,bus=virtio \
--network network=$NET_NAT \
--network network=$NET_PROVISION \
--nographics --serial=pty --os-type=linux --os-variant $OS_VARIANT \
--noautoconsole --noreboot

# resize disk
qemu-img resize $DISKPATH/$VM-${IMGFILE} ${DISKSIZE}G

cp $DISKPATH/$VM-${IMGFILE} $DISKPATH/orig-$VM-${IMGFILE}

partition=`virt-filesystems -l -h --all -a $DISKPATH/$VM-${IMGFILE} |grep /dev/VolGroup00|grep vg|awk '{print $7}'`
logvol=`virt-filesystems -l -h --all -a $DISKPATH/$VM-${IMGFILE} |grep /dev/VolGroup00|grep lv|awk '{print $1}'|head -1`
virt-resize --expand $partition --LV-expand $logvol $DISKPATH/orig-$VM-${IMGFILE} $DISKPATH/$VM-${IMGFILE}

# generate kvm post script for new vm

cp $dckvm/kvm_post_template $dckvm/kvm_post_$VM.sh

sed -i "s/_nat_ip_/$NET_NAT_IP/g" $dckvm/kvm_post_$VM.sh
sed -i "s/_nat_mask_/$NET_NAT_MASK/g" $dckvm/kvm_post_$VM.sh
sed -i "s/_nat_if_/$NET_NAT_IF/g" $dckvm/kvm_post_$VM.sh

sed -i "s/_provision_ip_/$NET_PROVISION_IP/g" $dckvm/kvm_post_$VM.sh
sed -i "s/_provision_mask_/$NET_PROVISION_MASK/g" $dckvm/kvm_post_$VM.sh

# update hostname and run post script to fix NIC issue
virt-customize --network --timezone $TZ \
--root-password password:$ROOTPW \
--hostname ${VM_HOSTNAME} --firstboot $dckvm/kvm_post_$VM.sh -d $VM

virsh start $VM

echo
echo $VM is launching now ...
echo
