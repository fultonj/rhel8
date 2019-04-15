#!/bin/bash
EXISTING_INV=/var/lib/mistral/overcloud/tripleo-ansible-inventory.yaml
#EXISTING_INV=/var/lib/mistral/overcloud/ceph-ansible/inventory.yml
EXISTING_KEY=/var/lib/mistral/overcloud/ssh_private_key
NEW_INV=$(pwd)/inventory.yaml
NEW_KEY=$(pwd)/ssh_private_key
if [[ -e $EXISTING_INV ]]; then
    sudo cp $EXISTING_INV $NEW_INV
    sudo chown $USER:$USER $NEW_INV
else
    echo "Fatal: cannot find $EXISTING_INV"
    exit 1
fi
if [[ -e $EXISTING_KEY ]]; then
    sudo cp $EXISTING_KEY $NEW_KEY
    sudo chown $USER:$USER $NEW_KEY
else
    echo "Fatal: cannot find $EXISTING_KEY"
    exit 1
fi
echo "Running the following:"
echo "ansible -b -i $NEW_INV --private-key $NEW_KEY all -m ping"
ansible -b -i $NEW_INV --private-key $NEW_KEY all -m ping

