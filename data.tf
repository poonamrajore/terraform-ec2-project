# Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# Get Subnets of Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

