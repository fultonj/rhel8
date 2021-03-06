#!/usr/bin/env bash

# based on mwahaha's notes

if [[ $(whoami) != "stack" ]]; then
    echo "I must be run as the stack user"
    exit 1
fi

if [[ $(sudo getenforce) -eq "Enforcing" ]]; then
    sudo setenforce 0
fi

echo "Install lvm2 ruby fonts"
sudo dnf install -y ruby liberation-sans-fonts lvm2

echo "use network-scripts to manage ens4"
sudo nmcli dev set ens4 managed no
sudo dnf install -y network-scripts

echo "configure upstream repositories"
sudo dnf config-manager --add-repo https://trunk.rdoproject.org/fedora/stable-base/latest
sudo dnf config-manager --add-repo https://trunk.rdoproject.org/fedora/current/

echo "excludepkgs=kernel*" | sudo tee -a /etc/yum.repos.d/trunk*fedora_stable-base*;
echo "Set priority for /etc/yum.repos.d/trunk* "
for F in `ls /etc/yum.repos.d/trunk*`; do
    echo "gpgcheck=0" | sudo tee -a $F;
    echo "priority=20" | sudo tee -a $F;
done

echo "Install fake docker and older ansible"
if [[ ! -d blobs ]]; then
    ln -s ~/standalone-blobs/ blobs
fi
if [[ -e blobs/docker-2.0.0-1.noarch.rpm ]]; then
    sudo dnf install -y blobs/docker*.rpm
else
    echo "blobs/docker-2.0.0-1.noarch.rpm is missing"
    exit 1
fi
# workaround https://bugs.launchpad.net/tripleo/+bug/1811875
if [[ -e blobs/ansible-2.7.1-1.noarch.rpm ]]; then
    sudo dnf install -y blobs/ansible-2.7.1-1.noarch.rpm
else
    echo "blobs/ansible-2.7.1-1.noarch.rpm is missing"
    exit 1
fi

echo "Install tripleo"
sudo dnf install -y python3-tripleoclient

echo "Patch puppet"

sudo sed -i 's/:operatingsystemmajrelease => "7"/:operatingsystemmajrelease => ["7","8"]/' /usr/share/ruby/vendor_ruby/puppet/provider/service/systemd.rb
sudo sed -i '/defaultfor :operatingsystem => :fedora/a \ \ defaultfor :osfamily => :redhat, :operatingsystemmajrelease => "8"' /usr/share/ruby/vendor_ruby/puppet/provider/package/dnf.rb
