#!/bin/bash -x

set -eu

pushd /etc/scylla

yq w -i scylla.yaml authenticator PasswordAuthenticator
yq w -i scylla.yaml authorizer CassandraAuthorizer
yq w -i scylla.yaml endpoint_snitch GossipingPropertyFileSnitch
yq w -i scylla.yaml broadcast_address ${public_ip}
yq w -i scylla.yaml broadcast_rpc_address ${public_ip}
yq w -i scylla.yaml cluster_name ${cluster_name}
yq w -i scylla.yaml auto_bootstrap true
yq w -i scylla.yaml listen_address 0.0.0.0
yq w -i scylla.yaml rpc_address 0.0.0.0
yq w -i scylla.yaml seed_provider[0].parameters[0].seeds ${seeds}


cat >cassandra-rackdc.properties <<EOF
#
# cassandra-rackdc.properties
#
dc=${dc}
rack=${rack}
EOF

popd
