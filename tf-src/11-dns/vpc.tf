module "vpc-dns-lab-west" {
  source = "../../../modules/network/vpc"

  vpc-name = local.vpc-west-config.vpc-name
  vpc-cidr = local.vpc-west-cidr
  azs      = local.vpc-west-config.azs
  subnets  = local.vpc-west-config.subnets

  create-igw = true

  default-tags = local.default-tags
}