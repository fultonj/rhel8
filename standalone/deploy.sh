#!/usr/bin/env bash

# based on mwahaha's notes

if [[ $(whoami) != "stack" ]]; then
    echo "I must be run as the stack user"
    exit 1
fi

export IP=192.168.24.2
export NETMASK=24
export INTERFACE=ens4

cat <<EOF > $HOME/standalone_parameters.yaml
resource_registry:
  OS::TripleO::Services::Docker: OS::Heat::None

parameter_defaults:
  CloudName: $IP
  ControlPlaneStaticRoutes: []
  NtpServer: ["clock.redhat.com","clock2.redhat.com"]
  Debug: true
  DeploymentUser: $USER
  DnsServers:
    - 10.19.43.29
    - 10.11.5.19
    - 10.5.30.160
  DockerInsecureRegistryAddress:
    - $IP:8787
  NeutronPublicInterface: $INTERFACE
  # domain name used by the host
  NeutronDnsDomain: localdomain
  # re-use ctlplane bridge for public net, defined in the standalone
  # net config (do not change unless you know what you're doing)
  NeutronBridgeMappings: datacentre:br-ctlplane
  NeutronPhysicalBridge: br-ctlplane
  # enable to force metadata for public net
  #NeutronEnableForceMetadata: true
  StandaloneEnableRoutedNetworks: false
  StandaloneHomeDir: $HOME
  StandaloneLocalMtu: 1500
  # Needed if running in a VM, not needed if on baremetal
  NovaComputeLibvirtType: qemu

  # below this comment is RHEL8 specific
  ContainerCli: podman
  SELinuxMode: permissive
  # bz#1630057
  SnmpdBindHost: ['udp:$IP:161','udp6:[::1]:161']
  PythonInterpreter: /usr/bin/python3
EOF

if [[ ! -d ~/templates ]]; then
    if [[ ! -d ~/tripleo-heat-templates ]]; then
	ln -s /usr/share/openstack-tripleo-heat-templates ~/templates
    else
	ln -s ~/tripleo-heat-templates ~/templates
    fi
fi

sudo openstack tripleo deploy \
     --templates $HOME/templates/ \
     --local-ip=$IP/$NETMASK \
     -e $HOME/templates/environments/standalone/standalone-tripleo.yaml \
     -r $HOME/templates/roles/Standalone.yaml \
     -e $HOME/templates/environments/ceph-ansible/ceph-ansible.yaml \
     -e $HOME/containers-prepare-parameters.yaml \
     -e $HOME/standalone_parameters.yaml \
     -e $HOME/rhel8/standalone/ceph.yaml \
     --output-dir $HOME \
     --standalone
