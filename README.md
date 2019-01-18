# rhel8

Misc scripts/playbooks to help test stein/nautilus on rhel8 beta.

- [box](box): create rhel8 beta boxes
- [standalone](standalone): deploy dev stein/nuatilus using tripleo standalone

# box
From Hypervisor:
- Create blobs/register_vars with an updated version of the following:
```
export USER=# replace with CDN username
export PASS=# replace with CDN password
export POOL=# replace with subscription manager pool number
export URL= # replace with URL containing compose
```
- Use [box/make.sh](box/make.sh) with EXTRA=1 to create rhel8 beta VM
- Update /etc/hosts with IP/name of your system

# standalone
From Hypervisor:
```
ansible-playbook -i inventory.yml -b bootstrap.yml
```

From VM:
```
bash bootstrap.sh
bash containers.sh
bash ceph_prep.sh
bash deploy.sh
```
