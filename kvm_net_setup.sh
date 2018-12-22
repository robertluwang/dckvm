#!/usr/bin/bash
# kvm_net_setup.sh
# kvm network interface setup
# Robert Wang @github.com/robertluwang
# Dec 22, 2018

dckvm=`dirname "$0"`

source $dckvm/kvmrc

# backup network xml

if [ -f $dckvm/net_$NET_NAT.xml ];then
    mv $dckvm/net_$NET_NAT.xml $dckvm/net_${NET_NAT}_last.xml
fi

if [ -f $dckvm/net_$NET_PROVISION.xml ];then
    mv $dckvm/net_$NET_PROVISION.xml $dckvm/net_${NET_PROVISION}_last.xml
fi

# create network xml

cat <<EOF > $dckvm/net_$NET_NAT.xml
<network>
  <name>$NET_NAT</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='$NET_NAT_BRIDGE' stp='on' delay='0'/>
  <ip address='$NET_NAT_IF' netmask='$NET_NAT_MASK'>
    <dhcp>
      <range start='$NET_NAT_DHCP_START' end='$NET_NAT_DHCP_END'/>
    </dhcp>
  </ip>
</network>
EOF

cat <<EOF > $dckvm/net_$NET_PROVISION.xml
<network>
  <name>$NET_PROVISION</name>
  <bridge name='$NET_PROVISION_BRIDGE' stp='on' delay='0'/>
  <ip address='$NET_PROVISION_IF' netmask='$NET_PROVISION_MASK'>
    <dhcp>
      <range start='$NET_PROVISION_DHCP_START' end='$NET_PROVISION_DHCP_END'/>
    </dhcp>
  </ip>
</network>
EOF

# delete network
virsh net-destroy $NET_NAT
virsh net-undefine $NET_NAT

virsh net-destroy $NET_PROVISION
virsh net-undefine $NET_PROVISION

# recreate network from xml

virsh net-define $dckvm/net_$NET_NAT.xml
virsh net-define $dckvm/net_$NET_PROVISION.xml

virsh net-start $NET_NAT
virsh net-start $NET_PROVISION

# show up the network
echo
echo network generated ...
echo
echo default network
virsh net-list --all | grep $NET_NAT

echo provision network
virsh net-list --all | grep $NET_PROVISION
echo

