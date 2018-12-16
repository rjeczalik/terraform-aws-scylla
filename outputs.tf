output "cluster_id" {
	value = "${random_uuid.cluster_id.result}"
}

output "seeds" {
	value = "${aws_eip.scylla.*.public_ip}"
}

output "monitor" {
	value = "http://${aws_eip.monitor.public_ip}:3000"
}

output "username" {
	value = "${var.cql_admin}"
}

output "password" {
	value = "${random_string.admin_password.result}"
}

output "private_key" {
	value = "${local.private_key}"
}

output "public_key" {
	value = "${local.public_key}"
}
