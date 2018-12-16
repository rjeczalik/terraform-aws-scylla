#!/bin/bash -x

set -eu

pushd scylla-grafana-monitoring-scylla-monitoring
pushd prometheus

for file in node_exporter_servers.yml scylla_servers.yml scylla_manager_servers.yml; do
        echo '- {targets: [], labels: {}}' > $${file}
        yq w -i $${file} [0].labels.cluster ${cluster_name}
        yq w -i $${file} [0].labels.dc ${dc}
done

for node_ip in ${nodes_ips}; do
        yq w -i node_exporter_servers.yml [0].targets[+] $${node_ip}:9100
        yq w -i scylla_servers.yml [0].targets[+] $${node_ip}:9180
done

if [ -f /tmp/rule_config.yml ]; then
	yq m -i -x rule_config.yml /tmp/rule_config.yml
fi

popd

# Workaround for:
#
#   Opening storage failed lock DB directory:
#   open /prometheus/data/lock: permission denied"
#
data_dir=/opt/prometheus-data
sudo mkdir -p $${data_dir}
sudo chown -R centos:centos $${data_dir}
sudo chmod -R 0777 $${data_dir}

./start-all.sh -v 2018.1 -d $${data_dir}

popd
