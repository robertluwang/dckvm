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
# env

DISKPATH=/var/lib/libvirt/images
IMGPATH=/var/lib/libvirt/boot

# kvm vm

OS_VERSION=centos-7.6
OS_VARIANT=rhel7
VM=testvm
RAM=2048
DISKSIZE=80G
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
# /usr/share/dckvm/kvm_image_build.sh
[   3.4] Downloading: http://libguestfs.org/download/builder/centos-7.6.xz
[  15.9] Planning how to build this image
[  15.9] Uncompressing
[  31.5] Resizing (using virt-resize) to expand the disk to 20.0G
[ 159.8] Opening the new disk
[ 167.0] Setting a random seed
[ 167.0] Setting the timezone: America/New_York
[ 167.1] Installing firstboot command: sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config; systemctl stop NetworkManager; systemctl disable NetworkManager; systemctl restart network
[ 167.1] Setting passwords
[ 169.4] Finishing off
                   Output file: /var/lib/libvirt/boot/centos-7.6-20G.img
                   Output size: 20.0G
                 Output format: raw
            Total usable space: 19.4G
                    Free space: 18.3G (94%)
[   0.0] Examining the guest ...
[   4.3] Performing "abrt-data" ...
[   4.3] Performing "backup-files" ...
[   6.3] Performing "bash-history" ...
[   6.3] Performing "blkid-tab" ...
[   6.4] Performing "crash-data" ...
[   6.4] Performing "cron-spool" ...
[   6.5] Performing "dhcp-client-state" ...
[   6.5] Performing "dhcp-server-state" ...
[   6.5] Performing "dovecot-data" ...
[   6.5] Performing "logfiles" ...
[   6.5] Performing "machine-id" ...
[   6.5] Performing "mail-spool" ...
[   6.5] Performing "net-hostname" ...
[   6.5] Performing "net-hwaddr" ...
[   6.6] Performing "pacct-log" ...
[   6.6] Performing "package-manager-cache" ...
[   6.6] Performing "pam-data" ...
[   6.6] Performing "passwd-backups" ...
[   6.6] Performing "puppet-data-log" ...
[   6.6] Performing "rh-subscription-manager" ...
[   6.6] Performing "rhn-systemid" ...
[   6.6] Performing "rpm-db" ...
[   6.6] Performing "samba-db-log" ...
[   6.6] Performing "script" ...
[   6.6] Performing "smolt-uuid" ...
[   6.6] Performing "ssh-hostkeys" ...
[   6.6] Performing "ssh-userdir" ...
[   6.7] Performing "sssd-db-log" ...
[   6.7] Performing "tmp-files" ...
[   6.7] Performing "udev-persistent-net" ...
[   6.7] Performing "utmp" ...
[   6.7] Performing "yum-uuid" ...
[   6.8] Performing "customize" ...
[   6.8] Setting a random seed
[   6.8] Setting the machine ID in /etc/machine-id
[   6.8] Performing "lvm-uuids" ...


# /usr/share/dckvm/kvm_vm_create.sh
error: failed to get domain 'testvm'
error: Domain not found: no domain with matching name 'testvm'
testvm not existing, will create it now

Starting install...
Domain creation completed.
You can restart your domain by running:
  virsh --connect qemu:///system start testvm
[   0.0] Examining the guest ...
[   6.6] Setting a random seed
[   6.6] Setting the hostname: testvm
[   6.6] Installing firstboot script: ./kvm_post_testvm.sh
[   6.8] Finishing off
Domain testvm started

testvm is running now

virsh list --all
virsh console testvm 
```

## verify kvm vm 
### vm size 
```
# df -h

```
### NIC 
- two NIC up
- eth0 192.168.122.90 for NAT 
- eth1 192.168.126.1 for privision/hostonly 
```
# ip a
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
# ip r
default via 192.168.122.1 dev eth0
169.254.0.0/16 dev eth0 scope link metric 1002
169.254.0.0/16 dev eth1 scope link metric 1003
192.168.122.0/24 dev eth0 proto kernel scope link src 192.168.122.90
192.168.126.0/24 dev eth1 proto kernel scope link src 192.168.126.1
```
### Internet access

```
# cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 192.168.122.1
nameserver 8.8.8.8

# ping google.ca
PING google.ca (74.125.21.94) 56(84) bytes of data.
64 bytes from yv-in-f94.1e100.net (74.125.21.94): icmp_seq=1 ttl=127 time=86.5 ms
64 bytes from yv-in-f94.1e100.net (74.125.21.94): icmp_seq=2 ttl=127 time=38.4 ms

--- google.ca ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 38.491/62.501/86.512/24.011 ms
```
