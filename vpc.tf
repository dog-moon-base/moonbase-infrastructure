variable "region" {
  default     = "us-west-2"
  description = "AWS region"
}

provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "parktoken-production"
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "production-vpc"
  cidr                 = "172.20.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.20.12.0/22", "172.20.16.0/22", "172.20.20.0/22"]
  public_subnets       = ["172.20.0.0/22", "172.20.4.0/22", "172.20.8.0/22"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
