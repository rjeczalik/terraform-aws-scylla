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

data "template_file" "provision_monitor_common_sh" {
	template = "${file(format("%s/provision/monitor-common.sh", var.template_dir))}"

	vars {
	}
}

data "template_file" "provision_monitor_sh" {
	template = "${file(format("%s/provision/monitor.sh", var.template_dir))}"

	vars {
		cluster_name = "${var.cluster_name}"
		dc = "${var.aws_region}"
		nodes_ips = "${join(" ", aws_eip.scylla.*.public_ip)}"
	}
}

data "template_file" "provision_stress_sh" {
	template = "${file(format("%s/provision/stress.sh", var.template_dir))}"

	vars {
	}
}

data "template_file" "provision_s3_sh" {
	template = "${file(format("%s/provision/s3.sh", var.template_dir))}"

	vars {
		bucket = "${data.template_file.bucket.rendered}"
		region = "${var.aws_region}"
		access_key = "${aws_iam_access_key.backup.id}"
		secret_key = "${aws_iam_access_key.backup.secret}"
	}
}
