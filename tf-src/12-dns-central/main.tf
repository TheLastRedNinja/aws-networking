locals {
  default-aws-region = "eu-central-1"

  default-tags = {
    Owner             = "Denis Murphy"
    Terraform         = true
    TerminationPolicy = "Can be deleted by anyone without notice"
    Created           = "17.01.2024"
  }

  local-machine-ip = "82.135.44.82/32"
  base-domain      = "http://sphalerondecays456.com/"
  vpc-central-cidr       = "172.9.0.0/16"

  vpc-central-config = {
    vpc-name   = "denis-dns-lab"
    cidr-block = local.vpc-central-cidr
    create-igw = true
    azs        = ["eu-central-1a", "eu-central-1b"]
    subnets = {
      public = {
        subnet-name     = "denis-public"
        subnet-type     = "public"
        number-of-azs   = null
        cidr-prefix     = local.vpc-central-cidr
        cidr-newbits    = 8
        additional-tags = {}
      }
    }
  }
}
