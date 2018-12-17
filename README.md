# dckvm
handy kvm tool from dreamcloud

## tool set
kvmrc - env setting for vm/image and networking (NAT and provision/hostonly)

net-default-nat.xml - default nat network config file

net-provision.xml - provision network config file

kvm_post_template - kvm vm post script template, used to geneate new post script, mainly fixing nic issue in vm instance

kvm_image_build.sh - build bootable kvm image

kvm_vm_create.sh - launch kvm vm instance using bootable kvm image

## dckvm usage 

### prepare setting in kvmrc

```
# kvm vm

OS_VERSION=centos-7.6
OS_VARIANT=rhel7
VM=undercloud
RAM=2048
DISKSIZE=80G
VCPU=1
VM_HOSTNAME=undercloud
TZ=America/New_York
ROOTPW=shroot

# kvm network

NET_NAT=default
NET_NAT_BRIDGE=virbr0
NET_NAT_IF=192.168.122.1
NET_NAT_IP=192.168.122.90
NET_NAT_MASK=255.255.255.0
NET_NAT_DHCP=192.168.122.128,192.168.122.254
NET_PROVISION=provision
NET_PROVISION_BRIDGE=virbr1
NET_PROVISION_IF=192.168.126.2
NET_PROVISION_IP=192.168.126.1
NET_PROVISION_MASK=255.255.255.0
NET_PROVISION_DHCP=192.168.126.100,192.168.126.254
```

### run the kvm_vm_create.sh 

If vm instance existing, will delete it at first.

```
[root@tripleo tmp]# /root/dckvm/kvm_vm_create.sh
undercloud existing, will delete it now
Domain undercloud destroyed

Domain undercloud has been undefined

undercloud deleted, will create it now
[   2.9] Downloading: http://libguestfs.org/download/builder/centos-7.6.xz
[   4.8] Planning how to build this image
[   4.8] Uncompressing
[  20.9] Resizing (using virt-resize) to expand the disk to 80.0G
[  92.4] Opening the new disk
[  98.5] Setting a random seed
[  98.5] Setting the timezone: America/New_York
[  98.6] Installing firstboot command: sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config; systemctl stop NetworkManager; systemctl disable NetworkManager; systemctl restart network
[  98.6] Setting passwords
[ 100.3] Finishing off
                   Output file: /var/lib/libvirt/boot/centos-7.6-80G.img
                   Output size: 80.0G
                 Output format: raw
            Total usable space: 79.4G
                    Free space: 78.3G (98%)

Starting install...
Domain creation completed.
You can restart your domain by running:
  virsh --connect qemu:///system start undercloud
[   0.0] Examining the guest ...
[   5.5] Setting a random seed
[   5.5] Setting the hostname: undercloud
[   5.5] Installing firstboot script: /root/dckvm/kvm_post_undercloud.sh
[   5.6] Finishing off
Domain undercloud started

undercloud is running now
[root@tripleo tmp]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 22    undercloud                     running
```

## verify kvm vm 
### vm size 
```
[root@undercloud ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda4        79G  994M   78G   2% /
devtmpfs        909M     0  909M   0% /dev
tmpfs           920M     0  920M   0% /dev/shm
tmpfs           920M   17M  903M   2% /run
tmpfs           920M     0  920M   0% /sys/fs/cgroup
/dev/vda2      1014M  137M  878M  14% /boot
tmpfs           184M     0  184M   0% /run/user/0
```
### NIC 
- two NIC up
- eth0 192.168.122.90 for NAT 
- eth1 192.168.126.1 for privision/hostonly 
```
[root@undercloud ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:d1:c6:db brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.90/24 brd 192.168.122.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fed1:c6db/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:f1:e4:6d brd ff:ff:ff:ff:ff:ff
    inet 192.168.126.1/24 brd 192.168.126.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fef1:e46d/64 scope link
       valid_lft forever preferred_lft forever
[root@undercloud ~]# ip r
default via 192.168.122.1 dev eth0
169.254.0.0/16 dev eth0 scope link metric 1002
169.254.0.0/16 dev eth1 scope link metric 1003
192.168.122.0/24 dev eth0 proto kernel scope link src 192.168.122.90
192.168.126.0/24 dev eth1 proto kernel scope link src 192.168.126.1
```


