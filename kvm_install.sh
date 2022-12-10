# kvm-install.sh
# handy script to install kvm packages on ubuntu 
# By Robert Wang @github.com/robertluwang
# Dec 10, 2022

# update  

sudo apt update -y

# remove snap on ubuntu 22.04 , can skip this section for previous ubuntu 
sudo systemctl disable snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service
sudo apt remove snapd
sudo apt autoremove --purge snapd
sudo rm -rf /var/cache/snapd/
rm -rf ~/snap

# upgrade

sudo apt upgrade -y

# check nested vt enabled for kvm 

VMX=$(egrep -c '(vmx|svm)' /proc/cpuinfo)

if $VMX = 0 
then
    echo "Please enable nested VT on host, exit!"
fi 

# kvm install 

sudo apt install -y qemu-kvm libvirt-daemon-system virtinst libvirt-clients bridge-utils
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl status libvirtd

# add login user to group of kvm, libvirt

sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER

# kvm tool 

sudo apt install -y libguestfs-tools virt-top

