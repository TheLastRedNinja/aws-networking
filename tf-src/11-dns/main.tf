locals {
  default-aws-region = "eu-west-1"

  default-tags = {
    Owner             = "Denis Murphy"
    Terraform         = true
    TerminationPolicy = "Can be deleted by anyone without notice"
    Created           = "22.01.2024"
  }

  local-machine-ip = "82.135.44.82/32"
  base-domain      = "sphalerondecays.online"
  vpc-west-cidr    = "172.3.0.0/16"

  vpc-west-config = {
    vpc-name   = "denis-dns-lab"
    cidr-block = local.vpc-west-cidr
    create-igw = true
    azs        = ["eu-west-1a", "eu-west-1b"]
    subnets = {
      public = {
        subnet-name     = "denis-public"
        subnet-type     = "public"
        number-of-azs   = null
        cidr-prefix     = local.vpc-west-cidr
        cidr-newbits    = 8
        additional-tags = {}
      }
    }
  }
}
