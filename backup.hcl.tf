resource "aws_s3_bucket" "backup" {
	bucket = "${format("dbaas-%s-cluster-bucket-%s", var.environment, var.cluster_id)}"
	region = "${var.aws_region}"
	acl = "private"
	acceleration_status = "Enabled"

	tags = {
		environment = "${var.environment}"
		version     = "${var.version}"
		cluster_id  = "${var.cluster_id}"
		keep        = "alive"
	}

	lifecycle {
		prevent_destroy = true
	}
}

resource "aws_iam_user" "backup" {
	name = "${format("cluster-bucket-%s", var.cluster_id)}"
	path = "/users/"
}

resource "aws_iam_access_key" "backup" {
	user = "${aws_iam_user.backup.name}"
}

resource "aws_iam_user_policy" "backup" {
	name = "${format("cluster-bucket-%s-policy", var.cluster_id)}"
	user = "${aws_iam_user.backup.name}"

	policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": ["s3:ListBucket"],
		"Resource": ["arn:aws:s3:::${aws_s3_bucket.backup.bucket}"]
	}, {
		"Effect": "Allow",
		"Action": [
			"s3:PutObject",
			"s3:GetObject"
		],
		"Resource": ["arn:aws:s3:::${aws_s3_bucket.backup.bucket}/*"]
	}]
}
EOF
}
