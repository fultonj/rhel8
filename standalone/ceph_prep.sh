#!/usr/bin/env bash

export SSH_GIT_CHECKOUT=1
export FETCH=/home/stack/ceph_ansible_fetch

echo "confirm we have block device and create fetch directory"
if [[ ! -e /dev/vdb ]]; then
    echo "error: /dev/vdb does not exist"
    exit 1
fi
sgdisk -Z /dev/vdb
sudo lsblk
if [[ ! -d $FETCH ]]; then
    mkdir $FETCH
fi

echo "installing latest ceph-ansible from git and symlinking it to /usr/share"
pushd ~
if [[ $SSH_GIT_CHECKOUT -eq 1 ]]; then
    git clone --single-branch --branch guits-podman git@github.com:/fultonj/ceph-ansible.git
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
sudo python3 get-pip.py
sudo /usr/local/bin/pip install notario
sudo ln -s /usr/local/lib/python3.6/site-packages/notario /usr/lib/python3.6/site-packages/notario
