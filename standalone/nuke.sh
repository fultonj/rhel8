#!/usr/bin/env bash
set -x

# stop active systemd
for i in $(systemctl list-units |grep -e 'tripleo.*active'|awk '{ print $1}'); do
    echo $i;
    systemctl stop "$i";
done

sudo podman ps -q -a |xargs -n1 sudo podman rm -f

sudo rm -rf /var/lib/mysql/*
sudo rm -rf /var/log/containers/*
sudo rm -f /etc/systemd/system/tripleo*
