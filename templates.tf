data "aws_availability_zones" "all" {}

data "template_file" "provision_common_sh" {
	template = "${file(format("%s/scripts/common.sh", path.module))}"

	vars {
		public_keys = "${join("\n", var.public_keys)}"
	}
}

data "external" "ifconfig_co" {
	program = ["bash", "${path.module}/scripts/ifconfig-co.sh"]
}

data "template_file" "provision_scylla_sh" {
	template = "${file(format("%s/scripts/scylla.sh", path.module))}"

	vars {
		ip = "${var.cluster_broadcast == "private" ? element(aws_instance.scylla.*.private_ip, count.index) : element(aws_eip.scylla.*.public_ip, count.index)}"
		seeds = "${var.cluster_broadcast == "private" ? join(",", aws_instance.scylla.*.private_ip) : join(",", aws_eip.scylla.*.public_ip)}"
		dc = "${var.aws_region}"
		rack = "${format("Subnet%s", replace(element(aws_instance.scylla.*.availability_zone, count.index), "-", ""))}"
		cluster_name = "${local.cluster_name}"
	}

	count = "${var.cluster_count}"
}

data "template_file" "provision_scylla_schema_sh" {
	template = "${file(format("%s/scripts/scylla-schema.sh", path.module))}"

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
	template = "${file(format("%s/scripts/monitor-common.sh", path.module))}"

	vars = {
	}
}

data "template_file" "provision_monitor_sh" {
	template = "${file(format("%s/scripts/monitor.sh", path.module))}"

	vars = {
		cluster_name = "${local.cluster_name}"
		dc = "${var.aws_region}"
		nodes_ips = "${var.cluster_broadcast == "private" ? join(" ", aws_instance.scylla.*.private_ip) : join(" ", aws_eip.scylla.*.public_ip)}"
	}
}

data "template_file" "provision_s3_sh" {
	template = "${file(format("%s/scripts/s3.sh", path.module))}"

	vars = {
		bucket = "${data.template_file.bucket.rendered}"
		region = "${var.aws_region}"
		access_key = "${aws_iam_access_key.backup.id}"
		secret_key = "${aws_iam_access_key.backup.secret}"
	}
}

data "template_file" "config_monitor_rule_yml" {
	template = "${file(format("%s/configs/monitor_rule.yml", path.module))}"

	vars = {
		environment = "${var.environment}"
		cluster_id = "${random_uuid.cluster_id.result}"
		monitor_alert_from = "${var.monitor_alert_from}"
		monitor_alert_to = "${var.monitor_alert_to}"
		monitor_alert_hostport = "${var.monitor_alert_hostport}"
		monitor_alert_username = "${var.monitor_alert_username}"
		monitor_alert_identity = "${var.monitor_alert_identity}"
		monitor_alert_password = "${var.monitor_alert_password}"
	}
}

data "template_file" "scylla_cidr" {
	template = "$${cidr}"

	vars = {
		cidr = "${var.cluster_broadcast == "private" ? element(aws_instance.scylla.*.private_ip, count.index) : element(aws_eip.scylla.*.public_ip, count.index)}/32"
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
	special = false
}

resource "random_string" "admin_password" {
	length = 16
	special = false
}
