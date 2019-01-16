#!/usr/bin/env bash

export SSH_GIT_CHECKOUT=1
export FETCH=/home/stack/ceph_ansible_fetch

echo "creating block device and fetch directory"
if [[ ! -e /dev/loop3 ]]; then # ensure /dev/loop3 does not exist before making it
    command -v losetup >/dev/null 2>&1 || { sudo yum -y install util-linux; }
    sudo dd if=/dev/zero of=/var/lib/ceph-osd.img bs=1 count=0 seek=7G
    sudo losetup /dev/loop3 /var/lib/ceph-osd.img
elif [[ -f /var/lib/ceph-osd.img ]]; then #loop3 and ceph-osd.img exist
    echo "warning: looks like ceph loop device already created. Trying to continue"
else
    echo "error: /dev/loop3 exists but not /var/lib/ceph-osd.img. Exiting."
    exit 1
fi
sgdisk -Z /dev/loop3
sudo lsblk
if [[ ! -d $FETCH ]]; then
    mkdir $FETCH
fi

echo "installing latest ceph-ansible from git and symlinking it to /usr/share"
pushd ~
if [[ $SSH_GIT_CHECKOUT -eq 1 ]]; then
    git clone --single-branch --branch guits-podman git@github.com:/ceph/ceph-ansible.git
else
    git clone --single-branch --branch guits-podman https://github.com/fultonj/ceph-ansible.git
fi
popd
sudo ln -s /home/stack/ceph-ansible /usr/share/ceph-ansible
