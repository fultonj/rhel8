#!/usr/bin/env bash

export SSH_GIT_CHECKOUT=0
export FETCH=/home/stack/ceph_ansible_fetch

echo "confirm we have block device and create fetch directory"
if [[ ! -e /dev/vdb ]]; then
    echo "error: /dev/vdb does not exist"
    exit 1
fi
# ensure /dev/vdb is clean
sudo dmsetup remove $(sudo dmsetup ls | grep ceph | awk {'print $1'})
sudo dd if=/dev/zero of=/dev/vdb bs=1M count=1000
sudo sgdisk -Z /dev/vdb
sudo lsblk

if [[ ! -d $FETCH ]]; then
    mkdir $FETCH
fi


echo "installing latest ceph-ansible from git and symlinking it to /usr/share"

if [[ $SSH_GIT_CHECKOUT -eq 1 ]]; then
    echo "cloning v4.0.0beta1 from github"
    pushd ~
    git clone --single-branch --branch v4.0.0beta1 git@github.com:ceph/ceph-ansible.git
    popd
    sudo ln -s /home/stack/ceph-ansible /usr/share/ceph-ansible
else
    echo "Add ceph-nautilus dnf repo and install ceph-ansible 4 beta"
    sudo dnf config-manager --add-repo https://buildlogs.centos.org/centos/7/storage/x86_64/ceph-nautilus/
    FILE=/etc/yum.repos.d/$(ls /etc/yum.repos.d/ | grep ceph)
    sudo sed -i "/gpgcheck/d" $FILE
    sudo sh -c "echo gpgcheck=0 >> $FILE"
    sudo dnf install -y ceph-ansible-4.0.0-0.beta1.1.el7
fi

echo "installing python3-notario"
# I cannot install from CBS because I need python3 notario
# https://cbs.centos.org/koji/buildinfo?buildID=23004
# sudo dnf install -y https://cbs.centos.org/kojifiles/packages/python-notario/0.0.14/1.el7/noarch/python2-notario-0.0.14-1.el7.noarch.rpm
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python3 get-pip.py
sudo /usr/local/bin/pip install notario
sudo ln -s /usr/local/lib/python3.6/site-packages/notario /usr/lib/python3.6/site-packages/notario
