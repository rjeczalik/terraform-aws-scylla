data "template_file" "bucket" {
	template = "cloud-$${environment}-cluster-bucket-$${cluster_id}"

	vars = {
		environment = "${var.environment}"
		cluster_id = "${random_uuid.cluster_id.result}"
	}
}

resource "aws_iam_user" "backup" {
	name = "${format("cluster-bucket-%s", random_uuid.cluster_id.result)}"
	path = "/users/"
}

resource "aws_iam_access_key" "backup" {
	user = "${aws_iam_user.backup.name}"
}

resource "aws_iam_user_policy" "backup" {
	name = "${format("cluster-bucket-%s-policy", random_uuid.cluster_id.result)}"
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
