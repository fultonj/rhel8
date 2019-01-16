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

echo "installing python-notario"
# I cannot install from CBS because I need python3 notario
# https://cbs.centos.org/koji/buildinfo?buildID=23004
# sudo dnf install -y https://cbs.centos.org/kojifiles/packages/python-notario/0.0.14/1.el7/noarch/python2-notario-0.0.14-1.el7.noarch.rpm
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
sudo /usr/local/bin/pip install notario
sudo ln -s /usr/local/lib/python3.6/site-packages/notario /usr/lib/python3.6/site-packages/notario
