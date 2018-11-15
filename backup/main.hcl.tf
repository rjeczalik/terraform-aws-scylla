variable "aws_access_key" { }
variable "aws_secret_key" { }
variable "aws_region" { }

variable "environment" { }
variable "cluster_id" { }

provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

resource "aws_s3_bucket" "backup" {
	bucket = "${format("dbaas-%s-cluster-bucket-%s", var.environment, var.cluster_id)}"
	region = "${var.aws_region}"
	acl = "private"
	acceleration_status = "Enabled"

	tags = {
		environment = "${var.environment}"
		cluster_id  = "${var.cluster_id}"
		keep        = "alive"
	}

	lifecycle {
		prevent_destroy = true
	}
}
