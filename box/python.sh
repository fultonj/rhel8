#!/usr/bin/env bash
if [[ $# -eq 0 ]]; then
    echo "USAGE: $0 [IP of the host where you install python3"
    exit 1
fi
IP=$1
SSH_OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

cat <<EOF > /tmp/py
echo "Set priority for /etc/yum.repos.d/download* "
for F in `ls /etc/yum.repos.d/download*`; do
    echo "gpgcheck=0" | tee -a $F;
    echo "priority=10" | tee -a $F;
done

echo "Install python3"
dnf module enable python36
dnf module install -y python36:3.6/common
EOF

scp $SSH_OPT /tmp/py root@$IP:/tmp/py
ssh $SSH_OPT root@$IP "bash /tmp/py"
ssh $SSH_OPT root@$IP "python3 --version"
