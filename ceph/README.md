# Ceph Debug
Shell scripts and Ansible playbooks to debug a Ceph deployment which this repo deployed.

## Examples
These playbooks are not great. I just use them to easily push updates to the ceph.conf.

### Enable debugging on ceph mons
```
bash setup_ansible.sh
ansible-playbook-3 debug.yml --tags getconf
ls *.conf
sed -i '/null/d' *.conf
echo "[mon]" >> server-ceph.conf
echo "        debug mon = 20" >> server-ceph.conf
echo "        debug auth = 5" >> server-ceph.conf
ansible-playbook-3 debug.yml --tags pushconf,restart
```

- Set up ansible
- Download the conf files
- Remove all lines with null
  - When /dev/null is deleted from the ceph.conf it will log to /var/log/ceph
- Increase logging numbers for monitors
- Upload the conf files and restart the relevant containers

### Debug containers themselves

Does Ceph Mon see any attempts to connect?
```
podman exec -ti ceph-mon-overcloud-controller-0 /bin/bash
tail -f /var/log/ceph/*.log
```

Try to connect from the Nova libvirt container
```
podman exec -ti nova_libvirt /bin/bash
rbd -c /etc/ceph/ceph.conf --keyring /etc/ceph/ceph.client.openstack.keyring -p vms ls -l
```

