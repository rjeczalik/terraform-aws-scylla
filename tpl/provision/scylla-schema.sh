#!/bin/bash -x

set -eu

while ! cqlsh -u cassandra -p cassandra -e "DESCRIBE CLUSTER;" &>/dev/null; do
	sleep 5
done

cqlsh -u cassandra -p cassandra -e "CREATE USER IF NOT EXISTS ${admin} WITH PASSWORD '${admin_password}' SUPERUSER;"
cqlsh -u ${admin} -p "${admin_password}" -e "DROP USER cassandra;"

cqlsh -u ${admin} -p "${admin_password}" -e "ALTER KEYSPACE system_auth WITH REPLICATION = {'class' : 'NetworkTopologyStrategy', '${dc}': ${system_auth_replication}};"
cqlsh -u ${admin} -p "${admin_password}" -e "CREATE USER IF NOT EXISTS ${user} WITH PASSWORD '${user_password}' SUPERUSER;"
