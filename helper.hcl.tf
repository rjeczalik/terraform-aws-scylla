variable "aws_availability_zones" {
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
	default = {
		"us-east-1" = "ami-04c172dadae705df1"
		"us-west-1" = "ami-0a7a96e5da05a6a1a"
		"us-west-2" = "ami-0f47671ff9c4532c5"
	}
}

variable "aws_ami_scylla" {
	default = {
		"us-east-1" = "ami-0f4178bd33d6cfa48"
		"us-west-1" = "ami-0a9db5299a5ee4409"
		"us-west-2" = "ami-0d82243436d964da0"
	}
}

variable "aws_ami_ubuntu" {
	default = {
		"us-east-1" = "ami-0f9351b59be17920e"
		"us-west-1" = "ami-0e066bd33054ef120"
		"us-west-2" = "ami-0afae182eed9d2b46"
	}
}
