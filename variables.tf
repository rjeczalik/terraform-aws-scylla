variable "aws_access_key" {
	description = ""
	default = ""
}

variable "aws_secret_key" {
	description = ""
	default = ""
}

variable "aws_region" {
	description = ""
	default = "us-east-1"
}

variable "aws_instance_type" {
	description = ""
	default = "i3.large"
}

variable "cluster_count" {
	description = ""
	default = 3
}

variable "cluster_admin_cidr" {
	description = ""
	type = "list"
	default = []
}

variable "cluster_user_cidr" {
	description = ""
	type = "list"
	default = []
}

variable "cluster_broadcast" {
	description = ""
	default = "public"
}

variable "environment" {
	description = ""
	default = "development"
}

variable "version" {
	description = ""
	default = "0.3.0"
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

variable "monitor_alert_from" {
	description = ""
	default = ""
}

variable "monitor_alert_to" {
	description = ""
	default = ""
}

variable "monitor_alert_hostport" {
	description = ""
	default = ""
}

variable "monitor_alert_username" {
	description = ""
	default = ""
}

variable "monitor_alert_identity" {
	description = ""
	default = ""
}

variable "monitor_alert_password" {
	description = ""
	default = ""
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

variable "aws_ami_scylla_oss" {
	description = ""
	type = "map"
	default = {
		"us-east-1" = "ami-0a0e33a6a9ad49e28"
		"us-west-1" = "ami-0d0470b0d3adf8e62"
		"us-west-2" = "ami-0eb3613c5069e80c5"
		"eu-west-1" = "ami-09dc493608b93279e"
		"sa-east-1" = "ami-0ceba50df0b950d4a"
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
