data "aws_availability_zones" "all" {}

data "template_file" "provision_common_sh" {
	template = "${file(format("%s/tpl/provision/common.sh", path.module))}"

	vars {
		public_keys = "${join("\n", var.public_keys)}"
	}
}

data "template_file" "provision_scylla_sh" {
	template = "${file(format("%s/tpl/provision/scylla.sh", path.module))}"

	vars {
		public_ip = "${element(aws_eip.scylla.*.public_ip, count.index)}"
		seeds = "${join(",", aws_eip.scylla.*.public_ip)}"
		dc = "${var.aws_region}"
		rack = "${format("Subnet%s", replace(element(aws_instance.scylla.*.availability_zone, count.index), "-", ""))}"
		cluster_name = "${var.cluster_name}"
	}

	count = "${var.cluster_count}"
}

data "template_file" "provision_scylla_schema_sh" {
	template = "${file(format("%s/tpl/provision/scylla-schema.sh", path.module))}"

	vars = {
		dc = "${var.aws_region}"
		user = "${var.cql_user}"
		user_password = "${random_string.user_password.result}"
		admin = "${var.cql_admin}"
		admin_password = "${random_string.admin_password.result}"
		system_auth_replication = "${var.system_auth_replication}"
	}
}

data "template_file" "provision_monitor_common_sh" {
	template = "${file(format("%s/tpl/provision/monitor-common.sh", path.module))}"

	vars = {
	}
}

data "template_file" "provision_monitor_sh" {
	template = "${file(format("%s/tpl/provision/monitor.sh", path.module))}"

	vars = {
		cluster_name = "${var.cluster_name}"
		dc = "${var.aws_region}"
		nodes_ips = "${join(" ", aws_eip.scylla.*.public_ip)}"
	}
}

data "template_file" "provision_s3_sh" {
	template = "${file(format("%s/tpl/provision/s3.sh", path.module))}"

	vars = {
		bucket = "${data.template_file.bucket.rendered}"
		region = "${var.aws_region}"
		access_key = "${aws_iam_access_key.backup.id}"
		secret_key = "${aws_iam_access_key.backup.secret}"
	}
}

data "template_file" "scylla_cidr" {
	template = "$${cidr}"

	vars = {
		cidr = "${element(aws_eip.scylla.*.public_ip, count.index)}/32"
	}

	count = "${var.cluster_count}"
}

data "template_file" "public_keys" {
	template = "$${public_key}"

	vars = {
		public_key = "${file(element(var.public_keys, count.index))}"
	}

	count = "${length(var.public_keys)}"
}

resource "random_string" "user_password" {
	length = 16
	special = true
	override_special = "!@#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "admin_password" {
	length = 16
	special = true
	override_special = "!@#$%&*()-_=+[]{}<>:?"
}
