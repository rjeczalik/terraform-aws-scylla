provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

resource "aws_instance" "scylla" {
	ami = "${lookup(var.aws_ami_scylla, var.aws_region)}"
	instance_type = "${var.aws_instance_type}"
	key_name = "${aws_key_pair.support.key_name}"
	monitoring = true
	availability_zone = "${element(var.aws_availability_zones[var.aws_region], count.index % length(var.aws_availability_zones[var.aws_region]))}"
	subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
	user_data = "${format(join("\n", var.scylla_args), var.cluster_name)}"

	security_groups = [
		"${aws_security_group.cluster.id}",
		"${aws_security_group.cluster_admin.id}",
		"${aws_security_group.cluster_user.id}"
	]

	root_block_device {
		volume_type = "${var.block_device_type}"
		volume_size = "${var.block_device_size}"
		iops = "${var.block_device_iops}"
	}

	credit_specification {
		cpu_credits = "unlimited"
	}

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}

	count = "${var.cluster_count}"
}

data "template_file" "scylla_cidr" {
	template = "$${cidr}"
	count = "${var.cluster_count}"
	vars = {
		cidr = "${element(aws_instance.scylla.*.public_ip, count.index)}/32"
	}
}

resource "aws_instance" "monitor" {
	ami = "${lookup(var.aws_ami_monitor, var.aws_region)}"
	instance_type = "t3.medium"
	key_name = "${aws_key_pair.support.key_name}"
	monitoring = true
	availability_zone = "${element(var.aws_availability_zones[var.aws_region], 0)}"
	subnet_id = "${element(aws_subnet.subnet.*.id, 0)}"
	security_groups = [
		"${aws_security_group.cluster.id}",
		"${aws_security_group.cluster_admin.id}",
		"${aws_security_group.cluster_user.id}"
	]

	root_block_device {
		volume_type = "gp2"
		volume_size = "20"
		iops = "100"
	}

	credit_specification {
		cpu_credits = "unlimited"
	}

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}
}

resource "null_resource" "scylla" {
	triggers {
		cluster_instance_ids = "${join(",", aws_instance.scylla.*.id)}"
	}

	connection {
		type = "ssh"
		host = "${element(aws_instance.scylla.*.public_ip, count.index)}"
		user = "centos"
		private_key = "${file(var.private_key)}"
		timeout = "1m"
	}

	provisioner "file" {
		destination = "/tmp/provision-scylla.sh"
		content = <<EOF
#!/bin/bash -x

set -eu

export PATH=/usr/local/bin:$${PATH}
export SEEDS="${join(",", aws_instance.scylla.*.public_ip)}"
export PUBLIC_IP=$$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

curl -o /usr/local/bin/yq -sSL https://github.com/mikefarah/yq/releases/download/2.1.2/yq_linux_amd64
chmod +x /usr/local/bin/yq

pushd /etc/scylla

yq w -i scylla.yaml authenticator PasswordAuthenticator
yq w -i scylla.yaml authorizer CassandraAuthorizer
yq w -i scylla.yaml endpoint_snitch GossipingPropertyFileSnitch
yq w -i scylla.yaml broadcast_address $${PUBLIC_IP}
yq w -i scylla.yaml broadcast_rpc_address $${PUBLIC_IP}
yq w -i scylla.yaml cluster_name ${var.cluster_name}
yq w -i scylla.yaml seed_provider[0].parameters[0].seeds $${SEEDS}

cat >cassandra-rackdc.properties <<EOG
#
# cassandra-rackdc.properties
#
dc=${var.aws_region}
rack=${format("Subnet%s", replace(element(aws_instance.scylla.*.availability_zone, count.index), "-", ""))}
EOG

popd

EOF
	}


	provisioner "remote-exec" {
		inline = [
			"chmod +x /tmp/provision-scylla.sh",
			"sudo /tmp/provision-scylla.sh"
		]
	}

	count = "${var.cluster_count}"
}

resource "null_resource" "monitor" {
	triggers {
		cluster_instance_ids = "${join(",", aws_instance.scylla.*.id)}"
		monitor_id = "${aws_instance.monitor.id}"
	}

	connection {
		type = "ssh"
		host = "${aws_instance.monitor.public_ip}"
		user = "centos"
		private_key = "${file(var.private_key)}"
		timeout = "1m"
	}

	provisioner "file" {
		destination = "/tmp/provision-monitor.sh"
		content = <<EOF
#!/bin/bash -x

set -eu

export PATH=/usr/local/bin:$${PATH}

curl -o /usr/local/bin/yq -sSL https://github.com/mikefarah/yq/releases/download/2.1.2/yq_linux_amd64
chmod +x /usr/local/bin/yq
mkdir -p /tmp/prometheus

pushd /home/centos/scylla-grafana-monitoring-scylla-monitoring
pushd prometheus

for file in node_exporter_servers.yml scylla_servers.yml; do
	echo '- {targets: [], labels: {}}' > $${file}
	yq w -i $${file} [0].labels.cluster ${var.cluster_name}
	yq w -i $${file} [0].labels.dc ${var.aws_region}
done

for node_ip in ${join(" ", aws_instance.scylla.*.public_ip)}; do
	yq w -i node_exporter_servers.yml [0].targets[+] $${node_ip}:9100
	yq w -i scylla_servers.yml [0].targets[+] $${node_ip}:9180
done

popd

./start-all.sh -v 2.0 -d /tmp/prometheus

popd

EOF
	}

	provisioner "remote-exec" {
		inline = [
			"chmod +x /tmp/provision-monitor.sh",
			"sudo /tmp/provision-monitor.sh"
		]
	}
}



resource "aws_key_pair" "support" {
	key_name = "support-key"
	public_key = "${file(var.public_key)}"
}

resource "aws_vpc" "vpc" {
	cidr_block = "10.0.0.0/16"

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}
}

resource "aws_internet_gateway" "vpc_igw" {
	vpc_id = "${aws_vpc.vpc.id}"

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}
}

resource "aws_subnet" "subnet" {
	availability_zone = "${element(var.aws_availability_zones[var.aws_region], count.index % length(var.aws_availability_zones[var.aws_region]))}"
	cidr_block = "${format("10.0.%d.0/24", count.index)}"
	vpc_id = "${aws_vpc.vpc.id}"
	map_public_ip_on_launch = true

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}

	count = "${var.cluster_count}"
}

resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.vpc.id}"

	route = {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.vpc_igw.id}"
	}

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}
}

resource "aws_route_table_association" "public" {
	route_table_id = "${aws_route_table.public.id}"
	subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"

	count = "${var.cluster_count}"
}

resource "aws_security_group" "cluster" {
	name = "cluster"
	description = "Security Group for inner cluster connections"
	vpc_id = "${aws_vpc.vpc.id}"

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}
}

resource "aws_security_group_rule" "cluster_egress" {
	type = "egress"
	security_group_id = "${aws_security_group.cluster.id}"
	cidr_blocks = ["0.0.0.0/0"]
	from_port = "0"
	to_port = "0"
	protocol = "-1"
}

resource "aws_security_group_rule" "cluster_ingress" {
	type = "ingress"
	security_group_id = "${aws_security_group.cluster.id}"
	cidr_blocks = ["${aws_instance.monitor.public_ip}/32", "${data.template_file.scylla_cidr.*.rendered}"]
	from_port = "${element(var.node_ports, count.index)}"
	to_port = "${element(var.node_ports, count.index)}"
	protocol = "tcp"

	count = "${length(var.node_ports)}"
}

resource "aws_security_group_rule" "cluster_monitor" {
	type = "ingress"
	security_group_id = "${aws_security_group.cluster.id}"
	cidr_blocks = ["${aws_instance.monitor.public_ip}/32"]
	from_port = "${element(var.monitor_ports, count.index)}"
	to_port = "${element(var.monitor_ports, count.index)}"
	protocol = "tcp"

	count = "${length(var.monitor_ports)}"
}

resource "aws_security_group" "cluster_admin" {
	name = "cluster-admin"
	description = "Security Group for the admin of cluster #${var.cluster_id}"
	vpc_id = "${aws_vpc.vpc.id}"

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}
}

resource "aws_security_group_rule" "cluster_admin_egress" {
	type = "egress"
	security_group_id = "${aws_security_group.cluster_admin.id}"
	cidr_blocks = ["0.0.0.0/0"]
	from_port = 0
	to_port = 0
	protocol = "-1"
}

resource "aws_security_group_rule" "cluster_admin_ingress" {
	type = "ingress"
	security_group_id = "${aws_security_group.cluster_admin.id}"
	cidr_blocks = "${var.cluster_admin_cidr}"
	from_port = "${element(var.admin_ports, count.index)}"
	to_port = "${element(var.admin_ports, count.index)}"
	protocol = "tcp"

	count = "${length(var.admin_ports)}"
}

resource "aws_security_group" "cluster_user" {
	name = "cluster-user"
	description = "Security Group for the user of cluster #${var.cluster_id}"
	vpc_id = "${aws_vpc.vpc.id}"

	tags = {
		environment = "${var.environment}"
		cluster_id	= "${var.cluster_id}"
	}
}

resource "aws_security_group_rule" "cluster_user_egress" {
	type = "egress"
	security_group_id = "${aws_security_group.cluster_user.id}"
	cidr_blocks = ["0.0.0.0/0"]
	from_port = 0
	to_port = 0
	protocol = "-1"
}

resource "aws_security_group_rule" "cluster_user_ingress" {
	type = "ingress"
	security_group_id = "${aws_security_group.cluster_user.id}"
	cidr_blocks = "${var.cluster_user_cidr}"
	from_port = "${element(var.user_ports, count.index)}"
	to_port = "${element(var.user_ports, count.index)}"
	protocol = "tcp"

	count = "${length(var.user_ports)}"
}
