variable "aws_access_key" { }
variable "aws_secret_key" { }
variable "aws_region" { }
variable "aws_instance_type" { }

variable "cluster_id" { }
variable "cluster_name" { }
variable "cluster_count" { default = 1 }
variable "cluster_admin_cidr" { type = "list" }
variable "cluster_user_cidr" { type = "list" }

variable "environment" { default = "development" }
variable "version" { default = "0.1.0" }

variable "private_key" { default = "keys/support.pem" }
variable "public_key"	{ default = "keys/support.pub" }
variable "template_dir" { default = "tpl" }

variable "scylla_args" {
	type = "list"
	default = [
		"--clustername %s",
		"--totalnodes 1",
		"--stop-services"
	]
}

variable "admin_ports" {
	type = "list"
	default = [
		22,
		3000,
		9042,
		9090,
		9093
	]
}

variable "user_ports" {
	type = "list"
	default = [
		9042,
		9160
	]
}

variable "node_ports" {
	type = "list"
	default = [
		7000,
		7001
	]
}

variable "monitor_ports" {
	type = "list"
	default = [
		9100,
		9180
	]
}

variable "aws_availability_zones" {
	type = "map"
	default = {
		"us-east-1" = [
			"us-east-1a",
			"us-east-1b",
			"us-east-1c",
		]

		"us-west-1" = [
			"us-west-1a",
			"us-west-1b",
			"us-west-1c",
		]

		"us-west-2" = [
			"us-west-2a",
			"us-west-2b",
			"us-west-2c",
		]
	}
}

variable "aws_ami_monitor" {
	type = "map"
	default = {
		"us-east-1" = "ami-04c172dadae705df1"
		"us-west-1" = "ami-0a7a96e5da05a6a1a"
		"us-west-2" = "ami-0f47671ff9c4532c5"
	}
}

variable "aws_ami_scylla" {
	type = "map"
	default = {
		"us-east-1" = "ami-0f4178bd33d6cfa48"
		"us-west-1" = "ami-0a9db5299a5ee4409"
		"us-west-2" = "ami-0d82243436d964da0"
	}
}

variable "aws_ami_ubuntu" {
	type = "map"
	default = {
		"us-east-1" = "ami-0f9351b59be17920e"
		"us-west-1" = "ami-0e066bd33054ef120"
		"us-west-2" = "ami-0afae182eed9d2b46"
	}
}
