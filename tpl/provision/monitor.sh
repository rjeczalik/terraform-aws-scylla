#!/bin/bash -x

set -eu

pushd scylla-grafana-monitoring-scylla-monitoring
pushd prometheus

for file in node_exporter_servers.yml scylla_servers.yml; do
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

./start-all.sh -v 2018.1 -d /prometheus-data

popd
