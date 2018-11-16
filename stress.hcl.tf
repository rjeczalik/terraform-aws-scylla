resource "aws_instance" "stress" {
	ami = "${data.aws_ami.centos.id}"
	instance_type = "c4.large"
	key_name = "${aws_key_pair.support.key_name}"
	monitoring = true
	availability_zone = "${element(var.aws_availability_zones[var.aws_region], count.index % length(var.aws_availability_zones[var.aws_region]))}"
	subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"

	security_groups = [
		"${aws_security_group.cluster.id}",
		"${aws_security_group.cluster_admin.id}",
		"${aws_security_group.cluster_user.id}"
	]

	credit_specification {
		cpu_credits = "unlimited"
	}

	tags = {
		environment = "${var.environment}"
		version     = "${var.version}"
		cluster_id	= "${var.cluster_id}"
		keep        = "alive"
	}

	count = "${var.cluster_stress_count}"
}

resource "null_resource" "stress" {
	triggers {
		elastic_ips = "${join(",", aws_eip.stress.*.public_ip)}"
		stress_id = "${join(",", aws_instance.stress.*.id)}"
	}

	connection {
		type = "ssh"
		host = "${element(aws_eip.stress.*.public_ip, count.index)}"
		user = "centos"
		private_key = "${file(var.private_key)}"
		timeout = "1m"
	}

	provisioner "file" {
		destination = "/tmp/provision-common.sh"
		content = "${data.template_file.provision_common_sh.rendered}"
	}

	provisioner "file" {
		destination = "/tmp/provision-stress.sh"
		content = "${data.template_file.provision_stress_sh.rendered}"
	}

	provisioner "remote-exec" {
		inline = [
			"chmod +x /tmp/provision-stress.sh",
			"sudo /tmp/provision-stress.sh"
		]
	}

	count = "${var.cluster_stress_count}"
	depends_on = ["null_resource.scylla_start"]
}

resource "aws_eip" "stress" {
	vpc = true
	instance = "${element(aws_instance.stress.*.id, count.index)}"

	count = "${var.cluster_stress_count}"
	depends_on = ["aws_internet_gateway.vpc_igw"]
}

data "aws_ami" "centos" {
	most_recent = true

	filter {
		name   = "name"
		values = ["CentOS Linux 7 x86_64 HVM EBS*"]
	}

	filter {
		name   = "architecture"
		values = ["x86_64"]
	}

	filter {
		name   = "root-device-type"
		values = ["ebs"]
	}

	owners = ["679593333241"]
}
