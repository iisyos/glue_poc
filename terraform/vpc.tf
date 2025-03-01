# @see https://registry.terraform.io/modules/kasaikou/vpc/aws/latest
module "vpc" {
  source     = "kasaikou/vpc/aws"
  name       = var.app_name
  cidr_block = "10.0.0.0/16"
  subnets = {
    "public-primary" = {
      cidr_block        = "10.0.32.0/20"
      availability_zone = "ap-northeast-1a"
      route_tables      = ["igw"]
    }
    "private-primary" = {
      cidr_block        = "10.0.64.0/20"
      availability_zone = "ap-northeast-1a"
    },
    "private-secondary" = {
      cidr_block        = "10.0.80.0/20"
      availability_zone = "ap-northeast-1c"
    }
  }
  route_tables = {
    "igw" = {
      global_type = "igw"
      vpc_gateway_endpoints = [
        "com.amazonaws.ap-northeast-1.s3"
      ]
    }
  }
}
