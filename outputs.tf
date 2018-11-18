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
