data "template_file" "bucket" {
	template = "cloud-$${environment}-cluster-bucket-$${cluster_id}"

	vars = {
		environment = "${var.environment}"
		cluster_id = "${var.cluster_id}"
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
		"Resource": ["arn:aws:s3:::${data.template_file.bucket.rendered}"]
	}, {
		"Effect": "Allow",
		"Action": [
			"s3:PutObject",
			"s3:GetObject"
		],
		"Resource": ["arn:aws:s3:::${data.template_file.bucket.rendered}/*"]
	}]
}
EOF
}
