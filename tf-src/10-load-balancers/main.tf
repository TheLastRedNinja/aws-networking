locals {
  default-aws-region      = "eu-west-1"
  default-tags = {
    Owner             = "Denis Murphy"
    Terraform         = true
    TerminationPolicy = "Can be deleted by anyone without notice"
    Created           = "12.01.2024"
  }
  local-machine-ip = "82.135.44.82/32"
}

locals {
  vpc-config = {
    vpc-name   = "denis-default-vpc"
    cidr-block = "172.31.0.0/16"
    create-igw = true
    azs        = ["eu-west-1", "eu-west-2"]
    subnets = {
      public = {
        subnet-name     = "denis-web-tier-public"
        subnet-type     = "public"
        number-of-azs   = null
        cidr-prefix     = "172.31.0.0/16"
        cidr-newbits    = 8
        additional-tags = {}
      }
      external = {
        subnet-name     = "denis-app-tier-public"
        subnet-type     = "external"
        number-of-azs   = null
        cidr-prefix     = "172.31.101.0/16"
        cidr-newbits    = 8
        additional-tags = {}
      }
    }
  }
}

