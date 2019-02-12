#!/bin/bash
pushd box
bash make.sh rhel8
popd

pushd standalone
ansible-playbook -i inventory.yml -b bootstrap.yml
popd

echo "ssh -A rhel8"
