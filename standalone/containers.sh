#!/usr/bin/env bash
openstack tripleo container image prepare default \
	  --output-env-file $HOME/containers-prepare-parameters.yaml
# use centos7 nautilus container
sed -i 's/ceph_tag:.*/ceph_tag:\ v4.0.0beta-nautilus/g' $HOME/containers-prepare-parameters.yaml
