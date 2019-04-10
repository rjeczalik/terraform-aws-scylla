# terraform-aws-scylladb

Terraform module for deploying ScyllaDB cluster on AWS. It deploys also [Scylla Monitoring Stack](https://docs.scylladb.com/operating-scylla/monitoring/monitoring_stack/) alongside the cluster, to monitor its metrics.

### Example

```bash
$ cat main.tf
```
```hcl
module "scylla-cluster" {
	source  = "github.com/rjeczalik/terraform-aws-scylla"

	aws_access_key = "AKIA..."
	aws_secret_key = "..."
	aws_instance_type = "i3.large"

	cluster_count = 3
	cluster_user_cidr = ["0.0.0.0/0"]
}
```

### Usage

Once you configure the module, create the cluster with:

```
$ terraform apply -no-color -auto-approve
```

To destroy the cluster, tear it down with:

```
$ terraform destroy -auto-approve
```

### Related modules

- https://github.com/rjeczalik/terraform-aws-scylla-bench
