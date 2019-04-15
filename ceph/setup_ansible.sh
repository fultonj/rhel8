#!/bin/bash
#EXISTING_INV=/var/lib/mistral/overcloud/tripleo-ansible-inventory.yaml
EXISTING_INV=/var/lib/mistral/overcloud/ceph-ansible/inventory.yml
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
#echo "Running the following:"
#echo "ansible -b -i $NEW_INV --private-key $NEW_KEY all -m ping"
#ansible -b -i $NEW_INV --private-key $NEW_KEY all -m ping

echo "[defaults]" > ansible.cfg
echo "private_key_file = $NEW_KEY" >> ansible.cfg
echo "inventory = $NEW_INV" >> ansible.cfg
echo "retry_files_enabled = False" >> ansible.cfg
echo "" >> ansible.cfg
echo "[ssh_connection]" >> ansible.cfg
echo "ssh_args = -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" >> ansible.cfg

echo "Running the following:"
echo "ansible all -m ping"
ansible all -m ping
