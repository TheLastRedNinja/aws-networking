###################################################
## Config for VPC and subnets
###################################################

module "vpc" {
  source = "../../../modules/network/vpc"

  vpc-name = local.vpc-config.vpc-name
  vpc-cidr = local.vpc-config.cidr-block

  create-igw   = local.vpc-config.create-igw
  default-tags = local.default-tags

  azs     = local.vpc-config.azs
  subnets = local.vpc-config.subnets
}