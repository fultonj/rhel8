#!/usr/bin/env bash
if [[ $# -eq 0 ]]; then
    echo "USAGE: $0 [name of RHEL8 VM to create]"
    exit 1
fi
NAME=$1
DOM=example.com
PASSWORD=redhat
RAM=16384
CPU=16
SLEEP=30
SSH_OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

if [[ ! -e /var/lib/libvirt/images/rhel-guest-image-8.0-1690.x86_64.qcow2 ]]; then
    echo "Download the RHEL8 beta to /var/lib/libvirt/images/"
    exit 1
fi
if [[ ! -e blobs/appliance-1.38.0.tar.xz ]]; then
    echo "Download an appliance to blobs http://download.libguestfs.org/binaries/appliance"
    exit 1    
fi
if [[ -e /var/lib/libvirt/images/$NAME.qcow2 ]]; then
    echo "Destroying old $NAME"
    if [[ $(sudo virsh list | grep $NAME) ]]; then
	sudo virsh destroy $NAME
    fi
    sudo virsh undefine $NAME
    sudo rm -f /var/lib/libvirt/images/$NAME.qcow2
fi

if [[ ! -e /tmp/appliance/ ]]; then
    echo "Preparing appliance"
    mkdir /tmp/appliance 2> /dev/null
    sudo cp blobs/appliance-*.xz /tmp/libguestfs_appliance.tar.gx
    sudo tar -C /tmp/ -xvf /tmp/libguestfs_appliance.tar.gx
fi

echo "Creating and customizing image"
sudo qemu-img create -f qcow2  /var/lib/libvirt/images/$NAME.qcow2 100G

#export LIBGUESTFS_DEBUG=1
#export LIBGUESTFS_TRACE=1
export LIBGUESTFS_PATH=/tmp/appliance
export LIBGUESTFS_BACKEND=direct

# copy olddisk to newdisk, extending one of the guest's partitions to fill
sudo -E bash -c "virt-resize --expand /dev/sda3 /var/lib/libvirt/images/rhel-guest-image-8.0-1690.x86_64.qcow2 /var/lib/libvirt/images/$NAME.qcow2"

sudo chown $USER:$USER /var/lib/libvirt/images/$NAME.qcow2
ls -l /var/lib/libvirt/images/$NAME.qcow2

virt-customize -v -a /var/lib/libvirt/images/$NAME.qcow2 --root-password password:$PASSWORD --selinux-relabel

virt-customize -a /var/lib/libvirt/images/$NAME.qcow2 --selinux-relabel --run-command 'yum remove -y cloud-init'

if [[ -e blobs/ssh_public_key ]]; then
    # curl https://github.com/fultonj.keys > blobs/ssh_public_key
    KEY=$(cat blobs/ssh_public_key)
    virt-customize -a /var/lib/libvirt/images/$NAME.qcow2 --selinux-relabel --run-command "mkdir /root/.ssh/; chmod 700 /root/.ssh/; echo $KEY > /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys;"
fi

echo "Installing virtual machine"
sudo virt-install --name $NAME \
  --disk path=/var/lib/libvirt/images/$NAME.qcow2,device=disk,bus=virtio,format=qcow2,cache=unsafe \
  --boot hd \
  --network network:default \
  --network network:ctlplane \
  --virt-type kvm \
  --cpu host-passthrough \
  --ram $RAM \
  --vcpus $CPU \
  --os-variant rhel7 \
  --import \
  --noautoconsole \
  --autostart \
  --vnc \
  --rng /dev/urandom

echo "Waiting $SLEEP seconds for VM to come online"
sleep $SLEEP

echo "Identifying IP address for new VM"
IPADDR=$(sudo virsh net-dhcp-leases default | grep $(sudo virsh dumpxml $NAME | awk '/mac address/' | awk -F "'" 'NR==1{print $2}') | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')
echo $IPADDR

if [[ ! -z $IPADDR ]]; then
   echo "Setting hostname"
   ssh $SSH_OPT root@$IPADDR "hostnamectl set-hostname $NAME.$DOM"
   ssh $SSH_OPT root@$IPADDR "hostnamectl set-hostname $NAME.$DOM --transient"
   ssh $SSH_OPT root@$IPADDR "uname -a"
   echo "The following is ready:"
   echo "$IPADDR       $NAME"
else
    echo "Could not find IP address for $NAME"
fi
