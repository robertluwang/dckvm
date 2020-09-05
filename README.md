# dckvm
a handy kvm tool from dreamcloud

## tool set
kvmrc - env setting for vm/image and networking (NAT and provision/hostonly)

net-default.xml - default nat network config file sample

net-provision.xml - provision network config file sample

kvm_post_template - kvm vm post script template, used to geneate new post script, mainly fixing nic issue in vm instance

kvm_image_build.sh - build bootable kvm image base template

kvm_net_setup.sh - kvm network interface setup

kvm_vm_create.sh - quickly launch kvm vm instance using bootable kvm image base template

## dckvm usage 

### prepare setting in kvmrc

```
# env

DISKPATH=/var/lib/libvirt/images
IMGPATH=/var/lib/libvirt/boot
ISO=CentOS-7-x86_64-Minimal-1708.iso
KS=centos7-ks.cfg

# kvm vm

OS_VERSION=centos-7.6
OS_VARIANT=rhel7
VM=testvm
RAM=2048
DISKSIZE=20G
VCPU=1
VM_HOSTNAME=testvm
TZ=America/New_York
ROOTPW=shroot

# kvm network

NET_NAT=default
NET_NAT_BRIDGE=virbr0
NET_NAT_IF=192.168.122.1
NET_NAT_IP=192.168.122.90
NET_NAT_MASK=255.255.255.0
NET_NAT_DHCP_START=192.168.122.100
NET_NAT_DHCP_END=192.168.122.254
NET_PROVISION=provision
NET_PROVISION_BRIDGE=virbr1
NET_PROVISION_IF=192.168.126.1
NET_PROVISION_IP=192.168.126.10
NET_PROVISION_MASK=255.255.255.0
NET_PROVISION_DHCP_START=192.168.126.100
NET_PROVISION_DHCP_END=192.168.126.254
```
### create base image as template
```
# /usr/share/dckvm/kvm_image_build.sh
[   2.7] Downloading: http://libguestfs.org/download/builder/centos-7.6.xz
[   6.4] Planning how to build this image
[   6.4] Uncompressing
[  19.2] Resizing (using virt-resize) to expand the disk to 20.0G
[  91.7] Opening the new disk
[  97.0] Setting a random seed
[  97.0] Setting the timezone: America/New_York
[  97.0] Installing firstboot command: sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config; systemctl stop NetworkManager; systemctl disable NetworkManager
[  97.1] Setting passwords
[  98.4] Finishing off
                   Output file: /var/lib/libvirt/boot/centos-7.6-20G.qcow2
                   Output size: 20.0G
                 Output format: qcow2
            Total usable space: 19.4G
                    Free space: 18.3G (94%)

[   0.0] Examining the guest ...
[   4.4] Performing "abrt-data" ...
[   4.4] Performing "backup-files" ...
[   6.6] Performing "bash-history" ...
[   6.6] Performing "blkid-tab" ...
[   6.7] Performing "crash-data" ...
[   6.7] Performing "cron-spool" ...
[   6.7] Performing "dhcp-client-state" ...
[   6.7] Performing "dhcp-server-state" ...
[   6.7] Performing "dovecot-data" ...
[   6.7] Performing "logfiles" ...
[   6.7] Performing "machine-id" ...
[   6.8] Performing "mail-spool" ...
[   6.8] Performing "net-hostname" ...
[   6.8] Performing "net-hwaddr" ...
[   6.8] Performing "pacct-log" ...
[   6.8] Performing "package-manager-cache" ...
[   6.8] Performing "pam-data" ...
[   6.8] Performing "passwd-backups" ...
[   6.8] Performing "puppet-data-log" ...
[   6.8] Performing "rh-subscription-manager" ...
[   6.9] Performing "rhn-systemid" ...
[   6.9] Performing "rpm-db" ...
[   6.9] Performing "samba-db-log" ...
[   6.9] Performing "script" ...
[   6.9] Performing "smolt-uuid" ...
[   6.9] Performing "ssh-hostkeys" ...
[   6.9] Performing "ssh-userdir" ...
[   6.9] Performing "sssd-db-log" ...
[   6.9] Performing "tmp-files" ...
[   6.9] Performing "udev-persistent-net" ...
[   6.9] Performing "utmp" ...
[   6.9] Performing "yum-uuid" ...
[   6.9] Performing "customize" ...
[   6.9] Setting a random seed
[   6.9] Setting the machine ID in /etc/machine-id
[   7.1] Performing "lvm-uuids" ...

base image template generated ...

image: /var/lib/libvirt/boot/centos-7.6-20G.qcow2
file format: qcow2
virtual size: 20G (21474836480 bytes)
disk size: 1.0G
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
```
### kvm network interface setup 

```
# /usr/share/dckvm/kvm_net_setup.sh
Network default destroyed

Network default has been undefined

Network provision destroyed

Network provision has been undefined

Network default defined from /usr/share/dckvm/net_default.xml

Network provision defined from /usr/share/dckvm/net_provision.xml

Network default started

Network provision started


network generated ...

default network
 default              active     no            yes
provision network
 provision            active     no            yes
```

### create new vm based on template image

If vm instance existing, will delete it at first.

```
# /usr/share/dckvm/kvm_vm_create.sh
testvm existing, will delete it now ...

Domain testvm destroyed

Domain testvm has been undefined

testvm deleted, will create it now

Starting install...
Domain creation completed.
You can restart your domain by running:
  virsh --connect qemu:///system start testvm
Domain testvm has been undefined

Domain testvm defined from /usr/share/dckvm/testvm.xml

[   0.0] Examining the guest ...
[   4.7] Setting a random seed
[   4.7] Setting the hostname: testvm
[   4.8] Installing firstboot script: /usr/share/dckvm/kvm_post_testvm.sh
[   4.9] Finishing off
Domain testvm started

testvm is launching now ...

virsh list --all
virsh console testvm 
```

## verify kvm vm 
### vm size 
```
# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda4        19G  991M   18G   6% /
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
# ip a
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:21:3a:92 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.90/24 brd 192.168.122.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe21:3a92/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:d0:b9:90 brd ff:ff:ff:ff:ff:ff
    inet 192.168.126.10/24 brd 192.168.126.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fed0:b990/64 scope link
       valid_lft forever preferred_lft forever

# ip r
default via 192.168.122.1 dev eth0
169.254.0.0/16 dev eth0 scope link metric 1002
169.254.0.0/16 dev eth1 scope link metric 1003
192.168.122.0/24 dev eth0 proto kernel scope link src 192.168.122.90
192.168.126.0/24 dev eth1 proto kernel scope link src 192.168.126.10
```
### Internet access

```
# cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 192.168.122.1
nameserver 8.8.8.8

# ping google.ca
PING google.ca (172.217.6.131) 56(84) bytes of data.
64 bytes from dfw25s16-in-f131.1e100.net (172.217.6.131): icmp_seq=1 ttl=127 time=43.3 ms
64 bytes from dfw25s16-in-f131.1e100.net (172.217.6.131): icmp_seq=2 ttl=127 time=44.7 ms
```
