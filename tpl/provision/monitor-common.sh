#!/bin/bash -x

set -eu

useradd support
mkdir -p /home/support/.ssh
grep support-scylladb-com /home/centos/.ssh/authorized_keys > /home/support/.ssh/authorized_keys
echo 'support ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
chown -R support /home/support/.ssh
chmod 0700 /home/support/.ssh
chmod 0600 /home/support/.ssh/authorized_keys

mkdir -p /prometheus-data
chown -R 65534:65534 /prometheus-data
