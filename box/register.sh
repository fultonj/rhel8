#!/usr/bin/env bash
if [[ $# -eq 0 ]]; then
    echo "USAGE: $0 [IP of the host your want to regsiter]"
    exit 1
fi
IP=$1
SSH_OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
source blobs/register_vars

echo "Registering to CDN"
ssh $SSH_OPT root@$IP "subscription-manager register --username=$USER --password=$PASS"
if [ $? -ne 0 ]; then
    echo "last command failed"
    exit 1
fi
sleep 3

echo "Attaching to subscription pool"
ssh $SSH_OPT root@$IP "subscription-manager auto-attach"
ssh $SSH_OPT root@$IP "subscription-manager attach --pool $POOL"
#echo "Configure BaseOS and AppStream repositories"
#ssh $SSH_OPT root@$IP "dnf config-manager --add-repo $URL/BaseOS/x86_64/os/"
#ssh $SSH_OPT root@$IP "dnf config-manager --add-repo $URL/AppStream/x86_64/os/"
