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
ansible-playbook-3 debug.yml --tags pushconf,restart
```

- Set up ansible
- Download the conf files
- Remove all ines with null
  - When /dev/null is deleted from the ceph.conf it will log to /var/log/ceph
- Upload the conf files and restart the relevant containers