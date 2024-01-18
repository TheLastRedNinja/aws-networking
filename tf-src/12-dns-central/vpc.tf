module "vpc-dns-lab-central" {
  source = "../../../modules/network/vpc"

  vpc-name = local.vpc-central-config.vpc-name
  vpc-cidr = local.vpc-central-cidr
  azs      = local.vpc-central-config.azs
  subnets  = local.vpc-central-config.subnets

  create-igw = true

  default-tags = local.default-tags
}