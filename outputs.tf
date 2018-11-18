output "seeds" {
	value = "${aws_instance.scylla.*.public_ip}"
}

output "monitor" {
	value = "http://${aws_instance.monitor.public_ip}:3000"
}

output "username" {
	value = "${var.cql_admin}"
}

output "password" {
	value = "${random_string.admin_password.result}"
}
