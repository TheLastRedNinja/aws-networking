###################################################
## Config for Security Group
###################################################

locals {
  security-groups = {
    dns-lab = {
      name        = "dns-lab"
      description = "sg used with dns-lab"
      ingress-rules = {
        http = {
          description = "http from World"
          from        = 80
          to          = 80
          cidr        = ["0.0.0.0/0"]
        }
        ssh = {
          description = "ssh from local machine"
          from        = 22
          to          = 22
          cidr        = [local.local-machine-ip]
        }
      }
      egress-rules = {
        http_world = {
          from        = 80
          to          = 80
          description = "http to World"
          cidr        = ["0.0.0.0/0"]
        }
        https_world = {
          from        = 443
          to          = 443
          description = "https to World, Needed for yum"
          cidr        = ["0.0.0.0/0"]
        }
      }
    }
  }
  #
  #  _sg-iterator = flatten([
  #    for sg, config in local.security-groups :
  #    [ for region in ["eu-west-1", "eu-central-1"]: { "${sg}-${region}" : merge(config, { vpc-id = region }) }]
  # ])
  #
  #  sg_iterator = { for item in local._sg-iterator :
  #    keys(item)[0] => values(item)[0]
  #  }
}

resource "aws_security_group" "denis-dns-lab-central" {

  for_each = local.security-groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc-dns-lab-central.vpc-id

  dynamic "ingress" {
    for_each = each.value.ingress-rules
    iterator = it
    content {
      description = try(it.value.description, "")
      protocol    = "tcp"
      from_port   = it.value.from
      to_port     = it.value.to
      cidr_blocks = it.value.cidr
    }
  }

  dynamic "egress" {
    for_each = try(each.value.egress-rules, {})
    iterator = it
    content {
      description = try(it.value.description, "")
      protocol    = "tcp"
      from_port   = it.value.from
      to_port     = it.value.to
      cidr_blocks = it.value.cidr
    }
  }

  tags = merge(local.default-tags, {
    Name = each.value.name
  })
}