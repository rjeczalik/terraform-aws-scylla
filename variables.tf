variable "aws_access_key" {
	description = ""
}

variable "aws_secret_key" {
	description = ""
}

variable "aws_region" {
	description = ""
}

variable "aws_instance_type" {
	description = ""
}

variable "cluster_id" {
	description = ""
}

variable "cluster_name" {
	description = ""
}

variable "cluster_count" {
	description = ""
	default = 1
}

variable "cluster_admin_cidr" {
	description = ""
	type = "list"
}

variable "cluster_user_cidr" {
	description = ""
	type = "list"
}

variable "environment" {
	description = ""
	default = "development"
}

variable "version" {
	description = ""
	default = "0.2.0"
}

variable "private_key" {
	description = ""
	default = "keys/support.pem"
}

variable "public_key" {
	description = ""
	default = "keys/support.pub"
}

variable "cql_user" {
	description = ""
	default = "scylla"
}

variable "cql_admin" {
	description = ""
	default = "scylla_admin"
}

variable "system_auth_replication" {
	description = ""
	default = 3
}

variable "scylla_args" {
	description = ""
	type = "list"
	default = [
		"--clustername %s",
		"--totalnodes 1",
		"--stop-services"
	]
}

variable "public_keys" {
	description = ""
	type = "list"
	default = []
}

variable "admin_ports" {
	description = ""
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
	description = ""
	type = "list"
	default = [
		9042,
		9160
	]
}

variable "node_ports" {
	description = ""
	type = "list"
	default = [
		7000,
		7001
	]
}

variable "monitor_ports" {
	description = ""
	type = "list"
	default = [
		9100,
		9180
	]
}

variable "aws_ami_monitor" {
	description = ""
	type = "map"
	default = {
		"us-east-1" = "ami-04c172dadae705df1"
		"us-west-1" = "ami-0a7a96e5da05a6a1a"
		"us-west-2" = "ami-0f47671ff9c4532c5"
	}
}

variable "aws_ami_scylla" {
	description = ""
	type = "map"
	default = {
		"us-east-1" = "ami-0f4178bd33d6cfa48"
		"us-west-1" = "ami-0a9db5299a5ee4409"
		"us-west-2" = "ami-0d82243436d964da0"
	}
}

variable "aws_ami_ubuntu" {
	description = ""
	type = "map"
	default = {
		"us-east-1" = "ami-0f9351b59be17920e"
		"us-west-1" = "ami-0e066bd33054ef120"
		"us-west-2" = "ami-0afae182eed9d2b46"
	}
}

variable "aws_ami_centos" {
	description = ""
	type = "map"
	default = {
		"us-east-1" = "ami-4bf3d731"
		"us-west-1" = "ami-65e0e305"
		"us-west-2" = "ami-a042f4d8"
	}
}
