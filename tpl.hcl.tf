data "template_file" "provision_common_sh" {
	template = "${file(format("%s/provision/common.sh", var.template_dir))}"

	vars {
	}
}

data "template_file" "provision_scylla_sh" {
	template = "${file(format("%s/provision/scylla.sh", var.template_dir))}"

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
	template = "${file(format("%s/provision/scylla-schema.sh", var.template_dir))}"

	vars = {
		dc = "${var.aws_region}"
		user = "${var.cql_user}"
		user_password = "${random_string.user_password.result}"
		admin = "${var.cql_admin}"
		admin_password = "${random_string.admin_password.result}"
		system_auth_replication = "${var.system_auth_replication}"
	}
}

data "template_file" "provision_stress_sh" {
	template = "${file(format("%s/provision/stress.sh", var.template_dir))}"

	vars = {
	}

	count = "${var.cluster_stress_count}"
}

data "template_file" "provision_monitor_common_sh" {
	template = "${file(format("%s/provision/monitor-common.sh", var.template_dir))}"

	vars = {
	}
}

data "template_file" "provision_monitor_sh" {
	template = "${file(format("%s/provision/monitor.sh", var.template_dir))}"

	vars = {
		cluster_name = "${var.cluster_name}"
		dc = "${var.aws_region}"
		nodes_ips = "${join(" ", aws_eip.scylla.*.public_ip)}"
	}
}

data "template_file" "provision_s3_sh" {
	template = "${file(format("%s/provision/s3.sh", var.template_dir))}"

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
