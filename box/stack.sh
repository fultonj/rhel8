if [[ $# -eq 0 ]]; then
    echo "USAGE: $0 [IP of the host where you want to add stack user]"
    exit 1
fi
IP=$1
export KEY_URL=https://github.com/fultonj.keys
export SSH_OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

cat <<EOF > /tmp/stack
useradd stack
echo "stack:redhat" | chpasswd
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack
mkdir /home/stack/.ssh/; chmod 700 /home/stack/.ssh/; curl $KEY_URL > /home/stack/.ssh/authorized_keys; chmod 600 /home/stack/.ssh/authorized_keys; chcon system_u:object_r:ssh_home_t:s0 /home/stack/.ssh ; chcon unconfined_u:object_r:ssh_home_t:s0 /home/stack/.ssh/authorized_keys; chown -R stack:stack /home/stack/.ssh/
EOF

scp $SSH_OPT /tmp/stack root@$IP:/tmp/stack
ssh $SSH_OPT root@$IP "bash /tmp/stack"
ssh $SSH_OPT root@$IP "id stack"
