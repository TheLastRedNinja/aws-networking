locals {
  vpc-name = var.vpc-name

  # Default settings will not create any subnet resources
  default-subnet-specs = {
    subnet-name     = null
    subnet-type     = "public"
    number-of-azs   = 0
    cidr-prefix     = var.vpc-cidr
    cidr-newbits    = 0
    additional-tags = {}
  }

  subnets = module.public-subnet.subnets

  public-subnets-exist = contains(keys(var.subnets), var.name-for-default-public-subnet)
}

###################################################
## VPC
###################################################

resource "aws_vpc" "this" {
  cidr_block = var.vpc-cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = false

  tags = merge(var.default-tags, lookup(var.resource-specific-tags, "vpc", {}), {
    Name = local.vpc-name
  })
}

###################################################
## Public Subnet
###################################################

module "public-subnet" {
  source = "../subnets-in-vpc"

  vpc-id       = aws_vpc.this.id
  subnet-specs = lookup(var.subnets, var.name-for-default-public-subnet, local.default-subnet-specs)

  availability-zones-in-use = var.azs
  create-nat-gateway        = false

  default-tags = var.default-tags
}

###################################################
## Private Subnets
###################################################

module "private-subnets" {
  for_each = toset([for subnet in setsubtract(toset(keys(var.subnets)), [var.name-for-default-public-subnet]) : subnet])

  source = "../subnets-in-vpc"

  vpc-id       = aws_vpc.this.id
  subnet-specs = lookup(var.subnets, each.value, local.default-subnet-specs)

  availability-zones-in-use = var.azs
  create-nat-gateway        = true

  default-tags = var.default-tags
}

