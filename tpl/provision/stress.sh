#!/bin/bash

set -eu

yum install -y epel-release wget tmux
wget -O /etc/yum.repos.d/scylla.repo http://repositories.scylladb.com/scylla/repo/2e2f1a5f-4195-4691-8e19-43f6af57b0e2/centos/scylladb-2018.1.repo
yum install -y scylla-enterprise-tools
